
##############################################
######## Create Resoruce Group VNETs ########
##############################################

# Create a resource group
data "azurerm_resource_group" "k8s_rg" {
  name     = "dc1_bigip-rg_F12"
}


##############################################
  ######## Create VNETs ########
##############################################

# Create App VNET
data "azurerm_virtual_network" "k8s_vnet" {
  name                  = "secure_vnet_F12"
  resource_group_name   = data.azurerm_resource_group.k8s_rg.name
}


##############################################
		######## Create subnets ########
##############################################

data "azurerm_subnet" "k8s_subnet" {
  name                    = "internal_F12"
  virtual_network_name    = data.azurerm_virtual_network.k8s_vnet.name
  resource_group_name     = data.azurerm_resource_group.k8s_rg.name
}



##############################################
		######## Create NSG ########
##############################################


# Create Network Security Group to access web
resource "azurerm_network_security_group" "k8s_nsg" {

  name                = "k8s-nsg"
  location            = var.location
  resource_group_name = data.azurerm_resource_group.k8s_rg.name 

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
  subnet_id = data.azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = data.azurerm_resource_group.k8s_rg.name
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
  subnet_id = data.azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = data.azurerm_resource_group.k8s_rg.name 
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
  subnet_id = data.azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = data.azurerm_resource_group.k8s_rg.name 
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}

module "node03" {
  source    = "./modules/ubuntu"
  tag       = var.tag
  prefix  	= var.k8s_prefix_node03
  ip 	    = var.k8s_ip_node03
  location  = var.location
  subnet_id = data.azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = data.azurerm_resource_group.k8s_rg.name 
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}

module "node04" {
  source    = "./modules/ubuntu"
  tag       = var.tag
  prefix  	= var.k8s_prefix_node04
  ip 	    = var.k8s_ip_node04
  location  = var.location
  subnet_id = data.azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = data.azurerm_resource_group.k8s_rg.name 
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}


module "node05" {
  source    = "./modules/ubuntu"
  tag       = var.tag
  prefix  	= var.k8s_prefix_node05
  ip 	    = var.k8s_ip_node05
  location  = var.location
  subnet_id = data.azurerm_subnet.k8s_subnet.id
  nsg_id  	= azurerm_network_security_group.k8s_nsg.id
  rg_name   = data.azurerm_resource_group.k8s_rg.name 
  password	= var.password
  username	= var.username
  vm-size	= var.k8s_vm-size
}



resource "null_resource" "create-json" {
    provisioner "local-exec" {
      command = "echo '{\"k8s_master_ip\":\"${module.master.public_ip}\", \"k8s_node01_ip\":\"${module.node01.public_ip}\", \"k8s_node02_ip\":\"${module.node02.public_ip}\", \"k8s_node03_ip\":\"${module.node03.public_ip}\", \"k8s_node04_ip\":\"${module.node04.public_ip}\", \"k8s_node05_ip\":\"${module.node05.public_ip}\"}' > ../../k8s.json"
  }

    provisioner "local-exec" {
      when    = destroy
      command = "rm ../../k8s.json"
      on_failure = continue
  }
}


resource "null_resource" "create-file-for-peering" {
  provisioner "local-exec" {
    command = "echo '{\"rg_name\":\"${data.azurerm_resource_group.k8s_rg.name}\", \"vnet_name\":\"${data.azurerm_virtual_network.k8s_vnet.name}\"}' > ../../k8s_info.json"
}
  provisioner "local-exec" {
    when    = destroy
    command = "rm ../../k8s_info.json"
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
output "k8s_node03_Public_IP" {
  value = module.node03.public_ip
}
output "k8s_node04_Public_IP" {
  value = module.node04.public_ip
}
output "k8s_node05_Public_IP" {
  value = module.node05.public_ip
}


