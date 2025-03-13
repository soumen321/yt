import boto3
import os

def lambda_handler(event, context):
    ssm_client = boto3.client('ssm')
    ec2_client = boto3.client('ec2')
    document_name = os.environ['DOCUMENT_NAME']

    # Query instances by tags
    response = ec2_client.describe_instances(
        Filters=[
            {'Name': 'tag:application', 'Values': ['octopus']},
            {'Name': 'tag:component', 'Values': ['um']}
        ]
    )

    # Extract instance IDs
    instance_ids = [instance['InstanceId'] for reservation in response['Reservations'] for instance in reservation['Instances']]

    if not instance_ids:
        return {
            'statusCode': 400,
            'body': 'No instances found with the specified tags.'
        }

    # Send SSM command to the instances
    response = ssm_client.send_command(
        InstanceIds=instance_ids,
        DocumentName=document_name
    )

    return {
        'statusCode': 200,
        'body': response
    }