resource "aws_iam_role" "iam-lambda" {
  name               = "iam-lambda"
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

resource "aws_lambda_function" "lambda" {
  filename         = "lambda.zip"
  function_name    = "lambda"
  role             = aws_iam_role.iam-lambda.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
}

