resource "aws_iam_role" "lambda_notification_role" {
  name = "lambda_notification_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "s3_full_access" {
  name        = "s3_full_access"
  description = "Policy to get permision on S3"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "ses_full_access" {
  name        = "ses_full_access"
  description = "Policy to get permision on SES"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ses:*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "sns_full_access" {
  name        = "sns_full_access"
  description = "Policy to get permision on SNS"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sns:*"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_policy" "cw_full_access" {
  name        = "cw_full_access"
  description = "Policy to get permision on cloudwatch"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "autoscaling:Describe*",
                "cloudwatch:*",
                "logs:*",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "events.amazonaws.com"
                }
            }
        }
    ]
}
EOF
}


resource "aws_iam_policy" "lambda_full_access" {
  name        = "lambda_full_access"
  description = "Policy to get permision on lambda"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudformation:DescribeChangeSet",
                "cloudformation:DescribeStackResources",
                "cloudformation:DescribeStacks",
                "cloudformation:GetTemplate",
                "cloudformation:ListStackResources",
                "cloudwatch:*",
                "cognito-identity:ListIdentityPools",
                "cognito-sync:GetCognitoEvents",
                "cognito-sync:SetCognitoEvents",
                "dynamodb:*",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "events:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:ListRoles",
                "iam:PassRole",
                "iot:AttachPrincipalPolicy",
                "iot:AttachThingPrincipal",
                "iot:CreateKeysAndCertificate",
                "iot:CreatePolicy",
                "iot:CreateThing",
                "iot:CreateTopicRule",
                "iot:DescribeEndpoint",
                "iot:GetTopicRule",
                "iot:ListPolicies",
                "iot:ListThings",
                "iot:ListTopicRules",
                "iot:ReplaceTopicRule",
                "kinesis:DescribeStream",
                "kinesis:ListStreams",
                "kinesis:PutRecord",
                "kms:ListAliases",
                "lambda:*",
                "logs:*",
                "s3:*",
                "sns:ListSubscriptions",
                "sns:ListSubscriptionsByTopic",
                "sns:ListTopics",
                "sns:Publish",
                "sns:Subscribe",
                "sns:Unsubscribe",
                "sqs:ListQueues",
                "sqs:SendMessage",
                "tag:GetResources",
                "xray:PutTelemetryRecords",
                "xray:PutTraceSegments"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = "${aws_iam_role.lambda_notification_role.name}"
  policy_arn = "${aws_iam_policy.s3_full_access.arn}"
}

resource "aws_iam_role_policy_attachment" "ses_attach" {
  role       = "${aws_iam_role.lambda_notification_role.name}"
  policy_arn = "${aws_iam_policy.ses_full_access.arn}"
}

resource "aws_iam_role_policy_attachment" "sns_attach" {
  role       = "${aws_iam_role.lambda_notification_role.name}"
  policy_arn = "${aws_iam_policy.sns_full_access.arn}"
}

resource "aws_iam_role_policy_attachment" "cw_attach" {
  role       = "${aws_iam_role.lambda_notification_role.name}"
  policy_arn = "${aws_iam_policy.cw_full_access.arn}"
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = "${aws_iam_role.lambda_notification_role.name}"
  policy_arn = "${aws_iam_policy.lambda_full_access.arn}"
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda_function.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}



resource "aws_lambda_function" "lambda_function" {
  filename      = "${var.zip_name}"
  function_name = "lambda_function"
  role          = "${aws_iam_role.lambda_notification_role.arn}"
  handler       = "${var.handler}"
  runtime       = "${var.python_runtime}"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "prudhvi-notification"
}



resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.lambda_function.arn}"
    events              = ["s3:ObjectCreated:*"]
  }
}