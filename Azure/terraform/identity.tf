resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.main_rg.location
  name                = "generic-identity"
  resource_group_name = azurerm_resource_group.main_rg.name
}