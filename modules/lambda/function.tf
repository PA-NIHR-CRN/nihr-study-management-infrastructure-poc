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

resource "aws_lambda_function" "study_management_lambda" {
  function_name = "${var.account}-lambda-${var.env}-${var.system}"
  memory_size   = var.memory_size
  timeout       = 60
  handler       = "NIHR.StudyManagement.Api::NIHR.StudyManagement.Api.LambdaEntryPoint::FunctionHandlerAsync"
  publish       = true # don't need this if updating code outside of terrafrom
  filename      = "./modules/.build/lambda_dummy/lambda_dummy.zip"
  role          = aws_iam_role.lambda.arn
  runtime       = "dotnet6"

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.sg_lambda.id]
  }

  environment {
    variables = {
      "StudyManagementApi__JwtBearer__Authority"     = "https://${var.cognito_identifier}",
      "StudyManagementApi__Data__ConnectionString"   = "server=${var.rds_cluster_endpoint};database=${var.db_name};user=${var.db_username}",
      "StudyManagementApi__Data__PasswordSecretName" = var.rds_password_secret_name,
      "StudyManagement__DefaultRoleName"             = "CHIEF_INVESTIGATOR",
      "StudyManagement__DefaultLocalSystemName"      = "EDGE"

    }
  }

  lifecycle {
    ignore_changes = [
      version,
      qualified_arn,
      memory_size,
      # environment
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
  function_name    = aws_lambda_function.study_management_lambda.function_name
  function_version = aws_lambda_function.study_management_lambda.version
}


# resource "aws_lambda_provisioned_concurrency_config" "study" {
#   count                             = var.enabled_provision_config ? 1 : 0
#   function_name                     = aws_lambda_function.study_management_lambda.function_name
#   provisioned_concurrent_executions = 2
#   qualifier                         = aws_lambda_alias.study_management.name
# }

# lambda logging
resource "aws_cloudwatch_log_group" "study_management_log_group" {
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

output "function_name" {
  value = aws_lambda_function.study_management_lambda.function_name
}

output "alias_name" {
  value = aws_lambda_alias.study_management.name
}