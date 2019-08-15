#!/usr/bin/env python3
import boto3

def lambda_handler(event, context):
    
    # Initialize SNS client
    
    Bucket = 'prudhvi-notification'
    s3_client=boto3.resource('s3')
    bucket = s3_client.Bucket(Bucket)
    var = []
    objs = bucket.objects.filter(Prefix='notification')
    for obj in objs:
        contents=obj.get()['Body'].read().decode(encoding="utf-8",errors="ignore")
    for line in contents.splitlines():
        var.append(line)
    email_to, phone, message = [var[i] for i in (0, 1, 2)]
    send_email(email_to, message)
    send_phone_message(phone, message)
    
def send_email(email_to, message):
    # Initialize SNS client
    ses = boto3.client('ses')
    email_from = 'msdevops2017@gmail.com'
    emaiL_subject = 'AWS Notification from Lambda'
    # Send email
    response = ses.send_email(
        Source = email_from,
        Destination={
            'ToAddresses': [
                email_to,
            ]
        },
        Message={
            'Subject': {
                'Data': emaiL_subject
            },
            'Body': {
                'Text': {
                    'Data': message
                }
            }
        }
    )
    print (response)

def send_phone_message(phone, message):
   # Initialize SNS client
   session = boto3.Session(
   region_name="us-east-1"
   )
   sns_client = session.client('sns')
   # Send message to Phone
   response = sns_client.publish(
        PhoneNumber=phone,
        Message=message,
        MessageAttributes={
            'AWS.SNS.SMS.SMSType': {
                'DataType': 'String',
                'StringValue': 'Transactional'
            }
        }
    )
   print (response)
