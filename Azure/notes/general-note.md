# General note

### 1. In Azure Portal, Limited to VNet is equal to external_enabled in terraform ingress option
If we also have VNet intergration for container app and want the container app to be published within VNet, remember to add this option in ingress.
```
external_enabled           = ingress.value.external_enabled
```


### 2. If you failed import Secret from KeyVault using User-assign Managed Identity
Take a look to : 
- Where the instance stand inside the Network
- The ACL Rule of Key Vaults that if your instance is allowed at the network espect

It will not tell you directly that it is network issue, the logs are only that you cannot use this Managed Identity to fetch the things.

To resolve:
- Adding service enpoint for Key Vault, where your instance stand.

```hcl
resource "azurerm_subnet" "application_subnet" {
  name                 = local.application_subnet_name
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.application_vnet.name
  address_prefixes     = var.application_subnet_prefixes
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault"] <---------- This one

  delegation {
    name = "container-app-delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}
```
- Modify the subnet to Key Vault ACL Rule.
```

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
    virtual_network_subnet_ids = ["${azurerm_subnet.application_subnet.id}"] <-------- This one
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
      principal_id               = "1191322d-191c-4b6c-bb5f-f1c9b466f9f2"
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
```