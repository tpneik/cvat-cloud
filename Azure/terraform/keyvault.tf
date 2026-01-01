
data "azurerm_client_config" "current" {}

module "key_vault" {
  location = azurerm_resource_group.main_rg.location
  source             = "Azure/avm-res-keyvault-vault/azurerm"
  name                = local.key_vault_name
  resource_group_name = azurerm_resource_group.main_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  enable_telemetry    = true
  network_acls = {
    bypass   = "AzureServices"
    ip_rules = ["${data.http.ip.response_body}/32"]
    virtual_network_subnet_ids = ["${azurerm_subnet.application_subnet.id}"]
  }
  public_network_access_enabled = true
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = "${data.azurerm_client_config.current.object_id}"
    }
    generic_identity_kv = {
      role_definition_id_or_name = "Key Vault Secrets User"
      principal_id               = "${azurerm_user_assigned_identity.this.principal_id}"
    }
    administrator_from_azure_portal = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = "${var.azure_portal_object_id}"
    }
  }
  secrets = {
    docker_hub_secret = {
      name = "docker-hub-secret"
    }
    generic_password = {
      name = "generic-password"
    }
  }
  secrets_value = {
    docker_hub_secret = "${var.docker_hub_secret}"
    generic_password  = "${var.generic_password}"
  }
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}