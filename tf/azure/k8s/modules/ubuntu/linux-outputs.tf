output "public_ip" {
  value = azurerm_public_ip.web-linux-vm-ip.ip_address
}
output "name" {
	value = azurerm_public_ip.web-linux-vm-ip.name
}
output "private_ip" {
  value = azurerm_network_interface.web-vm-nic.private_ip_address
}
output "id" {
  value = azurerm_linux_virtual_machine.web-linux-vm.id
}
