import boto3

def lambda_handler(event, context):
    # Your Lambda function logic here
    print("Lambda function triggered")
    return {
        'statusCode': 200,
        'body': 'Lambda executed successfully'
    }