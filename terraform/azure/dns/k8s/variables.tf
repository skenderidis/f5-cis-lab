################################
## Azure Provider _ Variables ##
################################

######### Azure authentication variables #########

variable subscription_id  		{}
variable client_id				{}
variable client_secret  		{}
variable tenant_id				{}


#########   Common Variables   ##########

variable location				{}
variable zone_name {
    description = "The name of the DNS zone that the records will be stored"
    default = "f5demo.cloud"
}
variable rg_zone {
    description = "The resource group name that the DNS zone belongs to"
    default = "f5demo_dns"
}


variable k8s_prefix_master		{default = "master"}
variable k8s_prefix_node01		{default = "node01"}
variable k8s_prefix_node02		{default = "node02"}



