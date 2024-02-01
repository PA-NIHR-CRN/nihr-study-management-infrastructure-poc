resource "aws_iam_role" "api_gateway_role" {
  name = "${var.account}-iam-${var.env}-${var.system}-api-gateway-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["apigateway.amazonaws.com", "events.amazonaws.com", "lambda.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags = {
    Name        = "${var.account}-iam-${var.env}-${var.system}-api-gateway-role",
    Environment = var.env,
    System      = var.system
  }
}

resource "aws_api_gateway_account" "iam_apigateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_role.arn
  lifecycle {
    ignore_changes = [
      cloudwatch_role_arn
    ]
  }
}

resource "aws_iam_role_policy" "apigateway-role-policy" {
  name = "${var.account}-iam-${var.env}-${var.system}-api-gateway-role-policy"
  role = aws_iam_role.api_gateway_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Action" : [
          "events:PutRule",
          "events:ListRules",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "sqs:SendMessage"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_api_gateway_rest_api" "main" {
  name        = "${var.account}-api-gateway-${var.env}-${var.system}"
  description = "${var.system} API Gateway."

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  tags = {
    Name        = "${var.account}-api-gateway-${var.env}-${var.system}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_api_gateway_resource" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "main" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.main.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = false
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  # method that the api gateway will use to call the lambda - lambdas can only be invoked by POST, even though the gateway method may be a GET
  type                    = "AWS_PROXY"
  uri                     = var.invoke_lambda_arn
  integration_http_method = "POST"
}


resource "aws_api_gateway_method_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  resource_id = aws_api_gateway_resource.main.id
  http_method = aws_api_gateway_method.main.http_method
  status_code = aws_api_gateway_method_response.main.status_code

  response_templates = {
    "application/json" = ""
  }
}

resource "aws_api_gateway_deployment" "main" {
  depends_on  = [aws_api_gateway_integration.main]
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = var.env
}