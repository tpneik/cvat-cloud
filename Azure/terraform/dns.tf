resource "azurerm_private_dns_zone" "main" {
  name                = local.private_dns_zone_name
  resource_group_name = azurerm_resource_group.main_rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  name                  = "dnszone-vnet-link-to-${local.virtual_network_name}"
  resource_group_name   = azurerm_resource_group.main_rg.name
  private_dns_zone_name = azurerm_private_dns_zone.main.name
  virtual_network_id    = azurerm_virtual_network.application_vnet.id
  registration_enabled  = true
}

