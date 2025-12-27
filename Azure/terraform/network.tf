resource "azurerm_network_security_group" "main_nsg" {
  name                = "${var.client_name}-${var.application_name}-nsg"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
}

resource "azurerm_virtual_network" "application_vnet" {
  name                = local.virtual_network_name
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name
  address_space       = var.virtual_network_address_space
}

resource "azurerm_subnet" "application_subnet" {
  name                 = local.application_subnet_name
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.application_vnet.name
  address_prefixes     = var.application_subnet_prefixes

  delegation {
    name = "container-app-delegation"
    service_delegation {
      name = "Microsoft.App/environments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "database_subnet" {
  name                 = local.database_subnet_name
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.application_vnet.name
  address_prefixes     = var.database_subnet_prefixes

  delegation {
    name = "fs"
    service_delegation {
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "database_nsg_association" {
  subnet_id                 = azurerm_subnet.database_subnet.id
  network_security_group_id = azurerm_network_security_group.main_nsg.id
}

resource "azurerm_subnet" "traefik_subnet" {
  name                 = local.traefik_application_gateway_subnet
  resource_group_name  = azurerm_resource_group.main_rg.name
  virtual_network_name = azurerm_virtual_network.application_vnet.name
  address_prefixes     = var.traefik_application_gateway_subnet_prefixes
}