output "RVBD_Director-1_Instance" {
  value = "${azurerm_virtual_machine.directorVM.*.name[0]}"
}

output "RVBD_Director-1_MGMT_IP" {
  value = "${azurerm_network_interface.director_nic_1.*.private_ip_address[0]}"
}

output "RVBD_Director-1_South_IP" {
  value = "${azurerm_network_interface.director_nic_2.*.private_ip_address[0]}"
}

output "RVBD_Director-1_Public_IP" {
  value = "${data.azurerm_public_ip.dir_pub_ip.*.ip_address[0]}"
}

output "RVBD_Director-1_SSH_Command" {
  value = "ssh -i id_rsa Administrator@${data.azurerm_public_ip.dir_pub_ip.*.ip_address[0]}"
}

output "RVBD_Director-1_UI_Login" {
  value = "https://${data.azurerm_public_ip.dir_pub_ip.*.ip_address[0]}\n"
}

output "RVBD_Director-2_Instance" {
  value = "${azurerm_virtual_machine.directorVM.*.name[1]}"
}

output "RVBD_Director-2_MGMT_IP" {
  value = "${azurerm_network_interface.director_nic_1.*.private_ip_address[1]}"
}

output "RVBD_Director-2_South_IP" {
  value = "${azurerm_network_interface.director_nic_2.*.private_ip_address[1]}"
}

output "RVBD_Director-2_Public_IP" {
  value = "${data.azurerm_public_ip.dir_pub_ip.*.ip_address[1]}"
}

output "RVBD_Director-2_SSH_Command" {
  value = "ssh -i id_rsa Administrator@${data.azurerm_public_ip.dir_pub_ip.*.ip_address[1]}"
}

output "RVBD_Director-2_UI_Login" {
  value = "https://${data.azurerm_public_ip.dir_pub_ip.*.ip_address[1]}\n"
}

output "RVBD_Router-1_Instance" {
  value = "${azurerm_virtual_machine.routerVM.*.name[0]}"
}

output "RVBD_Router-1_MGMT_IP" {
  value = "${azurerm_network_interface.router_nic_1.*.private_ip_address[0]}"
}

output "RVBD_Router-1_To_Director_IP" {
  value = "${azurerm_network_interface.router_nic_2.*.private_ip_address[0]}"
}

output "RVBD_Router-1_To_Peer_Router_IP" {
  value = "${azurerm_network_interface.router_nic_3.*.private_ip_address[0]}\n"
}

output "RVBD_Router-1_To_Controller_IP" {
  value = "${azurerm_network_interface.router_nic_4.*.private_ip_address[0]}"
}

output "RVBD_Router-1_Public_IP" {
  value = "${data.azurerm_public_ip.router_pub_ip.*.ip_address[0]}"
}

output "RVBD_Router-1_SSH_Command" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.router_pub_ip.*.ip_address[0]}"
}

output "RVBD_Router-2_Instance" {
  value = "${azurerm_virtual_machine.routerVM.*.name[1]}"
}

output "RVBD_Router-2_MGMT_IP" {
  value = "${azurerm_network_interface.router_nic_1.*.private_ip_address[1]}"
}

output "RVBD_Router-2_To_Director_IP" {
  value = "${azurerm_network_interface.router_nic_2.*.private_ip_address[1]}"
}

output "RVBD_Router-2_To_Peer_Router_IP" {
  value = "${azurerm_network_interface.router_nic_3.*.private_ip_address[1]}\n"
}

output "RVBD_Router-2_To_Controller_IP" {
  value = "${azurerm_network_interface.router_nic_4.*.private_ip_address[1]}"
}

output "RVBD_Router-2_Public_IP" {
  value = "${data.azurerm_public_ip.router_pub_ip.*.ip_address[1]}"
}

output "RVBD_Router-2_SSH_Command" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.router_pub_ip.*.ip_address[1]}"
}

output "RVBD_Controller-1_Instance" {
  value = "${azurerm_virtual_machine.controllerVM.*.name[0]}"
}

output "RVBD_Controller-1_MGMT_IP" {
  value = "${azurerm_network_interface.controller_nic_1.*.private_ip_address[0]}"
}

output "RVBD_Controller-1_To_Router_IP" {
  value = "${azurerm_network_interface.controller_nic_2.*.private_ip_address[0]}"
}

output "RVBD_Controller-1_WAN_Private_IP" {
  value = "${azurerm_network_interface.controller_nic_3.*.private_ip_address[0]}"
}

output "RVBD_Controller-1_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[0]}"
}

output "RVBD_Controller-1_SSH_Command" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[0]}"
}

output "RVBD_Controller-1_WAN_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_wan_pub_ip.*.ip_address[0]}\n"
}

output "RVBD_Controller-2_Instance" {
  value = "${azurerm_virtual_machine.controllerVM.*.name[1]}"
}

output "RVBD_Controller-2_MGMT_IP" {
  value = "${azurerm_network_interface.controller_nic_1.*.private_ip_address[1]}"
}

output "RVBD_Controller-2_To_Router_IP" {
  value = "${azurerm_network_interface.controller_nic_2.*.private_ip_address[1]}"
}

output "RVBD_Controller-2_WAN_Private_IP" {
  value = "${azurerm_network_interface.controller_nic_3.*.private_ip_address[1]}"
}

output "RVBD_Controller-2_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[1]}"
}

output "RVBD_Controller-2_SSH_Command" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[1]}"
}

output "RVBD_Controller-2_WAN_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_wan_pub_ip.*.ip_address[1]}\n"
}

output "RVBD_Analytics_Cluster_Mgmt_IPs" {
  value = local.hostmap_analytics
}

output "RVBD_Analytics_Forwarder_Mgmt_IPs" {
  value = local.hostmap_forwarder
}

output "RVBD_Analytics_Cluster_Public_IPs" {
  value = local.pubmap_analytics
}

output "RVBD_Analytics_Forwarder_Public_IPs" {
  value = local.pubmap_forwarder
}

output "RVBD_Analytics_Cluster_South_IPs" {
  value = local.southmap_analytics
}

output "RVBD_Analytics_Forwarder_South_IPs" {
  value = local.southmap_forwarder
}

output "RVBD_Analytics_Cluster_Internal_IPs" {
  value = local.clustmap_analytics
}

output "RVBD_Analytics_Forwarder_Internal_IPs" {
  value = local.clustmap_forwarder
}
