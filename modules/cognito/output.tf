output "cognito_arn" {
  value = module.aws_cognito_user_pool.arn
}
output "pool_id" {
  value = module.aws_cognito_user_pool.id
}
output "client_id" {
  value = module.aws_cognito_user_pool.client_ids[0]
}
