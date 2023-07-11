import boto3
import botocore
# import socket
from decimal import Decimal
from custom_encoder import CustomEncoder
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodbTableName = 'cloud-resume-challenge'
resource_db = boto3.resource('dynamodb')

table = resource_db.Table(dynamodbTableName)

SITE_URL = "resume.brettstephen.com"

# def get_client_ip_address(event):
#   # ## getting the hostname by socket.gethostname() method
#   # hostname = socket.gethostname()
#   # ## getting the IP address using socket.gethostbyname() method
#   # ip_address = socket.gethostbyname(hostname)
#   ip_address = event['requestContext']['identity']['sourceIp']
#   return ip_address


def lambda_handler(event, context):
    logging.info(event)
    # print(get_client_ip_address(event))
    try:
        response = update_visit()
        body = {
            'visits': response
        }
        return buildResponse(200, body)

    except botocore.exceptions.ClientError as err:
        logger.error(err.response['Error'])


def buildResponse(statusCode, body=None):
    response = {
        'statusCode': statusCode,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Headers': '*',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'OPTIONS, HEAD, GET'
        }
    }
    if body is not None:
        response['body'] = json.dumps(body, cls=CustomEncoder)
    return response


def update_visit():
    try:
        response = table.update_item(
            Key={
                'siteUrl': SITE_URL
            },
            ExpressionAttributeNames={
                '#v': 'visits'
            },
            ExpressionAttributeValues={
                ':increment': Decimal(1)
            },
            UpdateExpression='SET #v = #v + :increment',
            ReturnValues='UPDATED_NEW'
        )
        return response['Attributes']['visits']

    except botocore.exceptions.ClientError as err:
        logger.error(err.response['Error'])
        raise

#  Scan once to see if any items in table


# def check_if_table_is_empty():
#     try:
#         response = table.scan()

#         return response['Items']
#     except botocore.exceptions.ClientError as err:
#         logger.error(err.response['Error'])
#         raise


# def put_visit():
#     try:
#         table.put_item(
#             Item={
#                 'siteUrl': SITE_URL,
#                 'visits': Decimal(1)
#             }
#         )

#     except botocore.exceptions.ClientError as err:
#         logger.error(err.response['Error'])
#         raise


# def get_visit():
#     try:
#         response = table.get_item(
#             Key={
#                 'siteUrl': SITE_URL
#             }
#         )

#     except botocore.exceptions.ClientError as err:
#         logger.error(err.response['Error'])
#         raise
#     else:
#         return response['Item']['visits']
