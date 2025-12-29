resource "azurerm_subnet" "vm_test_subnet" {
    name                 = "vm-test-subnet"
    resource_group_name  = azurerm_resource_group.main_rg.name
    virtual_network_name = azurerm_virtual_network.application_vnet.name
    address_prefixes     = ["10.28.9.0/24"]
    service_endpoints    = ["Microsoft.Storage"]
}

resource "azurerm_network_security_group" "nsg_test_vm" {
    name                = "nsg-test-vm"
    location            = azurerm_resource_group.main_rg.location
    resource_group_name = azurerm_resource_group.main_rg.name
}

resource "azurerm_network_security_rule" "nsg_rule_test" {
    name                        = "AllowSSHInbound"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    resource_group_name         = azurerm_resource_group.main_rg.name
    network_security_group_name = azurerm_network_security_group.nsg_test_vm.name
}

resource "azurerm_subnet_network_security_group_association" "nsg_association_test_vm_association" {
  subnet_id                 = azurerm_subnet.vm_test_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_test_vm.id
}

resource "azurerm_public_ip" "test_vm_public_ip" {
    name                = "test-vm-public-ip"
    resource_group_name = azurerm_resource_group.main_rg.name
    location            = azurerm_resource_group.main_rg.location
    allocation_method   = "Static"
}

resource "azurerm_network_interface" "test_vm_nic" {
    name                = "test-vm-nic"
    location            = azurerm_resource_group.main_rg.location
    resource_group_name = azurerm_resource_group.main_rg.name

    ip_configuration {
        name                          = "test-vm-ip-config"
        subnet_id                     = azurerm_subnet.vm_test_subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = "10.28.9.9"
        public_ip_address_id          = azurerm_public_ip.test_vm_public_ip.id
    }
}

resource "azurerm_virtual_machine" "main" {
    name                  = "test-vm"
    location              = azurerm_resource_group.main_rg.location
    resource_group_name   = azurerm_resource_group.main_rg.name
    network_interface_ids = [azurerm_network_interface.test_vm_nic.id]
    vm_size               = "Standard_B2ats_v2"

    # Uncomment this line to delete the OS disk automatically when deleting the VM
    delete_os_disk_on_termination = true

    # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = true

    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "test-vm-os-disk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "test-vm"
        admin_username = "testadmin"
        admin_password = "Password1234!"
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}