################################
## Azure Provider _ Variables ##
################################

######### Azure authentication variables #########

variable subscription_id  		{}
variable client_id				{}
variable client_secret  		{}
variable tenant_id				{}


#########   Common Variables   ##########

variable tag 					{default = "CIS - Kubernetes Demo"}
variable location				{}
variable password		  		{}
variable username		  		{}
variable rg_prefix				{}


###########   k8s  Variables   ############
variable k8s_rg_name  			{default = "k8s-rg"}
variable k8s_vnet_name  		{default = "k8s_vnet"}
variable k8s_vnet_cidr  		{default = "10.10.50.0/24"}
variable k8s_subnet_name  		{default = "default"}
variable k8s_subnet_cidr  		{default = "10.10.50.0/24"}
variable k8s_ip_master  		{default = "10.10.50.10"}
variable k8s_ip_node01  		{default = "10.10.50.20"}
variable k8s_ip_node02  		{default = "10.10.50.30"}
variable k8s_prefix_master		{default = "master"}
variable k8s_prefix_node01		{default = "node01"}
variable k8s_prefix_node02		{default = "node02"}
variable k8s_vm-size			{default = "Standard_D4_v4"}
variable allowedIPs				{default = ["0.0.0.0/0"]}

