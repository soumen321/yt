import boto3
import json
import time
import logging
from typing import Dict, Any
from botocore.exceptions import ClientError

logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

class RootFSInfoError(Exception):
    """Custom exception for root filesystem info errors"""
    pass

def get_root_fs_info(instance_id: str, region: str, max_retries: int = 3) -> Dict[str, Any]:
    """
    Get root filesystem information for an EC2 instance.
    
    Args:
        instance_id: The EC2 instance ID
        region: AWS region where the instance is located
        max_retries: Maximum number of retries for SSM command
        
    Returns:
        Dictionary containing:
        - device: Device name (e.g., /dev/xvda1)
        - fstype: Filesystem type (e.g., ext4, xfs)
        - mountpoint: Mount point (always '/')
        
    Raises:
        RootFSInfoError: If filesystem information cannot be determined
    """
    ssm_client = boto3.client('ssm', region_name=region)
    ec2_client = boto3.client('ec2', region_name=region)
    
    try:
        # 1. Validate instance state
        instance_state = _check_instance_state(ec2_client, instance_id)
        if instance_state != 'running':
            raise RootFSInfoError(f"Instance {instance_id} is not running (current state: {instance_state})")

        # 2. Verify SSM connectivity
        _verify_ssm_connectivity(ssm_client, instance_id)

        command = _build_detection_command()
        attempt = 0
        last_exception = None
        
        while attempt < max_retries:
            attempt += 1
            try:
                command_id = _execute_ssm_command(ssm_client, instance_id, command)
                output = _wait_for_command(ssm_client, instance_id, command_id)
                
                fs_info = _parse_response(output)
                fs_info['fstype'] = _ensure_fstype(ssm_client, instance_id, fs_info)
                fs_info['device'] = _sanitize_device_path(fs_info['device'])
                
                return fs_info
                
            except Exception as e:
                last_exception = e
                logger.warning(f"Attempt {attempt} failed: {str(e)}")
                if attempt < max_retries:
                    time.sleep(5 * attempt)  # Exponential backoff
        
        raise RootFSInfoError(f"All {max_retries} attempts failed") from last_exception

    except ClientError as e:
        error_code = e.response.get('Error', {}).get('Code', '')
        if error_code == 'InvalidInstanceId':
            raise RootFSInfoError(f"Instance {instance_id} not ready for SSM commands")
        raise RootFSInfoError(f"AWS API error: {str(e)}")

def _build_detection_command() -> str:
    """Build the shell command to detect root filesystem info"""
    return r"""
    set -euo pipefail
    
    # Function to get filesystem type with multiple fallbacks
    get_fstype() {
        local dev="$1"
        lsblk -no FSTYPE "$dev" 2>/dev/null || \
        blkid -o value -s TYPE "$dev" 2>/dev/null || \
        df -T "$dev" 2>/dev/null | awk 'NR==2 {print $2}' || \
        file -sL "$dev" 2>/dev/null | grep -oE 'ext[2-4]|xfs|btrfs|vfat|ntfs' || \
        awk -v dev="$dev" '$1 == dev {print $3}' /proc/mounts 2>/dev/null || \
        echo "unknown"
    }
    
    # Try multiple detection methods
    for method in findmnt proc_mounts df mountinfo; do
        case $method in
            findmnt)
                if command -v findmnt >/dev/null; then
                    ROOT_DEV=$(findmnt -n -o SOURCE /)
                    ROOT_FSTYPE=$(findmnt -n -o FSTYPE /)
                    [ -n "$ROOT_DEV" ] && break
                fi
                ;;
                
            proc_mounts)
                if [ -f /proc/mounts ]; then
                    while IFS=' ' read -r device mountpoint fstype _; do
                        if [ "$mountpoint" = "/" ]; then
                            ROOT_DEV=$(readlink -f "$device" || echo "$device")
                            ROOT_FSTYPE="$fstype"
                            break
                        fi
                    done < /proc/mounts
                    [ -n "$ROOT_DEV" ] && break
                fi
                ;;
                
            df)
                ROOT_DEV=$(df / --output=source 2>/dev/null | tail -n1 | xargs)
                if [ -z "$ROOT_DEV" ]; then
                    ROOT_DEV=$(df / | awk 'NR==2 {print $1}' | xargs)
                fi
                [ -n "$ROOT_DEV" ] && ROOT_FSTYPE=$(get_fstype "$ROOT_DEV")
                [ -n "$ROOT_DEV" ] && break
                ;;
                
            mountinfo)
                if [ -f /proc/self/mountinfo ]; then
                    while read -r _ _ _ mountpoint _ _ _ device _; do
                        if [ "$mountpoint" = "/" ]; then
                            ROOT_DEV=$(readlink -f "$device" || echo "$device")
                            ROOT_FSTYPE=$(get_fstype "$ROOT_DEV")
                            break
                        fi
                    done < /proc/self/mountinfo
                    [ -n "$ROOT_DEV" ] && break
                fi
                ;;
        esac
    done
    
    if [ -n "$ROOT_DEV" ]; then
        echo "{\"device\": \"${ROOT_DEV}\", \"fstype\": \"${ROOT_FSTYPE:-unknown}\", \"mountpoint\": \"/\"}"
    else
        echo "ERROR: Could not determine root filesystem"
        exit 1
    fi
    """

def _check_instance_state(ec2_client, instance_id: str) -> str:
    """Check and return instance state"""
    response = ec2_client.describe_instances(InstanceIds=[instance_id])
    instances = response['Reservations'][0]['Instances']
    
    if not instances:
        raise RootFSInfoError(f"Instance {instance_id} not found")
    
    return instances[0]['State']['Name']

def _verify_ssm_connectivity(ssm_client, instance_id: str) -> None:
    """Verify SSM connectivity with proper timeout"""
    try:
        response = ssm_client.send_command(
            InstanceIds=[instance_id],
            DocumentName="AWS-RunShellScript",
            Parameters={'commands': ["echo 'SSM connectivity test'"]},
            TimeoutSeconds=30  # Minimum allowed value
        )
        command_id = response['Command']['CommandId']
        
        # Wait for command with timeout
        for _ in range(6):  # 6 * 5 = 30 seconds total
            time.sleep(5)
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id,
            )
            if output['Status'] != 'InProgress':
                break
        
        if output['Status'] != 'Success':
            raise RootFSInfoError(f"SSM test command failed: {output.get('StandardErrorContent', 'Unknown error')}")
            
    except ClientError as e:
        raise

def _execute_ssm_command(ssm_client, instance_id: str, command: str) -> str:
    """Execute SSM command with proper timeout"""
    response = ssm_client.send_command(
        InstanceIds=[instance_id],
        DocumentName="AWS-RunShellScript",
        Parameters={'commands': [command]},
        CloudWatchOutputConfig={
            'CloudWatchLogGroupName': f'/aws/ssm/root_fs_info/{instance_id}',
            'CloudWatchOutputEnabled': True
        },
        TimeoutSeconds=30  # Minimum allowed value
    )
    return response['Command']['CommandId']

def _wait_for_command(ssm_client, instance_id: str, command_id: str, timeout: int = 180) -> Dict:
    """Wait for SSM command to complete with timeout"""
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id,
            )
            
            if output['Status'] in ['Success', 'Failed', 'TimedOut', 'Cancelled']:
                if output['Status'] != 'Success':
                    error_msg = output.get('StandardErrorContent', 'No error output')
                    raise RootFSInfoError(f"SSM command failed: {error_msg}")
                return output
                
        except ClientError as e:
            logger.warning(f"Error checking command status: {str(e)}")
        
        time.sleep(5)
    
    raise RootFSInfoError("SSM command timed out")

def _parse_response(output: Dict) -> Dict[str, str]:
    """Parse and validate the SSM command output"""
    try:
        fs_info = json.loads(output['StandardOutputContent'])
        
        if not all(key in fs_info for key in ['device', 'fstype', 'mountpoint']):
            raise ValueError("Incomplete response from instance")
        
        if not fs_info['device']:
            raise ValueError("Empty device name in response")
            
        return fs_info
        
    except json.JSONDecodeError:
        raise RootFSInfoError("Invalid JSON response from instance")
    except ValueError as ve:
        raise RootFSInfoError(str(ve))

def _ensure_fstype(ssm_client, instance_id: str, fs_info: Dict) -> str:
    """Ensure filesystem type is determined"""
    if fs_info['fstype'] and fs_info['fstype'].lower() != 'unknown':
        return fs_info['fstype']
    
    # Try additional methods if initial detection failed
    fallback_commands = [
        f"blkid -o value -s TYPE {fs_info['device']}",
        f"lsblk -no FSTYPE {fs_info['device']}",
        f"df -T {fs_info['device']} | awk 'NR==2 {{print $2}}'",
        f"file -sL {fs_info['device']} | grep -oE 'ext[2-4]|xfs|btrfs|vfat|ntfs'",
        f"grep -E '{fs_info['device']}\\s+/\\s+' /proc/mounts | awk '{{print $3}}'"
    ]
    
    for cmd in fallback_commands:
        try:
            response = ssm_client.send_command(
                InstanceIds=[instance_id],
                DocumentName="AWS-RunShellScript",
                Parameters={'commands': [cmd + " || echo ''"]},
                TimeoutSeconds=30
            )
            command_id = response['Command']['CommandId']
            
            time.sleep(5)
            output = ssm_client.get_command_invocation(
                CommandId=command_id,
                InstanceId=instance_id,
            )
            
            if output['Status'] == 'Success':
                result = output['StandardOutputContent'].strip()
                if result:
                    return result
        except:
            continue
    
    return "unknown"

def _sanitize_device_path(device: str) -> str:
    """Normalize device path formatting"""
    if not device.startswith('/dev/'):
        return f"/dev/{device}"
    return device
