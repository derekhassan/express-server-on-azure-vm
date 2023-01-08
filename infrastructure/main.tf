resource "azurerm_resource_group" "express_server_rg" {
  name     = "rg-${var.project}-${var.environment}-001"
  location = var.location
}

resource "azurerm_virtual_network" "express_server_network" {
  name                = "vnet-${var.project}-${var.environment}-001"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.express_server_rg.location
  resource_group_name = azurerm_resource_group.express_server_rg.name
}

resource "azurerm_subnet" "express_server_subnet" {
  name                 = "snet-${var.project}-${var.environment}-001"
  resource_group_name  = azurerm_resource_group.express_server_rg.name
  virtual_network_name = azurerm_virtual_network.express_server_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "express_server_public_ip" {
  name                = "pip-${var.project}-${var.environment}-001"
  location            = azurerm_resource_group.express_server_rg.location
  resource_group_name = azurerm_resource_group.express_server_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "express_server_nsg" {
  name                = "nsg-${var.project}-${var.environment}-001"
  location            = azurerm_resource_group.express_server_rg.location
  resource_group_name = azurerm_resource_group.express_server_rg.name

  security_rule {
    name                       = "ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "http"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "express_server_nic" {
  name                = "nic-${var.project}-${var.environment}-001"
  location            = azurerm_resource_group.express_server_rg.location
  resource_group_name = azurerm_resource_group.express_server_rg.name

  ip_configuration {
    name                          = "express_server_nic_configuration"
    subnet_id                     = azurerm_subnet.express_server_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.express_server_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "express_server_security_group_assoc" {
  network_interface_id      = azurerm_network_interface.express_server_nic.id
  network_security_group_id = azurerm_network_security_group.express_server_nsg.id
}

# Boot diagnostics
resource "azurerm_storage_account" "express_server_storage_account" {
  name                     = "stvm${var.project}${var.environment}001"
  location                 = azurerm_resource_group.express_server_rg.location
  resource_group_name      = azurerm_resource_group.express_server_rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# SSH key
resource "tls_private_key" "generated_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "user_data" {
  template = file("./cloud-init.yml")
}

resource "azurerm_linux_virtual_machine" "express_server_vm" {
  name                  = "vm-${var.project}-${var.environment}-001"
  location              = azurerm_resource_group.express_server_rg.location
  resource_group_name   = azurerm_resource_group.express_server_rg.name
  network_interface_ids = [azurerm_network_interface.express_server_nic.id]
  size                  = var.vm_size

  user_data = base64encode(data.template_file.user_data.rendered)

  os_disk {
    name                 = "osdisk-${var.project}-${var.environment}-001"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.vm_source_image_publisher
    offer     = var.vm_source_image_offer
    sku       = var.vm_source_image_sku
    version   = "latest"
  }

  computer_name                   = var.vm_computer_name
  admin_username                  = var.vm_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.vm_username
    public_key = tls_private_key.generated_ssh_key.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.express_server_storage_account.primary_blob_endpoint
  }
}

