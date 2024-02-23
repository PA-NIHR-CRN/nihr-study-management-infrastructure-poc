variable "account" {
  default = "nihrd"
}

variable "system" {
  default = "nsip"

}

variable "env" {
  default = "dev"

}

variable "app" {

}

variable "vpc_id" {

}

variable "engine" {

}

variable "engine_version" {

}


variable "instance_class" {

}

variable "username" {

}


variable "backup_retention_period" {

}

variable "maintenance_window" {

}

variable "grant_odp_db_access" {
  default = true
}

variable "az_zones" {
  type = list(any)

}

variable "db_name" {

}

variable "instance_count" {

}

variable "max_capacity" {

}

variable "min_capacity" {

}

variable "skip_final_snapshot" {

}

variable "publicly_accessible" {

}

variable "log_types" {
  type = list(string)

}

variable "add_scheduler_tag" {

}

variable "subnet_group" {

}

variable "lambda_sg" {

}

# variable "capacity" {
#   default = null

#   type = object({
#     min_capacity = number
#     max_capacity = number
#   })
# }

variable "odp_db_server_ip" {
}

variable "ingress_rules" {
  description = "List of ingress rules with IP and description"
  type = list(object({
    ip          = string
    description = string
  }))
}

variable "iam_database_authentication_enabled" {
  type        = bool
  default     = true
  description = "Specify if mapping AWS IAM accounts to database accounts is enabled."
}

variable "iam_roles" {
  type        = list(string)
  default     = null
  description = "A list of IAM Role ARNs to associate with the cluster"
}

variable "delete_automated_backups" {
  type        = bool
  default     = true
  description = "Specifies whether to remove automated backups immediately after the DB cluster is deleted."
}
