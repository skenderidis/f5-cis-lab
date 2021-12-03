output "F5_Mgmt_Public_IP" {
  value = module.azure_f5.mgmt_public_ip
}

output "App1_Public_IP" {
  value = module.azure_f5.app1_public_ip
}
output "App2_Public_IP" {
  value = module.azure_f5.app2_public_ip
}
output "App3_Public_IP" {
  value = module.azure_f5.app3_public_ip
}
output "App4_Public_IP" {
  value = module.azure_f5.app4_public_ip
}

output "username" {
  value = var.username
}
output "password" {
  value = var.password
}

