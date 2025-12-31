resource "azurerm_network_security_group" "traefik_nsg" {
    name                = "nsg-traefik-vm"
    location            = azurerm_resource_group.main_rg.location
    resource_group_name = azurerm_resource_group.main_rg.name
}

resource "azurerm_network_security_rule" "traefik_nsg_rule_AllowSSHInbound" {
    name                        = "AllowSSHInbound"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "${data.http.ip.response_body}/32"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.main_rg.name
    network_security_group_name = azurerm_network_security_group.traefik_nsg.name
}

resource "azurerm_network_security_rule" "traefik_nsg_rule_AllowHTTPSInbound" {
    name                        = "AllowHTTPSInbound"
    priority                    = 110
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "443"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.main_rg.name
    network_security_group_name = azurerm_network_security_group.traefik_nsg.name
}

resource "azurerm_network_security_rule" "traefik_nsg_rule_AllowHTTPInbound" {
    name                        = "AllowHTTPInbound"
    priority                    = 120
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "80"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.main_rg.name
    network_security_group_name = azurerm_network_security_group.traefik_nsg.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_test_vm_association" {
    subnet_id                 = azurerm_subnet.traefik_subnet.id
    network_security_group_id = azurerm_network_security_group.traefik_nsg.id
}


resource "azurerm_public_ip" "traefik_public_ip" {
    name                = "traefik-public-ip"
    domain_name_label   = "traefik"
    resource_group_name = azurerm_resource_group.main_rg.name
    location            = azurerm_resource_group.main_rg.location
    allocation_method   = "Static"
}

# resource "azurerm_network_interface" "traefik_nic" {
#     name                = "traefik-nic"
#     location            = azurerm_resource_group.main_rg.location
#     resource_group_name = azurerm_resource_group.main_rg.name

#     ip_configuration {
#         name                          = "traefik-ip-config"
#         subnet_id                     = azurerm_subnet.traefik_subnet.id
#         private_ip_address_allocation = "Static"
#         private_ip_address            = "10.28.10.9"
#         public_ip_address_id          = azurerm_public_ip.traefik_public_ip.id
#     }
# }

module "traefik_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.20.0"

  location = azurerm_resource_group.main_rg.location
  name     = local.traefik_application_gateway_name
  network_interfaces = {
    network_interface_1 = {
        name = "traefik-nic"
        ip_configurations = {
                ip_configuration_1 = {
                    name                                = "traefik-nic-config"
                    private_ip_subnet_resource_id       = "${azurerm_subnet.traefik_subnet.id}"
                    private_ip_address_allocation       = "Static"
                    private_ip_address                  = "10.28.10.9"
                    create_public_ip_address            = false
                    public_ip_address_resource_id       = "${azurerm_public_ip.traefik_public_ip.id}"
                }
        }
    }
  }
  resource_group_name = azurerm_resource_group.main_rg.name
  zone = "1"
  account_credentials = {
    admin_credentials = {
      username                           = "testuser"
      password                           = "h7!P$9kR@2vX*5mQ#8tZ"
      generate_admin_password_or_ssh_key = false
    }
    password_authentication_disabled = false
  }
  enable_telemetry           = true
  encryption_at_host_enabled = false
  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  os_type  = "Linux"
  sku_size = "Standard_B2ats_v2"
  source_image_reference = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
}