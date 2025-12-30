

resource "azurerm_postgresql_flexible_server" "cvat_db" {
  name                          = "cvat-db-1"
  resource_group_name           = azurerm_resource_group.main_rg.name
  location                      = azurerm_resource_group.main_rg.location
  version                       = "17"
#   delegated_subnet_id           = azurerm_subnet.private_endpoint_subnet.id
#   private_dns_zone_id           = azurerm_private_dns_zone.main.id
  public_network_access_enabled = false
  administrator_login           = "cvatAdmin"
  administrator_password        = "h7!P$9kR@2vX*5mQ#8tZ"
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P10"

  sku_name   = "B_Standard_B1ms"
}

resource "azurerm_private_endpoint" "postgresql_pe" {
    name                =  "cvat-db-pe"
    location            = azurerm_resource_group.main_rg.location
    resource_group_name = azurerm_resource_group.main_rg.name
    subnet_id           = azurerm_subnet.private_endpoint_subnet.id
    custom_network_interface_name  = "cvat-db-pe-nic"

    private_service_connection {
        name                           = "cvat-db-pe-connection"
        private_connection_resource_id = azurerm_postgresql_flexible_server.cvat_db.id
        is_manual_connection           = false
        subresource_names              = ["postgresqlServer"]
    }
    ip_configuration {
        name                   = "${var.client_name}-${var.application_name}-postgresql-ip-name"
        private_ip_address     = "10.28.16.8"
        subresource_name        = "postgresqlServer"
    }
}

resource "azurerm_postgresql_flexible_server_database" "cvat_database" {
  name      = "cvat"
  server_id = azurerm_postgresql_flexible_server.cvat_db.id
  collation = "en_US.utf8"
  charset   = "UTF8"

}