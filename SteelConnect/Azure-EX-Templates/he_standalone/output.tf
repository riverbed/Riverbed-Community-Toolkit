output "director_hostname" {
  value = "${var.hostname_director}"
  description = "SteelConnect-EX Director hostname"
}

output "admin_gui_director" {
  value = "https://${data.azurerm_public_ip.dir_pub_ip.ip_address}"
  description = "Director - webconsole"
}

output "admin_ssh_director" {
  value = "ssh -i sshkey Administrator@${data.azurerm_public_ip.dir_pub_ip.ip_address}\n"
  description = "Director - SSH command"
}

output "director_mgmt_public_ip" {
  value = "${data.azurerm_public_ip.dir_pub_ip.ip_address}"
  description = "Director - Public IP (Management)"
}

output "director_mgmt_ip" {
  value = "${azurerm_network_interface.director_nic_1.private_ip_address}"
  description = "Director - Management IP"
}

output "analytics_hostname" {
  value = "${var.hostname_analytics}"
    description = "SteelConnect-EX Analytics hostname"
}

output "admin_gui_riverbed_analytics" {
  value = "http://${data.azurerm_public_ip.van_pub_ip.ip_address}:8080\n"
  description = "Analytics - webconsole"
}

output "admin_ssh_analytics" {
  value = "ssh -i sshkey versa@${data.azurerm_public_ip.van_pub_ip.ip_address}"
  description = "Analytics - SSH command"
}

output "analytics_mgmt_public_ip" {
  value = "${data.azurerm_public_ip.van_pub_ip.ip_address}"
  description = "Analytics - Public IP (Management)"
}

output "analytics_northbound_ip_management_subnet" {
  value = "${azurerm_network_interface.van_nic_1.private_ip_address}"
  description = "Analytics - Management IP (North-bound)"
}

output "analytics_southbound_ip_control_subnet" {
  value = "${azurerm_network_interface.van_nic_2.private_ip_address}"
  description = "Analytics - Control IP (South-bound)"
}

output "analytics_southbound_port" {
  value = "${var.analytics_port}"
  description = "Analytics - Control Port (South-bound)"
}

output "controller_hostname" {
  value = "${var.hostname_controller}"
  description = "SteelConnect-EX Controller hostname"
}

output "admin_ssh_controller" {
  value = "ssh -i sshkey admin@${data.azurerm_public_ip.ctrl_pub_ip.ip_address}"
  description = "Controller - SSH Command"
}

output "controller_ip_address" {
  value = "${azurerm_network_interface.controller_nic_1.private_ip_address}"
  description = "Controller - Management IP (General IP Address)"
}

output "controller_control_network_ip_prefix" {
  value = "${azurerm_network_interface.controller_nic_2.private_ip_address}/${16+var.newbits_subnet}"
  description = "Controller - Control IP (Control Network IP/Prefix)"
}

output "controller_wan_interface_ip_prefix" {
  value = "${azurerm_network_interface.controller_nic_3.private_ip_address}/${16+var.newbits_subnet}"
  description = "Controller - Internet Uplink Private IP (WAN Interface, Address)"
}

output "controller_wan_interface_gw_ip" {
  value = "${cidrhost(azurerm_subnet.wan_network_subnet.address_prefix,1)}"
  description = "Controller - Internet Uplink Gateway (WAN Interface, Gateway)"
}

output "controller_wan_interface_public_ip" {
  value = "${data.azurerm_public_ip.ctrl_wan_pub_ip.ip_address}"
  description = "Controller - Internet Uplink Public IP (WAN Interface, Public IP Address)"
}


output "overlay_range" {
  value = "${var.overlay_network}"
  description = "SteelConnect-EX Overlay prefix "
}