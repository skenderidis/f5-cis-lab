output "mgmt_public_ip" {
  value = azurerm_public_ip.public_ip_mgmt.ip_address
}

output "name" {
  value = azurerm_virtual_machine.f5-bigip1.name
}

output "ext_public_ip" {
  value = azurerm_public_ip.public_ip_ext.ip_address
}

output "ext_nic_id" {
  value = azurerm_network_interface.ext_nic.id
}

output "id" {
  value = azurerm_virtual_machine.f5-bigip1.id
}

output "start_id" {
  value = azurerm_virtual_machine_extension.f5-bigip1-run-startup-cmd.id
}

