provider "aws" {
  region                  = "eu-central-1"
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "default"
}

data "archive_file" "echo_program" {
  type = "zip"
  source_file  = "${path.module}//target/x86_64-unknown-linux-musl/release/bootstrap"
  output_path = "${path.module}/bootstrap.zip"
}

resource "aws_lambda_function" "echo" {
  filename      = data.archive_file.echo_program.output_path
  function_name = "rust_hello"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "bootstrap"

  source_code_hash = filebase64sha256(data.archive_file.echo_program.output_path)

  runtime = "provided.al2"

}

resource "aws_apigatewayv2_api" "lambda" {
  name          = "my_gateway"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda" {
  api_id = aws_apigatewayv2_api.lambda.id

  name        = "serverless_lambda_stage"
  auto_deploy = true

  // CloudWatch logging
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }

}

resource "aws_apigatewayv2_integration" "echo" {
  api_id = aws_apigatewayv2_api.lambda.id

  integration_uri    = aws_lambda_function.echo.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "echo" {
  api_id = aws_apigatewayv2_api.lambda.id

  route_key = "POST /echo" // Use access path
  target    = "integrations/${aws_apigatewayv2_integration.echo.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.echo.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.lambda.execution_arn}/*/*"
}

/// output files
output "base_url" {
  description = "Base URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda.invoke_url
}

// CloudWatch Logging
resource "aws_cloudwatch_log_group" "echo" {
  name = "/aws/lambda/${aws_lambda_function.echo.function_name}"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "api_gw" {
  name = "/aws/api_gw/${aws_apigatewayv2_api.lambda.name}"
  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
