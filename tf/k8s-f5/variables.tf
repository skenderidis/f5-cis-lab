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

variable k8s_ip_master  		{default = "10.1.20.100"}
variable k8s_ip_node01  		{default = "10.1.20.101"}
variable k8s_ip_node02  		{default = "10.1.20.102"}
variable k8s_ip_node03  		{default = "10.1.20.103"}
variable k8s_ip_node04  		{default = "10.1.20.104"}
variable k8s_ip_node05  		{default = "10.1.20.105"}

variable k8s_prefix_master		{default = "master"}
variable k8s_prefix_node01		{default = "node01"}
variable k8s_prefix_node02		{default = "node02"}
variable k8s_prefix_node03		{default = "node03"}
variable k8s_prefix_node04		{default = "node04"}
variable k8s_prefix_node05		{default = "node05"}
variable k8s_vm-size			{default = "Standard_D8_v4"}
variable allowedIPs				{default = ["0.0.0.0/0"]}

