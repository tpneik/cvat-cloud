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

resource "azurerm_private_dns_a_record" "cvat-ui-app" {
  name                = "cvat-ui"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main_rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.app_env.static_ip_address]

  depends_on = [ 
    azurerm_container_app_environment.app_env,
    azurerm_private_dns_zone.main
  ]
}

resource "azurerm_private_dns_a_record" "cvat-server-app" {
  name                = "cvat-server"
  zone_name           = azurerm_private_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main_rg.name
  ttl                 = 300
  records             = [azurerm_container_app_environment.app_env.static_ip_address]

  depends_on = [ 
    azurerm_container_app_environment.app_env,
    azurerm_private_dns_zone.main
  ]
}
