resource "azurerm_resource_group" "main_rg" {
  name     = local.resource_group_name
  location = var.location
}