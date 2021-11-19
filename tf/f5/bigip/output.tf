output "mgmt_public_ip" {
  value = azurerm_public_ip.public_ip_mgmt.ip_address
}

output "name" {
  value = azurerm_virtual_machine.bigip.name
}

output "app1_public_ip" {
  value = azurerm_public_ip.pip_app1.ip_address
}


output "id" {
  value = azurerm_virtual_machine.bigip.id
}

#output "start_id" {
#  value = azurerm_virtual_machine_extension.f5-bigip1-run-startup-cmd.id
#}

