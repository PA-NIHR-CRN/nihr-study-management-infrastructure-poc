variable "env" {
  description = "environment name"
  type        = string
}

variable "system" {
  type = string
}

variable "account" {
  description = "account name"
  type        = string
  default     = "nihrd"
}

variable "memory_size" {
  type = string
}

variable "private_subnet_ids" {

}

variable "retention_in_days" {

}

variable "enabled_provision_config" {
  description = "Change to false to avoid deploying any resources"
  type        = bool
  default     = true
}

variable "vpc_id" {

}
variable "cognito_identifier" {

}

variable "rds_cluster_endpoint" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "rds_password_secret_name"{
  type = string
}

