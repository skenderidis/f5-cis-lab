######## Create App Public IPs  ########
resource "azurerm_public_ip" "pip_app1" {
  name                      = "${var.prefix}_app1_pip"
  location                  = var.location
  sku				                = "Standard"
  availability_zone         = "No-Zone"
  resource_group_name       = var.rg_name
  allocation_method         = "Static"
  tags = {
    owner = var.tag
  }  
}
resource "azurerm_public_ip" "pip_app2" {
  name                      = "${var.prefix}_app2_pip"
  location                  = var.location
  sku				                = "Standard"
  availability_zone         = "No-Zone"
  resource_group_name       = var.rg_name
  allocation_method         = "Static"
  tags = {
    owner = var.tag
  }  
}
resource "azurerm_public_ip" "pip_app3" {
  name                      = "${var.prefix}_app3_pip"
  location                  = var.location
  sku				                = "Standard"
  availability_zone         = "No-Zone"
  resource_group_name       = var.rg_name
  allocation_method         = "Static"
  tags = {
    owner = var.tag
  }  
}
resource "azurerm_public_ip" "pip_app4" {
  name                      = "${var.prefix}_app4_pip"
  location                  = var.location
  sku				                = "Standard"
  availability_zone         = "No-Zone"
  resource_group_name       = var.rg_name
  allocation_method         = "Static"
  tags = {
    owner = var.tag
  }  
}

# Create a Public IP for BIGIP Management
resource "azurerm_public_ip" "public_ip_mgmt" {
  name                      = "${var.prefix}_mgmt_pip"
  location                  = var.location
  sku						            = "Standard"
  availability_zone         = "No-Zone"
  resource_group_name       = var.rg_name
  allocation_method         = "Static"
  tags = {
    owner = var.tag
  }
}

/*
### This is required only when we have to configure CFE
resource "azurerm_public_ip" "public_ip_ext" {
  name                      = "${var.prefix}-public-ip-ext"
  location                  = var.location
  availability_zone         = "No-Zone"
  sku						            = "Standard"
  resource_group_name       = var.rg_name
  allocation_method         = "Static"

  tags = {
    owner = var.tag
  }
}
*/


# Create the mgmt interface for BIG-IP
resource "azurerm_network_interface" "mgmt_nic" {
  name                      = "${var.prefix}_mgmt_nic"
  location                  = var.location
  resource_group_name       = var.rg_name
  ip_configuration {
    name                          = "selfIP"
    subnet_id                     = var.mgmt_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.self_ip_mgmt
    public_ip_address_id          = azurerm_public_ip.public_ip_mgmt.id
  }
  tags = {
    owner = var.tag
  }
}


# Assosiate NSG to 
resource "azurerm_network_interface_security_group_association" "nsg1" {
  network_interface_id      = azurerm_network_interface.mgmt_nic.id
  network_security_group_id = var.mgmt_nsg_id
}


# Create the ext interface for BIG-IP 
resource "azurerm_network_interface" "ext_nic" {
  name                            = "${var.prefix}-ext"
  location                        = var.location
  resource_group_name             = var.rg_name
  enable_ip_forwarding		        = true

  ip_configuration {
    name                          = "selfIP"
    subnet_id                     = var.ext_subnet_id
	primary						              = true
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.self_ip_ext
#    public_ip_address_id          = azurerm_public_ip.public_ip_ext.id
  }
  ip_configuration {
    name                          = "App01"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.app_ip_01
    public_ip_address_id          = azurerm_public_ip.pip_app1.id
  }
  ip_configuration {
    name                          = "App02"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.app_ip_02
    public_ip_address_id          = azurerm_public_ip.pip_app2.id
   }
  ip_configuration {
    name                          = "App03"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.app_ip_03
    public_ip_address_id          = azurerm_public_ip.pip_app3.id
  }
  ip_configuration {
    name                          = "App04"
    subnet_id                     = var.ext_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.app_ip_04
    public_ip_address_id          = azurerm_public_ip.pip_app4.id
  }

  tags = {
    owner = var.tag
  }
}
resource "azurerm_network_interface_security_group_association" "nsg2" {
  network_interface_id            = azurerm_network_interface.ext_nic.id
  network_security_group_id       = var.ext_nsg_id
}


# Create the ext interface for BIG-IP 01
resource "azurerm_network_interface" "int_nic" {
  name                            = "${var.prefix}-int"
  location                        = var.location
  resource_group_name             = var.rg_name

  ip_configuration {
    name                          = "selfIP"
    subnet_id                     = var.int_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address			      = var.self_ip_int
	}
  tags = {
    owner = var.tag
  }
}

data "template_file" "bigip_onboard" {
  template = file("${path.module}/f5_onboard.tmpl")
  vars = {
    INIT_URL                    = var.INIT_URL
    DO_URL                      = var.DO_URL
    AS3_URL                     = var.AS3_URL
    TS_URL                      = var.TS_URL
    CFE_URL                     = var.CFE_URL
    FAST_URL                    = var.FAST_URL,
    DO_VER                      = split("/", var.DO_URL)[7]
    AS3_VER                     = split("/", var.AS3_URL)[7]
    TS_VER                      = split("/", var.TS_URL)[7]
    CFE_VER                     = split("/", var.CFE_URL)[7]
    FAST_VER                    = split("/", var.FAST_URL)[7]
    username                    = var.username
    password                    = var.password
    hostname                    = "${var.prefix}-vm-${var.suffix}"
    self-ip-ext                 = var.self_ip_ext
    gateway                     = cidrhost(format("%s/24", var.self_ip_ext), 1)
    self-ip-int                 = var.self_ip_int
  }
}

# Create F5 BIGIP
resource "azurerm_virtual_machine" "bigip" {
  name                              = "${var.prefix}-vm-${var.suffix}"
  location                          = var.location
  resource_group_name               = var.rg_name
  primary_network_interface_id      = azurerm_network_interface.mgmt_nic.id
  network_interface_ids             = [azurerm_network_interface.mgmt_nic.id, azurerm_network_interface.ext_nic.id, azurerm_network_interface.int_nic.id]
  vm_size                           = var.f5_instance_type
  delete_os_disk_on_termination     = true
  delete_data_disks_on_termination  = true

  storage_image_reference {
    publisher                       = "f5-networks"
    offer                           = var.f5_product_name
    sku                             = var.f5_image_name
    version                         = var.f5_version
  }

  storage_os_disk {
    name                            = "${var.prefix}-osdisk"
    caching                         = "ReadWrite"
    create_option                   = "FromImage"
    managed_disk_type               = "Standard_LRS"
  }

  os_profile {
    computer_name                   = "${var.prefix}-os"
    admin_username                  = var.username
    admin_password                  = var.password
    custom_data                     = data.template_file.bigip_onboard.rendered

  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  plan {
    name                            = var.f5_image_name
    publisher                       = "f5-networks"
    product                         = var.f5_product_name
  }

  tags = {
    owner = var.tag
  }

  depends_on = [
    azurerm_network_interface_security_group_association.nsg2,
    azurerm_network_interface_security_group_association.nsg1

  ]

}

