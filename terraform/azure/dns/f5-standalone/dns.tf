##############################################
######## Create DNS entries for F5 ########
##############################################


locals {
  f5_data = jsondecode(file("../../../../f5.json"))
}



resource "azurerm_dns_a_record" "f5_dns" {
  name                = var.f5_prefix
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.f5_data.mgmt_ip]
}


resource "azurerm_dns_a_record" "dns_pip1" {
  name                = var.app1_prefix
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.f5_data.app1_ip]
}

resource "azurerm_dns_a_record" "dns_pip2" {
  name                = var.app2_prefix
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.f5_data.app2_ip]
}

resource "azurerm_dns_a_record" "dns_pip3" {
  name                = var.app3_prefix
  zone_name           = var.zone_name
  resource_group_name = var.rg_zone
  ttl                 = 30
  records             = [local.f5_data.app3_ip]
}




output "F5-BIGIP-DNS-Name" {
  value = azurerm_dns_a_record.f5_dns.name
}
output "App-1-DNS-Name" {
  value = azurerm_dns_a_record.dns_pip1.name
}
output "App-2-DNS-Name" {
  value = azurerm_dns_a_record.dns_pip2.name
}
output "App-3-DNS-Name" {
  value = azurerm_dns_a_record.dns_pip3.name
}
output "App1-DNS-Name" {
  value = azurerm_dns_a_record.dns_pip1.name
}


