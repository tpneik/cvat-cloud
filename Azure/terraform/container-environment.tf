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
}