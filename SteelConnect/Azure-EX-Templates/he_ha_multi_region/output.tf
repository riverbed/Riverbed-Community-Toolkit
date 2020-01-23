output "RVBD_Director-1_Instance" {
  value = "${azurerm_virtual_machine.directorVM.*.name[0]}"
}

output "RVBD_Director-1_MGMT_IP" {
  value = "${azurerm_network_interface.director_nic_1.*.private_ip_address[0]}"
}

output "RVBD_Director-1_Public_IP" {
  value = "${data.azurerm_public_ip.dir_pub_ip.*.ip_address[0]}"
}

output "RVBD_Director-1_CLI_sshCommand" {
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

output "RVBD_Director-2_Public_IP" {
  value = "${data.azurerm_public_ip.dir_pub_ip.*.ip_address[1]}"
}

output "RVBD_Director-2_CLI_sshCommand" {
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

output "RVBD_Router-1_Public_IP" {
  value = "${data.azurerm_public_ip.router_pub_ip.*.ip_address[0]}"
}

output "RVBD_Router-1_CLI_sshCommand" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.router_pub_ip.*.ip_address[0]}"
}

output "RVBD_Router-1_UI_Login" {
  value = "http://${data.azurerm_public_ip.router_pub_ip.*.ip_address[0]}\n"
}

output "RVBD_Router-2_Instance" {
  value = "${azurerm_virtual_machine.routerVM.*.name[1]}"
}

output "RVBD_Router-2_MGMT_IP" {
  value = "${azurerm_network_interface.router_nic_1.*.private_ip_address[1]}"
}

output "RVBD_Router-2_Public_IP" {
  value = "${data.azurerm_public_ip.router_pub_ip.*.ip_address[1]}"
}

output "RVBD_Router-2_CLI_sshCommand" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.router_pub_ip.*.ip_address[1]}"
}

output "RVBD_Router-2_UI_Login" {
  value = "http://${data.azurerm_public_ip.router_pub_ip.*.ip_address[1]}\n"
}

output "RVBD_Controller-1_Instance" {
  value = "${azurerm_virtual_machine.controllerVM.*.name[0]}"
}

output "RVBD_Controller-1_MGMT_IP" {
  value = "${azurerm_network_interface.controller_nic_1.*.private_ip_address[0]}"
}

output "RVBD_Controller-1_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[0]}"
}

output "RVBD_Controller-1_CLI_sshCommand" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[0]}"
}

output "RVBD_Controller-1_UI_Login" {
  value = "http://${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[0]}"
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

output "RVBD_Controller-2_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[1]}"
}

output "RVBD_Controller-2_CLI_sshCommand" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[1]}"
}

output "RVBD_Controller-2_UI_Login" {
  value = "http://${data.azurerm_public_ip.ctrl_pub_ip.*.ip_address[1]}"
}

output "RVBD_Controller-2_WAN_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_wan_pub_ip.*.ip_address[1]}\n"
}

output "RVBD_Analytics-1_Instance" {
  value = "${azurerm_virtual_machine.vanVM.*.name[0]}"
}

output "RVBD_Analytics-1_MGMT_IP" {
  value = "${azurerm_network_interface.van_nic_1.*.private_ip_address[0]}"
}

output "RVBD_Analytics-1_Public_IP" {
  value = "${data.azurerm_public_ip.van_pub_ip.*.ip_address[0]}"
}

output "RVBD_Analytics-1_CLI_sshCommand" {
  value = "ssh -i id_rsa versa@${data.azurerm_public_ip.van_pub_ip.*.ip_address[0]}"
}

output "RVBD_Analytics-1_UI_Login" {
  value = "http://${data.azurerm_public_ip.van_pub_ip.*.ip_address[0]}:8080\n"
}

output "RVBD_Analytics-2_Instance" {
  value = "${azurerm_virtual_machine.vanVM.*.name[1]}"
}

output "RVBD_Analytics-2_MGMT_IP" {
  value = "${azurerm_network_interface.van_nic_1.*.private_ip_address[1]}"
}

output "RVBD_Analytics-2_Public_IP" {
  value = "${data.azurerm_public_ip.van_pub_ip.*.ip_address[1]}"
}

output "RVBD_Analytics-2_CLI_sshCommand" {
  value = "ssh -i id_rsa versa@${data.azurerm_public_ip.van_pub_ip.*.ip_address[1]}"
}

output "RVBD_Analytics-2_UI_Login" {
  value = "http://${data.azurerm_public_ip.van_pub_ip.*.ip_address[1]}:8080\n"
}
