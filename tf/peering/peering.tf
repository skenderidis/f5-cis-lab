locals {
  f5_data = jsondecode(file("../../f5_info.json"))
  k8s_data = jsondecode(file("../../k8s_info.json"))
}


data "azurerm_virtual_network" "bigip_vnet" {
  name                = local.f5_data.vnet_name
  resource_group_name = local.f5_data.rg_name
}


data "azurerm_virtual_network" "k8s_vnet" {
  name                = local.k8s_data.vnet_name
  resource_group_name = local.k8s_data.rg_name
}


resource "azurerm_virtual_network_peering" "bigip_to_k8s" {
  name                      = "bigip_to_k8s"
  resource_group_name       = local.f5_data.rg_name
  virtual_network_name      = data.azurerm_virtual_network.bigip_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.k8s_vnet.id
}

resource "azurerm_virtual_network_peering" "k8s_to_bigip" {
  name                      = "k8s_to_bigip"
  resource_group_name       = local.k8s_data.rg_name
  virtual_network_name      = data.azurerm_virtual_network.k8s_vnet.name
  remote_virtual_network_id = data.azurerm_virtual_network.bigip_vnet.id
}

