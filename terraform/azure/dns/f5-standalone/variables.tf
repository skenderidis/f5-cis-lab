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


variable f5_prefix      {default = "bigip01"}
variable app1_prefix	{default = "app1"}
variable app2_prefix	{default = "app2"}
variable app3_prefix	{default = "app3"}



