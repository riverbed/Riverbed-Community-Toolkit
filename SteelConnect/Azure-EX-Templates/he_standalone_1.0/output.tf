output "Riverbed_Director_Instance" {
  value = "${azurerm_virtual_machine.directorVM.name}"
}

output "Riverbed_Director_MGMT_IP" {
  value = "${azurerm_network_interface.director_nic_1.private_ip_address}"
}

output "Riverbed_Director_Public_IP" {
  value = "${data.azurerm_public_ip.dir_pub_ip.ip_address}"
}

output "Riverbed_Director_CLI_sshCommand" {
  value = "ssh -i id_rsa Administrator@${data.azurerm_public_ip.dir_pub_ip.ip_address}"
}

output "Riverbed_Director_UI_Login" {
  value = "https://${data.azurerm_public_ip.dir_pub_ip.ip_address}\n"
}

output "Riverbed_Controller_Instance" {
  value = "${azurerm_virtual_machine.controllerVM.name}"
}

output "Riverbed_Controller_MGMT_IP" {
  value = "${azurerm_network_interface.controller_nic_1.private_ip_address}"
}

output "Riverbed_Controller_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_pub_ip.ip_address}"
}

output "Riverbed_Controller_CLI_sshCommand" {
  value = "ssh -i id_rsa admin@${data.azurerm_public_ip.ctrl_pub_ip.ip_address}"
}

output "Riverbed_Controller_UI_Login" {
  value = "http://${data.azurerm_public_ip.ctrl_pub_ip.ip_address}"
}

output "Riverbed_Controller_WAN_Public_IP" {
  value = "${data.azurerm_public_ip.ctrl_wan_pub_ip.ip_address}\n"
}

output "Riverbed_Analytics_Instance" {
  value = "${azurerm_virtual_machine.vanVM.name}"
}

output "Riverbed_Analytics_MGMT_IP" {
  value = "${azurerm_network_interface.van_nic_1.private_ip_address}"
}

output "Riverbed_Analytics_Public_IP" {
  value = "${data.azurerm_public_ip.van_pub_ip.ip_address}"
}

output "Riverbed_Analytics_CLI_sshCommand" {
  value = "ssh -i id_rsa versa@${data.azurerm_public_ip.van_pub_ip.ip_address}"
}

output "Riverbed_Analytics_UI_Login" {
  value = "http://${data.azurerm_public_ip.van_pub_ip.ip_address}:8080\n"
}
