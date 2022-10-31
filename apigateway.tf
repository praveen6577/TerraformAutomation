resource "aws_apigatewayv2_api" "lambda_api" {
  name     = "http-api"
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
  route_key = "GET /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.integrate_lambda.id}"
}

resource "aws_lambda_permission" "api-gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lambda_api.execution_arn}/*/*/*"
}
