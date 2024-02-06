module "aws_cognito_user_pool" {

  source = "./source"

  user_pool_name = "${var.account}-cognito-${var.env}-${var.userpool}-userpool"

  username_configuration = {
    case_sensitive = false
  }

  password_policy = {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7

  }
  # resource servers

  resource_servers = [
    {
      name       = "${var.account}-cognito-${var.env}-${var.system}-resource-server"
      identifier = "${var.account}-cognito-${var.env}-${var.system}-resource-server"
      scope = [{
        scope_name        = "todo.read"
        scope_description = "Read todo list"
        }
      ]
    }
  ]

  # user_pool_domain
  # domain = var.domain-name

  # clients
  clients = [
    {
      allowed_oauth_flows                  = ["client_credentials"]
      allowed_oauth_flows_user_pool_client = true
      prevent_user_existence_errors        = "ENABLED"
      generate_secret = true
      allowed_oauth_scopes = [
        "${module.aws_cognito_user_pool.aws_cognito_resource_server.resource[0].scope_identifiers}"
      ]
      explicit_auth_flows = [
        "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"
      ]
      name                         = "${var.account}-cognito-${var.env}-${var.system}-${var.client_name}-client"
      supported_identity_providers = ["COGNITO"]
      refresh_token_validity       = 30
      access_token_validity        = 60
      id_token_validity            = 60
      token_validity_units = {
        access_token  = "minutes"
        id_token      = "minutes"
        refresh_token = "days"
      }
      write_attributes = [
        "address",
        "birthdate",
        # "custom:access_token",
        # "custom:id_token",
        "email",
        "family_name",
        "gender",
        "given_name",
        "locale",
        "middle_name",
        "name",
        "nickname",
        "phone_number",
        "picture",
        "preferred_username",
        "profile",
        "updated_at",
        "website",
        "zoneinfo"
      ]
      read_attributes = [
        "address",
        "birthdate",
        # "custom:access_token",
        # "custom:id_token",
        "email",
        "email_verified",
        "family_name",
        "gender",
        "given_name",
        "locale",
        "middle_name",
        "name",
        "nickname",
        "phone_number",
        "phone_number_verified",
        "picture",
        "preferred_username",
        "profile",
        "updated_at",
        "website",
        "zoneinfo"
      ]
    }
  ]

  # user_group

  # identity_providers
  # identity_providers = [
  #   {
  #     provider_name = var.provider-name
  #     provider_type = "OIDC"

  #     attribute_mapping = {
  #       email    = "sub"
  #       username = "sub"
  #     }
  #   }
  # ]

  # tags
  tags = {
    Environment = var.env
    Name        = "${var.account}-cognito-${var.env}-${var.userpool}-userpool"
    System      = var.system
  }
}
