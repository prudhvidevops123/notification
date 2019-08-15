# notification
Terraaform code to send email through ses and sms from lambda function. It will create s3 bucket , when we upload notification.txt in s3 bucket it will trigger lambda function to send email and sms. For sending mail and sms it will read details from notification.txt and pass to email_to ,  PhoneNumber and message.
