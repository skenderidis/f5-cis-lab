##############################################
######## Create Resoruce Group VNETs ########
##############################################

resource "random_string" "suffix" {
  length  = 3
  special = false
}



# Create a resource group
resource "azurerm_resource_group" "f5_rg" {
  name     = "${var.rg_prefix}-${var.f5_rg_name}-${random_string.suffix.result}"
  location = var.location
  tags = {
    owner = var.tag
  }
}



##############################################
  ######## Create VNETs ########
##############################################

# Create the Secure VNET 
resource "azurerm_virtual_network" "f5_vnet" {
  name                = var.f5_vnet_name
  address_space       = [var.f5_vnet_cidr]
  resource_group_name = azurerm_resource_group.f5_rg.name
  location            = var.location
  tags = {
    owner = var.tag
  }
}



##############################################
		######## Create subnets ########
##############################################

resource "azurerm_subnet" "mgmt_subnet" {
  name                 = var.mgmt_subnet_name
  address_prefixes       = [var.mgmt_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "ext_subnet" {
  name                 = var.ext_subnet_name
  address_prefixes       = [var.ext_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}

resource "azurerm_subnet" "int_subnet" {
  name                 = var.int_subnet_name
  address_prefixes       = [var.int_subnet_cidr]
  virtual_network_name = azurerm_virtual_network.f5_vnet.name
  resource_group_name  = azurerm_resource_group.f5_rg.name 
}



##############################################
		######## Create NSG ########
##############################################


# Create Network Security Group to access F5 mgmt
resource "azurerm_network_security_group" "f5_nsg_mgmt" {

  name                = "${var.f5_vnet_name}-f5_mgmt-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.f5_rg.name 

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

  name                = "${var.f5_vnet_name}-f5_ext-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.f5_rg.name 

  security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 120
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
    priority                   = 122
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



##############################################
		######## Create F5 HA  ########
##############################################


module "azure_f5_ha1" {
  source            = "./modules/f5 bigip"
  azure_region      = var.location
  azure_rg_name     = azurerm_resource_group.f5_rg.name
  prefix            = "${var.prefix_bigip}-01" 
  tag 		          = var.tag
  mgmt_subnet_id 	  = azurerm_subnet.mgmt_subnet.id
  mgmt_nsg_id	  	  = azurerm_network_security_group.f5_nsg_mgmt.id
  ext_subnet_id 	  = azurerm_subnet.ext_subnet.id
  ext_nsg_id		    = azurerm_network_security_group.f5_nsg_ext.id
  int_subnet_id 	  = azurerm_subnet.int_subnet.id
  self_ip_mgmt 		  = var.self_ip_mgmt_01
  self_ip_ext 		  = var.self_ip_ext_01
  add_ip_ext_1 		  = var.add_ip_ext_01_1
  add_ip_ext_2		  = var.add_ip_ext_01_2
  add_ip_ext_3		  = var.add_ip_ext_01_3
  self_ip_int 		  = var.self_ip_int_01
  f5_instance_type  = var.f5_instance_type
  f5_version        = var.f5_version
  f5_image_name     = var.f5_image_name
  f5_product_name   = var.f5_product_name
  DO_URL            = var.do_url
  AS3_URL           = var.as3_url
  TS_URL            = var.ts_url
  CFE_URL			      = var.cfe_url
  FAST_URL			    = var.fast_url
  f5_password       = var.password
  f5_username       = var.username  
}


module "azure_f5_ha2" {
  source            = "./modules/f5 bigip"
  azure_region      = var.location
  azure_rg_name     = azurerm_resource_group.f5_rg.name
  prefix            = "${var.prefix_bigip}-02" 
  tag 		          = var.tag
  mgmt_subnet_id 	  = azurerm_subnet.mgmt_subnet.id
  mgmt_nsg_id	  	  = azurerm_network_security_group.f5_nsg_mgmt.id
  ext_subnet_id 	  = azurerm_subnet.ext_subnet.id
  ext_nsg_id		    = azurerm_network_security_group.f5_nsg_ext.id
  int_subnet_id 	  = azurerm_subnet.int_subnet.id
  self_ip_mgmt 		  = var.self_ip_mgmt_02
  self_ip_ext 		  = var.self_ip_ext_02
  add_ip_ext_1 		  = var.add_ip_ext_02_1
  add_ip_ext_2		  = var.add_ip_ext_02_2
  add_ip_ext_3		  = var.add_ip_ext_02_3
  self_ip_int 		  = var.self_ip_int_02
  f5_instance_type  = var.f5_instance_type
  f5_version        = var.f5_version
  f5_image_name     = var.f5_image_name
  f5_product_name   = var.f5_product_name
  DO_URL            = var.do_url
  AS3_URL           = var.as3_url
  TS_URL            = var.ts_url
  CFE_URL			      = var.cfe_url
  FAST_URL			    = var.fast_url
  f5_password       = var.password
  f5_username       = var.username  
}


##############################################
	######## Create LB ########
##############################################


resource "azurerm_public_ip" "lb_pip_app1" {
  name                = "PublicIPForApp1"
  location            = var.location
  sku				          = "Standard"
  resource_group_name = azurerm_resource_group.f5_rg.name 
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "lb_pip_app2" {
  name                = "PublicIPForApp2"
  location            = var.location
  sku				          = "Standard"
  resource_group_name = azurerm_resource_group.f5_rg.name 
  allocation_method   = "Static"
}

resource "azurerm_public_ip" "lb_pip_app3" {
  name                = "PublicIPForApp3"
  location            = var.location
  sku				          = "Standard"
  resource_group_name = azurerm_resource_group.f5_rg.name 
  allocation_method   = "Static"
}


resource "azurerm_lb" "f5_ha_lb" {
  name                = "F5_HA_LB"
  location            = var.location
  sku				  = "Standard"
  resource_group_name = azurerm_resource_group.f5_rg.name 

  frontend_ip_configuration {
    name                 = "App1"
    public_ip_address_id = azurerm_public_ip.lb_pip_app1.id
  }
  frontend_ip_configuration {
    name                 = "App2"
    public_ip_address_id = azurerm_public_ip.lb_pip_app2.id
  }  
  frontend_ip_configuration {
    name                 = "App3"
    public_ip_address_id = azurerm_public_ip.lb_pip_app3.id
  }  
  
}

resource "azurerm_lb_probe" "tcp_80" {
  resource_group_name = azurerm_resource_group.f5_rg.name 
  loadbalancer_id     = azurerm_lb.f5_ha_lb.id
  name                = "TCP-80"
  port                = 80
}


resource "azurerm_lb_backend_address_pool" "pool_app1" {
  loadbalancer_id     = azurerm_lb.f5_ha_lb.id
  name                = "Pool_App1"
}

resource "azurerm_lb_backend_address_pool" "pool_app2" {
  loadbalancer_id     = azurerm_lb.f5_ha_lb.id
  name                = "Pool_App2"
}

resource "azurerm_lb_backend_address_pool" "pool_app3" {
  loadbalancer_id     = azurerm_lb.f5_ha_lb.id
  name                = "Pool_App3"
}


resource "azurerm_network_interface_backend_address_pool_association" "pool1" {
  network_interface_id    = module.azure_f5_ha1.ext_nic_id
  ip_configuration_name   = "Add01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_app1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool2" {
  network_interface_id    = module.azure_f5_ha2.ext_nic_id
  ip_configuration_name   = "Add01"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_app1.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool1_1" {
  network_interface_id    = module.azure_f5_ha1.ext_nic_id
  ip_configuration_name   = "Add02"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_app2.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool2_2" {
  network_interface_id    = module.azure_f5_ha2.ext_nic_id
  ip_configuration_name   = "Add02"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_app2.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool3_1" {
  network_interface_id    = module.azure_f5_ha1.ext_nic_id
  ip_configuration_name   = "Add03"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_app3.id
}

resource "azurerm_network_interface_backend_address_pool_association" "pool3_2" {
  network_interface_id    = module.azure_f5_ha2.ext_nic_id
  ip_configuration_name   = "Add03"
  backend_address_pool_id = azurerm_lb_backend_address_pool.pool_app3.id
}


resource "azurerm_lb_rule" "App1_80" {
  resource_group_name            = var.location
  loadbalancer_id                = azurerm_lb.f5_ha_lb.id
  name                           = "App1_Port_80"
  protocol                       = "Tcp"
  probe_id						           = azurerm_lb_probe.tcp_80.id
  backend_address_pool_id		     = azurerm_lb_backend_address_pool.pool_app1.id
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "App1"
}

resource "azurerm_lb_rule" "App2_80" {
  resource_group_name            = var.location
  loadbalancer_id                = azurerm_lb.f5_ha_lb.id
  name                           = "App2_Port_80"
  protocol                       = "Tcp"
  probe_id						           = azurerm_lb_probe.tcp_80.id
  backend_address_pool_id		     = azurerm_lb_backend_address_pool.pool_app2.id
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "App2"
}

resource "azurerm_lb_rule" "App3_80" {
  resource_group_name            = var.location
  loadbalancer_id                = azurerm_lb.f5_ha_lb.id
  name                           = "App3_Port_80"
  protocol                       = "Tcp"
  probe_id						           = azurerm_lb_probe.tcp_80.id
  backend_address_pool_id		     = azurerm_lb_backend_address_pool.pool_app3.id
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "App3"
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

resource "null_resource" "create-f5json" {
  provisioner "local-exec" {
    command = "echo '{\"bigip_01_mgmt\":\"${module.azure_f5_ha1.mgmt_public_ip}\", \"bigip_02_mgmt\":\"${module.azure_f5_ha2.mgmt_public_ip}\", \"app1_ip\":\"${azurerm_public_ip.lb_pip_app1.ip_address}\", \"app2_ip\":\"${azurerm_public_ip.lb_pip_app2.ip_address}\", \"app3_ip\":\"${azurerm_public_ip.lb_pip_app3.ip_address}\", \"f5_user\":\"${var.username}\", \"f5_pass\":\"${var.password}\"}' > ../../f5.json"
}
  provisioner "local-exec" {
    when    = destroy
    command = "rm ../../f5.json"
    on_failure = continue
}

}



output "BIGIP01-Mgmt_Public_IP" {
  value = module.azure_f5_ha1.mgmt_public_ip
}
output "BIGIP02-Mgmt_Public_IP" {
  value = module.azure_f5_ha2.mgmt_public_ip
}

output "App1_Public_IP" {
  value = azurerm_public_ip.lb_pip_app1.ip_address
}
output "App2_Public_IP" {
  value = azurerm_public_ip.lb_pip_app2.ip_address
}
output "App3_Public_IP" {
  value = azurerm_public_ip.lb_pip_app3.ip_address
}
