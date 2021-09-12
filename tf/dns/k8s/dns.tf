##############################################
######## Create K8s DNS entries ########
##############################################

locals {
#  f5_data = jsondecode(file("f5.json"))
  k8s_data = jsondecode(file("../../../k8s.json"))
}


resource "azurerm_dns_a_record" "k8s_master" {
  name                = var.k8s_prefix_master
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.k8s_data.k8s_master_ip]
}

resource "azurerm_dns_a_record" "k8s_node01" {
  name                = var.k8s_prefix_node01
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.k8s_data.k8s_node01_ip]
}


resource "azurerm_dns_a_record" "k8s_node02" {
  name                = var.k8s_prefix_node02
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.k8s_data.k8s_node02_ip]
}



output "K8s-Master-DNS-Name" {
  value = azurerm_dns_a_record.k8s_master.name
}
output "K8s-Node01-DNS-Name" {
  value = azurerm_dns_a_record.k8s_node01.name
}
output "K8s-Node02-DNS-Name" {
  value = "${azurerm_dns_a_record.k8s_node02.name}+.+${var.rg_zone}"
}
