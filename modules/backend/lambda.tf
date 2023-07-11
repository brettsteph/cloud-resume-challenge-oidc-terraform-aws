# Lambda Function
resource "aws_lambda_function" "put-visits" {
  filename = data.archive_file.lambda_functions.output_path

  function_name = "put_function"

  role = aws_iam_role.lambda_role.arn

  memory_size = 128
  runtime     = "python3.9"
  handler     = "put_function.lambda_handler"

  # Optional, used to trigger updates
  source_code_hash = filebase64sha256(data.archive_file.lambda_functions.output_path)

  depends_on = [
    aws_iam_role_policy_attachment.lambda-attachment
  ]
}

############################################################
# Give API Gateway permission to invoke your Lambda function
############################################################
resource "aws_lambda_permission" "apigw-lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put-visits.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"

}

