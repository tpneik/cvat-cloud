


resource "azurerm_resource_group" "this" {
  location = "southeastasia"
  name     = local.resource_group_name
}

data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}

data "azurerm_client_config" "current" {}

module "random_password" {
  source = "./modules/random_password"

  length           = 20
  lower            = true
  upper            = true
  min_lower        = 4
  min_upper        = 2
  min_numeric      = 3
  min_special      = 3
  numeric          = true
  special          = true
}





# module "key_vault" {

#   location                  = azurerm_resource_group.this.location
#   source                    = "Azure/avm-res-keyvault-vault/azurerm"
#   name                      = local.key_vault_name
#   version                   = "0.10.2"
#   resource_group_name       = azurerm_resource_group.this.name
#   tenant_id                 = data.azurerm_client_config.current.tenant_id
#   enable_telemetry          = true
#   sku_name                  = "standard"

#   secrets = {
#     postgre-secret ={
#       name = "postgre-secret"
#     }
#   }
#   secrets_value = {
#     postgre-secret = module.random_password.result
#   }

#   network_acls = {
#     bypass   = "AzureServices"
#     ip_rules = ["${data.http.ip.response_body}/32"]
#   }
#   public_network_access_enabled = true
#   role_assignments = {
#     deployment_user_kv_admin = {
#       role_definition_id_or_name = "Key Vault Administrator"
#       principal_id               = data.azurerm_client_config.current.object_id
#     },
#     deployment_admin_user_kv_admin = {
#       role_definition_id_or_name = "Key Vault Administrator"
#       principal_id               = "1191322d-191c-4b6c-bb5f-f1c9b466f9f2"
#     }
#   }
#   wait_for_rbac_before_key_operations = {
#     create = "60s"
#   }
# }