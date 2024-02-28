variable "names" {
  default = {
    "retention_in_days" = "30"
    "proj"              = "nihr"
    "system"            = "study-management"
    "app"               = "study-management"

    "dev" = {
      "accountidentifiers"          = "nihrd"
      "environment"                 = "dev"
      "app"                         = "study-management"
      "backupretentionperiod"       = 7
      "engine"                      = "mysql"
      "engine_version"              = "8.0.mysql_aurora.3.02.2"
      "instanceclass"               = "db.serverless"
      "skip_final_snapshot"         = true
      "private_subnet_ids"          = ["subnet-036934130e6e171db", "subnet-08301b8a8d127a1e5", "subnet-04c549421f430d61f"] #private subnets
      "vpcid"                       = "vpc-05a9b4ad1477b9b86"
      "maintenancewindow"           = "Sat:04:00-Sat:05:00"
      "storageencrypted"            = true
      "grant_odp_db_access"         = false
      "rds_instance_count"          = "1"
      "az_zones"                    = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
      "min_capacity"                = 0.5
      "max_capacity"                = 1
      "log_types"                   = ["error", "general", "slowquery", "audit"]
      "publicly_accessible"         = true
      "add_scheduler_tag"           = true
      "whitelist_ips"               = ["0.0.0.0/0"]
      "rds_max_connections"         = "50"
      "lambda_memory"               = 256
      "retention_period"            = 30
      "provider-name"               = "ORCID"
      "db_name"                     = "study_management"
      "rds_password_secret_name"    = "nihrd-secret-dev-rds-aurora-mysql-study-management-admin-password"
    }
  }
}