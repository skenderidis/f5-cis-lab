
##############################################
######## Create Resoruce Group VNETs ########
##############################################

resource "random_string" "suffix" {
  length  = 3
  special = false
}



# Create a resource group
resource "azurerm_resource_group" "k8s_rg" {
  name     = "${var.rg_prefix}-${var.k8s_rg_name}-${random_string.suffix.result}"
  location = var.location
  tags = {
    owner = var.tag
  }
}


##############################################
  ######## Create VNETs ########
##############################################

# Create App VNET
resource "azurerm_virtual_network" "k8s_vnet" {
  name                  = var.k8s_vnet_name
  address_space         = [var.k8s_vnet_cidr]
  resource_group_name   = azurerm_resource_group.k8s_rg.name
  location              = var.location
  tags = {
    owner = var.tag
  }
}


##############################################
		######## Create subnets ########
##############################################

resource "azurerm_subnet" "k8s_subnet" {
  name                    = var.k8s_subnet_name
  address_prefixes        = [var.k8s_subnet_cidr]
  virtual_network_name    = azurerm_virtual_network.k8s_vnet.name
  resource_group_name     = azurerm_resource_group.k8s_rg.name 
}


##############################################
		######## Create NSG ########
##############################################


# Create Network Security Group to access web
resource "azurerm_network_security_group" "k8s_nsg" {

  name                = "k8s-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.k8s_rg.name 

  security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefixes	   = var.allowedIPs
    destination_address_prefix = "*"
  }
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
  tags = {
    owner = var.tag
  }
}



##############################################
		######## Create K8s servers ########
##############################################

# Create a resource group for Demo
module "master" {
  source    = "./modules/ubuntu"
  tag       = var.tag
  prefix  	= var.k8s_prefix_master
  ip 	    = var.k8s_ip_master
  location  = var.location
  subnet_id = azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = azurerm_resource_group.k8s_rg.name
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}

module "node01" {
  source    = "./modules/ubuntu"
  tag       = var.tag
  prefix  	= var.k8s_prefix_node01
  ip 	    = var.k8s_ip_node01
  location  = var.location
  subnet_id = azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = azurerm_resource_group.k8s_rg.name 
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}

module "node02" {
  source    = "./modules/ubuntu"
  tag       = var.tag
  prefix  	= var.k8s_prefix_node02
  ip 	    = var.k8s_ip_node02
  location  = var.location
  subnet_id = azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = azurerm_resource_group.k8s_rg.name 
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}



resource "null_resource" "create-json" {
    provisioner "local-exec" {
      command = "echo '{\"k8s_master_ip\":\"${module.master.public_ip}\", \"k8s_node01_ip\":\"${module.node01.public_ip}\", \"k8s_node02_ip\":\"${module.node02.public_ip}\"}' > ../../../k8s.json"
  }

    provisioner "local-exec" {
      when    = destroy
      command = "rm ../../../k8s.json"
      on_failure = continue
  }
}


resource "null_resource" "create-file-for-peering" {
  provisioner "local-exec" {
    command = "echo '{\"rg_name\":\"${azurerm_resource_group.k8s_rg.name}\", \"vnet_name\":\"${azurerm_virtual_network.k8s_vnet.name}\"}' > ../../../k8s_info.json"
}
  provisioner "local-exec" {
    when    = destroy
    command = "rm ../../../k8s_info.json"
    on_failure = continue
}

}


output "k8s_master_Public_IP" {
  value = module.master.public_ip
}
output "k8s_node01_Public_IP" {
  value = module.node01.public_ip
}
output "k8s_node02_Public_IP" {
  value = module.node02.public_ip
}



