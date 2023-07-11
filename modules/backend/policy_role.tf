# Roles
# A Lambda function needs to access AWS resources DynamoDB.
# IAM
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "lambda_role" {
  name               = "myrole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "dynamodb-lambda-policy" {
  name = "lambda_dynamodb_policy_challenge"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Action : [
          # "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          # "dynamodb:Scan",
          # "dynamodb:Query",
          # "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          # "dynamodb:DeleteItem"
        ],
        "Resource" : "${aws_dynamodb_table.table.arn}"
      }
    ]
  })
}


resource "aws_iam_policy" "iam-policy-for-lambda" {
  name        = "aws_iam_policy_for_aws_lambda_challenge"
  path        = "/"
  description = "AWS IAM Policy for managing aws lambda role"
  policy      = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
    "Resource": "*",
     "Effect": "Allow"
   }
 ]
}
EOF
}
# arn:aws:logs:*:*:*
# 
resource "aws_iam_role_policy_attachment" "lambda-attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.iam-policy-for-lambda.arn
}



