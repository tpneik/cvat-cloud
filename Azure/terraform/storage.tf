resource "azurerm_storage_account" "main" {
  name                              = local.storage_account_name
  resource_group_name               = azurerm_resource_group.main_rg.name
  location                          = azurerm_resource_group.main_rg.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  public_network_access_enabled     = false

}

resource "azurerm_storage_account_network_rules" "storage_account_network_rules" {
  storage_account_id = azurerm_storage_account.main.id

  default_action             = "Allow"
  virtual_network_subnet_ids = [azurerm_subnet.application_subnet.id, azurerm_subnet.vm_test_subnet.id]
  # virtual_network_subnet_ids = [azurerm_subnet.application_subnet.id]
#   virtual_network_subnet_ids = [azurerm_subnet.vm_test_subnet.id]
  bypass                     = ["AzureServices"]
}

resource "azurerm_storage_share" "vector" {
  name               = "cvat-vector-component"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50
}

resource "azurerm_storage_share" "redis" {
  name               = "cvat-cache-db"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50
}

# resource "azurerm_storage_share_file" "vector" {
#   name              = "vector.toml"
#   storage_share_url = azurerm_storage_share.vector.url
#   source            = "../config/components/cvat-vector-component/vector.toml"
# }

# resource "azurerm_storage_share_file" "redis" {
#   name              = "kvrocks.conf"
#   storage_share_url = azurerm_storage_share.redis.url
#   source            = "../config/components/cvat-cache-db/kvrocks.conf"
# }


resource "azurerm_private_endpoint" "storage_account_pe" {
    name                =  "${var.client_name}-${var.application_name}-storage-account-pe"
    location            = azurerm_resource_group.main_rg.location
    resource_group_name = azurerm_resource_group.main_rg.name
    subnet_id           = azurerm_subnet.private_endpoint_subnet.id
    custom_network_interface_name  = "${var.client_name}-${var.application_name}-private-link-sa-nic"

    private_service_connection {
        name                           = "${var.client_name}-${var.application_name}-sa-privateserviceconnection"
        private_connection_resource_id = azurerm_storage_account.main.id
        is_manual_connection           = false
        subresource_names              = ["file"]
    }
    ip_configuration {
        name                   = "${var.client_name}-${var.application_name}-sa-ip-name"
        private_ip_address     = "10.28.16.8"
        subresource_name        = "file"
    }
}