# Known after apply Drifted

## Introduction
Description: Value of some core attribute as "(known after apply)" when `plan` or `apply` may cause drifted.

Such as this:

```tf
# Container App Environment

resource "azurerm_container_app_environment" "app_env" {
  name                              = local.container_app_environment_name
  location                          = azurerm_resource_group.main_rg.location
  resource_group_name               = azurerm_resource_group.main_rg.name
  infrastructure_subnet_id          = azurerm_subnet.application_subnet.id <--- This is where cause drifted
  public_network_access             = "Disabled"
  internal_load_balancer_enabled    = true
  # Workload_profile which is default as `Consumption` <--- This is where cause drifted
  
  identity {
    type = "SystemAssigned"
  }

  depends_on = [
    azurerm_subnet.application_subnet,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip,
    azurerm_storage_share.vector,
    azurerm_storage_share.redis
  ]
}

resource "azurerm_container_app_environment_storage" "vector_file_shared" {
  name                         = azurerm_storage_share.vector.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id <--- This is where cause drifted
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.vector.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

}

resource "azurerm_container_app_environment_storage" "redis_file_shared" {
  name                         = azurerm_storage_share.redis.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id <--- This is where cause drifted
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.redis.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}
```

## How is the solution?

Use `life_cycle` block

```tf
# Container App Environment

resource "azurerm_container_app_environment" "app_env" {
  name                              = local.container_app_environment_name
  location                          = azurerm_resource_group.main_rg.location
  resource_group_name               = azurerm_resource_group.main_rg.name
  infrastructure_subnet_id          = azurerm_subnet.application_subnet.id
  public_network_access             = "Disabled"
  internal_load_balancer_enabled    = true
  
  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [infrastructure_resource_group_name, workload_profile] <--- Add this to remove ignore the 'known after apply'
  } 

  depends_on = [
    azurerm_subnet.application_subnet,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip,
    azurerm_storage_share.vector,
    azurerm_storage_share.redis
  ]
}

resource "azurerm_container_app_environment_storage" "vector_file_shared" {
  name                         = azurerm_storage_share.vector.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.vector.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]  <--- Add this to remove ignore the 'known after apply'
  }
}

resource "azurerm_container_app_environment_storage" "redis_file_shared" {
  name                         = azurerm_storage_share.redis.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.redis.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"

  lifecycle {
    ignore_changes = [container_app_environment_id]  <--- Add this to remove ignore the 'known after apply'
  }
}
```