
# API Gateway
###################################################
# Defines a name for the API Gateway and sets its protocol to HTTP
####################################################
resource "aws_api_gateway_rest_api" "api" {
  name        = "serverless_cloud_challenge_gw"
  description = "API for site visits"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}
# 
resource "aws_api_gateway_resource" "api-resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "visits"
}
#########################################################
# Maps an HTTP GET request to a target, Lambda function
#########################################################
resource "aws_api_gateway_method" "api-get-method" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.api-resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = false

  lifecycle {
    create_before_destroy = true //recommended
  }
}

########################################################
# Configure the API Gateway to use your Lambda function - each method has an integration
########################################################
resource "aws_api_gateway_integration" "api-get-method-integration" {
  http_method             = aws_api_gateway_method.api-get-method.http_method
  resource_id             = aws_api_gateway_resource.api-resource.id
  rest_api_id             = aws_api_gateway_rest_api.api.id
  type                    = "AWS_PROXY"
  integration_http_method = "POST"

  uri = aws_lambda_function.put-visits.invoke_arn

  depends_on = [
    aws_api_gateway_method.api-get-method,
    aws_lambda_function.put-visits
  ]

}

resource "aws_api_gateway_method_response" "api-get-method-response-200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api-resource.id
  http_method = aws_api_gateway_method.api-get-method.http_method
  status_code = "200"

  # response_models = {
  #   "application/json" = "Empty"
  # }

  # response_parameters = {
  #   "method.response.header.Access-Control-Allow-Origin"      = true
  #   "method.response.header.Access-Control-Allow-Headers"     = false
  #   "method.response.header.Access-Control-Allow-Methods"     = true
  #   "method.response.header.Access-Control-Allow-Credentials" = false
  # }
  depends_on = [
    aws_api_gateway_method.api-get-method
  ]
}
# 
resource "aws_api_gateway_integration_response" "api-get-integration-response-200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api-resource.id
  http_method = aws_api_gateway_method.api-get-method.http_method
  status_code = aws_api_gateway_method_response.api-get-method-response-200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/xml" = <<EOF
#set($inputRoot = $input.path('$'))
<?xml version="1.0" encoding="UTF-8"?>
<message>
    $inputRoot.body
</message>
EOF
  }

  depends_on = [
    aws_api_gateway_integration.api-get-method-integration
  ]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name
}

########################################################
# Create an API Gateway "deployment" in order to activate 
# the configuration and expose the API at a URL
########################################################
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  # stage_name = aws_api_gateway_stage.stage.stage_name

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.api.body
    ]))
  }

  depends_on = [
    aws_api_gateway_integration.api-get-method-integration,
    aws_api_gateway_integration.cors-integration
  ]

  lifecycle {
    create_before_destroy = true //recommended
  }
}

# API Gateway CORS

# ###########################################################
# # Maps an HTTP OPTIONS request to a target, Lambda function
# ###############################{proxy+}####################
resource "aws_api_gateway_method" "cors-method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api-resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# Cors integration
resource "aws_api_gateway_integration" "cors-integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api-resource.id
  http_method = aws_api_gateway_method.cors-method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }

  depends_on = [
    aws_api_gateway_method.cors-method
  ]
}

resource "aws_api_gateway_integration_response" "cors-integration-response" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api-resource.id
  http_method = aws_api_gateway_method.cors-method.http_method
  status_code = aws_api_gateway_method_response.cors-method-200.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS, PUT'"
  }
  depends_on = [
    aws_api_gateway_integration.cors-integration
  ]
}


# ########################################################################
# Provides an HTTP Method Integration Response for an API Gateway Resource
# ########################################################################
resource "aws_api_gateway_method_response" "cors-method-200" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.api-resource.id
  http_method = aws_api_gateway_method.cors-method.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"      = true
    "method.response.header.Access-Control-Allow-Headers"     = true
    "method.response.header.Access-Control-Allow-Methods"     = true
    "method.response.header.Access-Control-Allow-Credentials" = true
  }

  depends_on = [
    aws_api_gateway_method.cors-method
  ]
}


# #######################
# # Create an api doamin
# #######################
# Regional (ACM Certificate)
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.${var.domain}"
  regional_certificate_arn = var.aws_acm_cert

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  lifecycle {
    create_before_destroy = true //recommended
  }

  depends_on = [
    var.aws_acm_cert
  ]
}
# Create API Mapping
resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name

}

