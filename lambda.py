import json

def lambda_handler(event,context):
    print("demo testing")
    return{
        'statusCode': 200,
        'body' : json.dumps('Hello world from Avinash')
    }