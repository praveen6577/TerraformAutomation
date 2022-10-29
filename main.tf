provider "aws" {
  region = "ap-south-1"

}

data "archive_file" "lambdazipfile" {
  type        = "zip"
  source_dir  = "lambda"
  output_path = "lambda.zip"
}


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
  source_code_hash = data.archive_file.lambdazipfile.output_base64sha256
  runtime          = "nodejs12.x"
}

resource "aws_apigatewayv2_api" "lambda_api" {
  name     = "http-api-v2"
  protocol_type  = "HTTP"
}


resource "aws_apigatewayv2_stage" "lambda_api" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  name       = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "integrate_lambda" {
  api_id                = aws_apigatewayv2_api.lambda_api.id
  integration_type      = "AWS_PROXY"
  integration_method    = "POST"
  integration_uri       = aws_lambda_function.lambda.invoke_arn
  passthrough_behavior = "WHEN_NO_MATCH"
}

resource "aws_apigatewayv2_route" "lamda_route" {
  api_id    = aws_apigatewayv2_api.lambda_api.id
  route_key = "GET /{proy+}"
  target    = "integrations/${aws_apigatewayv2_integration.integrate_lambda.id}"
}

resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*/*"
}
