# notification
Terraaform code to send email through ses and sms from lambda function. It will create s3 bucket , when we upload notification.txt in s3 bucket it will trigger lambda function to send email and sms. For sending mail and sms it will read details from notification.txt and pass to email_to ,  PhoneNumber and message.

Prereq for running terraform code:

1) Python
2) Pip
3) Aws cli
4) terraform

Steps for running terraform.

1) Run "aws configure" and give detials of access key and access key id with default region.
2) Run "terraform init'
3) Run "terraform plan"
4) Run "terraform apply"
