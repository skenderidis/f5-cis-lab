
# F5 CIS Azure Lab . (Work in progress)


### Variables

Most of the variables can be found on `variables.tf` on the `tf` directories. Please see below the example on the `f5_standalone` directory.

```shell

######### Azure authentication variables #########

variable subscription_id      {}
variable client_id            {}
variable client_secret        {}
variable tenant_id            {}


#########   Common Variables   ##########
variable tag        {default = "CIS - Kubernetes Demo"}
variable password	      {}
variable username		  	    	{}
variable location				      {}
variable rg_prefix			    	{}

###########   F5  Variables   ############
variable f5_rg_name				    {default = "bigip-rg" }
variable f5_vnet_name  			  {default = "secure_vnet"}
variable f5_vnet_cidr  			  {default = "10.1.0.0/16" }

variable mgmt_subnet_name		  {default = "management"}
variable int_subnet_name  		{default = "internal"}
variable ext_subnet_name  		{default = "external" }

variable mgmt_subnet_cidr		  {default = "10.1.1.0/24" }
variable int_subnet_cidr  		{default = "10.1.20.0/24" }
variable ext_subnet_cidr  		{default = "10.1.10.0/24" }

variable self_ip_mgmt_01  		{default = "10.1.1.4"}
variable self_ip_ext_01  		  {default = "10.1.10.4"}
variable add_ip_ext_01_1  		{default = "10.1.10.10"}
variable add_ip_ext_01_2  		{default = "10.1.10.20"}
variable add_ip_ext_01_3  		{default = "10.1.10.30"}
variable self_ip_int_01  		  {default = "10.1.20.4"}
variable prefix_bigip  			  {default = "bigip1"}

variable allowedIPs				    {default = ["0.0.0.0/0"]}


########################
#  F5 Image related	   #
########################

variable f5_version 			    {default = "15.1.201000"}
variable f5_image_name 			  {default = "f5-bigip-virtual-edition-25m-best-hourly" }
variable f5_product_name 		  {default = "f5-big-ip-best"}
variable f5_instance_type 		{default = "Standard_DS4_v2"}
variable do_url 				      {default = "https://github.com/F5Networks/f5-declarative-onboarding/releases/download/v1.21.0/f5-declarative-onboarding-1.21.0-3.noarch.rpm"}
variable as3_url      {default = "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.28.0/f5-appsvcs-3.28.0-3.noarch.rpm"}
variable ts_url       {default = "https://github.com/F5Networks/f5-telemetry-streaming/releases/download/v1.20.0/f5-telemetry-1.20.0-3.noarch.rpm" }
variable cfe_url      {default = "https://github.com/F5Networks/f5-cloud-failover-extension/releases/download/v1.8.0/f5-cloud-failover-1.8.0-0.noarch.rpm" }
variable fast_url     {default = "https://github.com/F5Networks/f5-appsvcs-templates/releases/download/v1.9.0/f5-appsvcs-templates-1.9.0-1.noarch.rpm" }

```



