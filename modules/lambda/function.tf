resource "aws_security_group" "sg_lambda" {
  name        = "${var.account}-sg-lambda-${var.env}-${var.system}"
  description = "lambda security group"
  vpc_id      = var.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.account}-sg-lambda-${var.env}-${var.system}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lambda_function" "study_management_lamnbda" {
  function_name = "${var.account}-lambda-${var.env}-${var.system}"
  memory_size   = var.memory_size
  timeout       = 30
  handler       = "NIHR.StudyManagement.Api::NIHR.StudyManagement.Api.LambdaEntryPoint::FunctionHandlerAsync"
  publish       = true # don't need this if updating code outside of terrafrom
  filename      = "./modules/.build/lambda_dummy/lambda_dummy.zip"
  role          = aws_iam_role.lambda.arn
  runtime       = "dotnet7"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.sg_lambda.id]
  }

  environment {
    variables = {
      "StudyManagementApiConfiguration__JwtTokenValidationConfiguration__OverrideJwtTokenValidation" = "false"
    }
  }

  lifecycle {
    ignore_changes = [
      version,
      qualified_arn,
      memory_size,
      timeout,
      environment
    ]
  }
  tags = {
    Name        = "${var.account}-lambda-${var.env}-${var.system}"
    Environment = var.env
    System      = var.system
  }
}

resource "aws_lambda_alias" "study_management" {
  name             = "main"
  function_name    = aws_lambda_function.study_management_lamnbda.function_name
  function_version = aws_lambda_function.study_management_lamnbda.version
}


resource "aws_lambda_provisioned_concurrency_config" "study" {
  count                             = var.enabled_provision_config ? 1 : 0
  function_name                     = aws_lambda_function.study_management_lamnbda.function_name
  provisioned_concurrent_executions = 2
  qualifier                         = aws_lambda_alias.study_management.name
}

# lambda logging
resource "aws_cloudwatch_log_group" "study" {
  name              = "/aws/lambda/${aws_lambda_function.study_management_lambda.function_name}"
  retention_in_days = var.retention_in_days
  tags = {
    Name        = "${var.account}-lambda-${var.env}-${var.system}"
    Environment = var.env
    System      = var.system
  }
}

output "lambda_sg" {
  value = aws_security_group.sg_lambda.id
}

output "study_management_invoke_alias_arn" {
  value = aws_lambda_alias.study_management.invoke_arn
}