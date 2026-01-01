resource "azurerm_storage_container" "this" {
  name                  = "traefik-scripts"
  storage_account_id    = azurerm_storage_account.main.id
  container_access_type = "blob"
}


resource "azurerm_storage_blob" "main-script" {
  name                   = "install-script"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Block"
  source                 = "../config/traefik-config/python-script/install-traefik.sh"
}

resource "azurerm_storage_blob" "output-log" {
  name                   = "output"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Append"
}

resource "azurerm_storage_blob" "error-log" {
  name                   = "error"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.this.name
  type                   = "Append"
}

data "azurerm_storage_account_sas" "example" {
  connection_string = azurerm_storage_account.main.primary_connection_string
  https_only        = true
  signed_version    = "2021-08-06"
  start             = "2026-01-01T00:00:00Z"
  expiry            = "2028-01-01T00:00:00Z"

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
    tag     = false
    filter  = false
  }
}

# authorize to storage blob using SAS token
resource "azurerm_virtual_machine_run_command" "this" {
  location           = azurerm_resource_group.main_rg.location
  name               = "setup-traefik"
  virtual_machine_id = module.traefik_vm.resource_id
  error_blob_uri     = "${azurerm_storage_blob.error-log.id}${data.azurerm_storage_account_sas.example.sas}"
  output_blob_uri    = "${azurerm_storage_blob.output-log.id}${data.azurerm_storage_account_sas.example.sas}"
  source {
    script_uri = "${azurerm_storage_blob.main-script.id}${data.azurerm_storage_account_sas.example.sas}"
  }

#   parameter {

#     name  = "example-vm1"
#     value = "val1"
#   }

#   tags = {
#     environment = "terraform-example-s"
#     some_key    = "some-value"
#   }
}