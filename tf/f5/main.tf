######## Create a suffix ########
resource "random_string" "suffix" {
  length  = 3
  special = false
}

######## Create a Resource Group ########
resource "azurerm_resource_group" "f5_rg" {
  name      = "${var.rg_prefix}_${var.f5_rg_name}_${random_string.suffix.result}"
  location  = var.location
  tags = {
    owner = var.tag
  }
}

######## Create F5 VNET ########
resource "azurerm_virtual_network" "f5_vnet" {
  name                = "${var.f5_vnet_name}_${random_string.suffix.result}"
  address_space       = [var.f5_vnet_cidr]
  resource_group_name = azurerm_resource_group.f5_rg.name
  location            = var.location
  tags = {
    owner = var.tag
  }
}


######## Create F5 subnets ########

resource "azurerm_subnet" "mgmt_subnet" {
  name                    = "${var.mgmt_subnet_name}_${random_string.suffix.result}"
  address_prefixes        = [var.mgmt_subnet_cidr]
  virtual_network_name    = azurerm_virtual_network.f5_vnet.name
  resource_group_name     = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "ext_subnet" {
  name                    = "${var.ext_subnet_name}_${random_string.suffix.result}"
  address_prefixes        = [var.ext_subnet_cidr]
  virtual_network_name    = azurerm_virtual_network.f5_vnet.name
  resource_group_name     = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "int_subnet" {
  name                    = "${var.int_subnet_name}_${random_string.suffix.result}"
  address_prefixes        = [var.int_subnet_cidr]
  virtual_network_name    = azurerm_virtual_network.f5_vnet.name
  resource_group_name     = azurerm_resource_group.f5_rg.name 
}


#### Create Network Security Group to access F5 mgmt
resource "azurerm_network_security_group" "f5_nsg_mgmt" {

  name                        = "f5_mgmt_nsg_${random_string.suffix.result}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-ssh"
    description                = "allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }
  tags = {
    owner = var.tag
  }
}

# Create Network Security Group to access F5 ext
resource "azurerm_network_security_group" "f5_nsg_ext" {

  name                        = "f5_ext_nsg_${random_string.suffix.result}"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    description                = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = var.allowedIPs
    destination_address_prefix = "*"
  }
  
  tags = {
    owner = var.tag
  }
}


######## Create F5 ########
module "azure_f5" {
  source            = "./bigip"
  location          = var.location
  rg_name           = azurerm_resource_group.f5_rg.name
  prefix            = var.prefix_bigip
  tag 		          = var.tag
  suffix            = random_string.suffix.result
  mgmt_subnet_id 	  = azurerm_subnet.mgmt_subnet.id
  mgmt_nsg_id	  	  = azurerm_network_security_group.f5_nsg_mgmt.id
  ext_subnet_id 	  = azurerm_subnet.ext_subnet.id
  ext_nsg_id		    = azurerm_network_security_group.f5_nsg_ext.id
  int_subnet_id 	  = azurerm_subnet.int_subnet.id
  self_ip_mgmt 		  = var.self_ip_mgmt_01
  self_ip_ext 		  = var.self_ip_ext_01
  self_ip_int 		  = var.self_ip_int_01
  app_ip_01         = var.app_ip_01
  app_ip_02         = var.app_ip_02
  app_ip_03         = var.app_ip_03
  app_ip_04         = var.app_ip_04
  f5_instance_type  = var.f5_instance_type
  f5_version        = var.f5_version
  f5_image_name     = var.f5_image_name
  f5_product_name   = var.f5_product_name
  password          = var.password
  username          = var.username
  INIT_URL          = var.init_url
  DO_URL            = var.do_url
  AS3_URL           = var.as3_url
  TS_URL            = var.ts_url
  CFE_URL			      = var.cfe_url
  FAST_URL			    = var.fast_url
}



resource "null_resource" "create-f5json" {
  provisioner "local-exec" {
    command = "echo '{\"mgmt_ip\":\"${module.azure_f5.mgmt_public_ip}\", \"app1_ip\":\"${module.azure_f5.app1_public_ip}\",  \"f5_user\":\"${var.username}\", \"f5_pass\":\"${var.password}\"}' > ../../f5.json"
  }
  provisioner "local-exec" {
      when    = destroy
      command = "rm ../../f5.json"
      on_failure = continue
  }
}

resource "null_resource" "create-file-for-peering" {
  provisioner "local-exec" {
    command = "echo '{\"rg_name\":\"${azurerm_resource_group.f5_rg.name}\", \"vnet_name\":\"${azurerm_virtual_network.f5_vnet.name}\"}' > ../../f5_info.json"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "rm ../../f5_info.json"
    on_failure = continue
  }

}
