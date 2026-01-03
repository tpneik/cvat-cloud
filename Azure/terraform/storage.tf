resource "azurerm_storage_account" "main" {
  name                              = local.storage_account_name
  resource_group_name               = azurerm_resource_group.main_rg.name
  location                          = azurerm_resource_group.main_rg.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  public_network_access_enabled     = true
}

# Take note that azurerm_storage_account_network_rules must have only one per storage account.
# You cannot have multiple azurerm_storage_account_network_rules for the same storage account.
resource "azurerm_storage_account_network_rules" "sa_network_rule_to_allow_administrator_ip" {
  storage_account_id = azurerm_storage_account.main.id
  default_action             = "Deny"
  ip_rules                   = ["${data.http.ip.response_body}"]
  # Take note of these subnet IDs. They must have service endpoint for Microsoft.Storage enabled in order to work.
  # If more subnets need access, add them to this list.
  # virtual_network_subnet_ids = [azurerm_subnet.vm_test_subnet.id]
  virtual_network_subnet_ids = [azurerm_subnet.application_subnet.id, azurerm_subnet.traefik_subnet.id]
  bypass                     = ["AzureServices"]
}

resource "azurerm_storage_share" "vector" {
  name               = "cvat-vector-component"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip
  ]
}

resource "azurerm_storage_share" "redis" {
  name               = "cvat-cache-db"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip
  ]
}

resource "azurerm_storage_share_file" "vector" {
  name              = "vector.toml"
  storage_share_url = azurerm_storage_share.vector.url
  source            = "../config/components/cvat-vector-component/vector.toml"
}

resource "azurerm_storage_share_file" "redis" {
  name              = "kvrocks.conf"
  storage_share_url = azurerm_storage_share.redis.url
  source            = "../config/components/cvat-cache-db/kvrocks.conf"
}

resource "azurerm_storage_share" "cvat_data" {
  name               = "cvat-data"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip
  ]
}

resource "azurerm_storage_share" "cvat_keys" {
  name               = "cvat-keys"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip
  ]
}

resource "azurerm_storage_share" "cvat_logs" {
  name               = "cvat-logs"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip
  ]
}

resource "azurerm_storage_share" "cvat_events_db" {
  name               = "cvat-events-db"
  storage_account_id = azurerm_storage_account.main.id
  quota              = 50

  depends_on = [
    azurerm_storage_account.main,
    azurerm_storage_account_network_rules.sa_network_rule_to_allow_administrator_ip
  ]
}
