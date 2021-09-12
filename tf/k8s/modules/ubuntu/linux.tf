#####################################
## Linux VM with Web Server - Main ##
#####################################

# Generate random password
#resource "random_password" "web-linux-vm-password" {
#  length           = 16
#  min_upper        = 2
#  min_lower        = 2
#  min_special      = 2
#  number           = true
#  special          = true
#  override_special = "!@#$%&"
#}

# Generate randon name for virtual machine
resource "random_string" "random-linux-vm" {
  length  = 5
  special = false
  lower   = true
  upper   = false
  number  = true
}


# Get a Static Public IP
resource "azurerm_public_ip" "web-linux-vm-ip" {

  name                = "${var.prefix}-vm-ip"
  location            = var.location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  
  tags = {
    owner = var.tag
  }
}

# Create Network Card for web VM
resource "azurerm_network_interface" "web-vm-nic" {
  depends_on=[azurerm_public_ip.web-linux-vm-ip]

  name                = "${var.prefix}-vm-nic"
  location            = var.location
  resource_group_name = var.rg_name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.ip	
    public_ip_address_id          = azurerm_public_ip.web-linux-vm-ip.id
  }
  tags = {
    owner = var.tag
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_vnic" {

  network_interface_id      = azurerm_network_interface.web-vm-nic.id
  network_security_group_id = var.nsg_id
  
}

# Create Linux VM with web server
resource "azurerm_linux_virtual_machine" "web-linux-vm" {
  depends_on=[azurerm_network_interface.web-vm-nic]

  name                  = "${var.prefix}-linux-vm"
  location              = var.location
  resource_group_name   = var.rg_name
  network_interface_ids = [azurerm_network_interface.web-vm-nic.id]
  size                  = var.vm-size

  source_image_reference {
    offer     = lookup(var.web-linux-vm-image, "offer", null)
    publisher = lookup(var.web-linux-vm-image, "publisher", null)
    sku       = lookup(var.web-linux-vm-image, "sku", null)
    version   = lookup(var.web-linux-vm-image, "version", null)
  }

  os_disk {
    name                 = "${var.prefix}-vm-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "${var.prefix}-vm"
  admin_username = var.username
  admin_password = var.password 

  disable_password_authentication = false
  
  admin_ssh_key {
	username       = var.username
 	public_key     = file("id_rsa.pub")
  }
  
  tags = {
    owner = var.tag
  }
}
