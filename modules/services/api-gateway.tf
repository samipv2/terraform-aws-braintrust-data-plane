locals {
  api_basic_method = {
    consumes = ["application/json", "text/plain"]
    produces = ["application/json"]
    responses = {
      "200" = {
        description = "200 response"
        schema      = "$ref: '#/definitions/Empty'"
      }
    }
    x-amazon-apigateway-integration = local.api_gateway_integration_snippet
  }
  api_gateway_integration_snippet = {
    "uri"                 = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/${aws_lambda_function.api_handler.arn}/invocations"
    "type"                = "aws_proxy"
    "httpMethod"          = "POST"
    "contentHandling"     = "CONVERT_TO_TEXT"
    "passthroughBehavior" = "when_no_match"
    "responses" = {
      "default" = {
        "statusCode" = "200"
      }
    }
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name = "${var.deployment_name}-API"

  endpoint_configuration {
    types = ["EDGE"]
  }

  body = jsonecode({
    openapi = "3.0.1"
    info = {
      title   = "${var.deployment_name}-API"
      version = "1.0"
    }
    paths = {
      "/" = {
        get = local.api_basic_method
      }
      "/api/{object_type}" = {
        for method in ["get", "options", "post"] : method => merge(local.api_basic_method, {
          parameters = [
            {
              name     = "object_type"
              in       = "path"
              required = true
              type     = "string"
            }
          ]
        })
      }
      "/api/{object_type}/{action}" = {
        for method in ["get", "options", "post"] : method => merge(local.api_basic_method, {
          parameters = [
            {
              name     = "object_type"
              in       = "path"
              required = true
              type     = "string"
            },
            {
              name     = "action"
              in       = "path"
              required = true
              type     = "string"
            }
          ]
        })
      }
    }
  })
}

# Create API Gateway deployment and stage
resource "aws_api_gateway_deployment" "api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on  = [aws_api_gateway_rest_api.api]
}

resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "api"
}

# Add Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}
