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

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.main,
    azurerm_subnet.application_subnet,
    azurerm_storage_account_network_rules.storage_account_network_rules,
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
}

resource "azurerm_container_app_environment_storage" "redis_file_shared" {
  name                         = azurerm_storage_share.redis.name
  container_app_environment_id = azurerm_container_app_environment.app_env.id
  account_name                 = azurerm_storage_account.main.name
  share_name                   = azurerm_storage_share.redis.name
  access_key                   = azurerm_storage_account.main.primary_access_key
  access_mode                  = "ReadWrite"
}