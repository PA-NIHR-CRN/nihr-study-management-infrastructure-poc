terraform {
  backend "s3" {
    region  = "eu-west-2"
    encrypt = true
  }

}

data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
}

## CLOUDWATCH ALARMS

data "aws_sns_topic" "system_alerts" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts"
}

data "aws_sns_topic" "system_alerts_oat" {
  count = var.env == "oat" ? 1 : 0
  name  = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts-oat"
}

data "aws_sns_topic" "system_alerts_service_desk" {
  count = var.env == "prod" ? 1 : 0
  name  = "${var.names["${var.env}"]["accountidentifiers"]}-sns-system-alerts-service-desk"
}

module "api_gateway" {
  source            = "./modules/api-gateway"
  account           = var.names["${var.env}"]["accountidentifiers"]
  env               = var.env
  system            = var.names["system"]
  invoke_lambda_arn = module.lambda.study_management_invoke_alias_arn

}

module "lambda" {
  source             = "./modules/lambda"
  account            = var.names["${var.env}"]["accountidentifiers"]
  env                = var.env
  system             = var.names["system"]
  memory_size        = var.names["${var.env}"]["lambda_memory"]
  private_subnet_ids = var.names["${var.env}"]["private_subnet_ids"]
  retention_in_days  = var.names["${var.env}"]["retention_period"]
  vpc_id             = var.names["${var.env}"]["vpcid"]

}


module "cloudwatch_alarms" {
  source                 = "./modules/cloudwatch_alarms"
  account                = var.names["${var.env}"]["accountidentifiers"]
  env                    = var.env
  system                 = var.names["system"]
  app                    = var.names["${var.env}"]["app"]
  sns_topic              = var.env == "oat" ? data.aws_sns_topic.system_alerts_oat[0].arn : data.aws_sns_topic.system_alerts.arn
  cluster_instances      = module.rds_aurora.db_instances
  sns_topic_service_desk = var.env == "prod" ? data.aws_sns_topic.system_alerts_service_desk[0].arn : ""
  rds_max_connections    = var.names["${var.env}"]["rds_max_connections"]
}

data "aws_secretsmanager_secret" "terraform_secret" {
  name = "${var.names["${var.env}"]["accountidentifiers"]}-secret-${var.env}-${var.names["system"]}-terraform"
}

data "aws_secretsmanager_secret_version" "terraform_secret_version" {
  secret_id = data.aws_secretsmanager_secret.terraform_secret.id
}

## RDS DB
module "rds_aurora" {
  source                  = "./modules/auroradb"
  account                 = var.names["${var.env}"]["accountidentifiers"]
  env                     = var.env
  system                  = var.names["system"]
  app                     = var.names["${var.env}"]["app"]
  vpc_id                  = var.names["${var.env}"]["vpcid"]
  engine                  = var.names["${var.env}"]["engine"]
  engine_version          = var.names["${var.env}"]["engine_version"]
  instance_class          = var.names["${var.env}"]["instanceclass"]
  backup_retention_period = var.names["${var.env}"]["backupretentionperiod"]
  maintenance_window      = var.names["${var.env}"]["maintenancewindow"]
  grant_odp_db_access     = var.names["${var.env}"]["grant_odp_db_access"]
  subnet_group            = "${var.names["${var.env}"]["accountidentifiers"]}-rds-sng-${var.env}-public"
  db_name                 = "study_management"
  username                = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["db-username"]
  instance_count          = var.names["${var.env}"]["rds_instance_count"]
  az_zones                = var.names["${var.env}"]["az_zones"]
  min_capacity            = var.names["${var.env}"]["min_capacity"]
  max_capacity            = var.names["${var.env}"]["max_capacity"]
  skip_final_snapshot     = var.names["${var.env}"]["skip_final_snapshot"]
  log_types               = var.names["${var.env}"]["log_types"]
  publicly_accessible     = var.names["${var.env}"]["publicly_accessible"]
  add_scheduler_tag       = var.names["${var.env}"]["add_scheduler_tag"]
  lambda_sg               = module.lambda.lambda_sg
  odp_db_server_ip        = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["odp-db-server-ip"]
  ingress_rules           = jsondecode(data.aws_secretsmanager_secret_version.terraform_secret_version.secret_string)["ingress_rules"]
}

module "cognito" {
  source        = "./modules/cognito"
  env           = var.env
  system        = var.names["system"]
  account       = var.names["${var.env}"]["accountidentifiers"]
  provider-name = "ORCID"
}