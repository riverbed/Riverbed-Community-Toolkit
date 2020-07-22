# Riverbed Community Toolkit
# SteelConnect-EX High Availability Headend - Terraform template

# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>2.0.0"
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    features {}
}

# Create a resource group in each region
resource "azurerm_resource_group" "rvbd_rg" {
    count    = length(var.location)
    name     = "${var.resource_group}-${1+count.index}"
    location = element(var.location, count.index)

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Add template to use custom data for Director:
data "template_file" "user_data_dir" {
  count			= length(var.location)
  template = file("director-${1+count.index}.sh")
  
  vars = {
    hostname_dir_master = var.hostname_director[0],
	hostname_dir_slave = var.hostname_director[1],
        dir_master_mgmt_ip = azurerm_network_interface.director_nic_1.0.private_ip_address,
        dir_master_ctrl_ip = azurerm_network_interface.director_nic_2.0.private_ip_address,
	dir_slave_mgmt_ip = azurerm_network_interface.director_nic_1.1.private_ip_address,
	dir_slave_ctrl_ip = azurerm_network_interface.director_nic_2.1.private_ip_address,
	router1_dir_ip = azurerm_network_interface.router_nic_2.0.private_ip_address,
	router2_dir_ip = azurerm_network_interface.router_nic_2.1.private_ip_address,
	mgmt_master_net = azurerm_subnet.mgmt_subnet.0.address_prefix,
	mgmt_slave_net = azurerm_subnet.mgmt_subnet.1.address_prefix,
	ctrl_master_net = azurerm_subnet.control_network_subnet.0.address_prefix,
	ctrl_slave_net = azurerm_subnet.control_network_subnet.1.address_prefix,
	master_net = var.vpc_address_space[0],
	slave_net = var.vpc_address_space[1],
	overlay_net = var.overlay_network,
	hostname_van_1 = var.hostname_van[0],
	hostname_van_2 = var.hostname_van[1],
	van_1_mgmt_ip = azurerm_network_interface.van_nic_1.0.private_ip_address,
	van_1_ctrl_ip = azurerm_network_interface.van_nic_2.0.private_ip_address,
	van_2_mgmt_ip = azurerm_network_interface.van_nic_1.1.private_ip_address,
	van_2_ctrl_ip = azurerm_network_interface.van_nic_2.1.private_ip_address,
	sshkey = var.ssh_key
  }
}

# Add template to use custom data for Controller:
data "template_file" "user_data_ctrl" {
  template = file("controller.sh")
  
  vars = {
	sshkey = var.ssh_key,
    dir_master_mgmt_ip = azurerm_network_interface.director_nic_1.0.private_ip_address,
	dir_slave_mgmt_ip = azurerm_network_interface.director_nic_1.1.private_ip_address
  }
}

# Add template to use custom data for Analytics:
data "template_file" "user_data_van" {
  count			= length(var.location)
  template = file("van-${1+count.index}.sh")
  
  vars = {
    hostname_dir_master = var.hostname_director[0],
	hostname_dir_slave	= var.hostname_director[1],
    dir_master_mgmt_ip = azurerm_network_interface.director_nic_1.0.private_ip_address,
	dir_slave_mgmt_ip = azurerm_network_interface.director_nic_1.1.private_ip_address,
	hostname_van_1 = var.hostname_van[0],
	hostname_van_2	= var.hostname_van[1],
	van_1_mgmt_ip = azurerm_network_interface.van_nic_1.0.private_ip_address,
        van_1_ctrl_ip = azurerm_network_interface.van_nic_2.0.private_ip_address,
	van_2_mgmt_ip = azurerm_network_interface.van_nic_1.1.private_ip_address,
        van_2_ctrl_ip = azurerm_network_interface.van_nic_2.1.private_ip_address,
        router1_dir_ip = azurerm_network_interface.router_nic_2.0.private_ip_address,
        router2_dir_ip = azurerm_network_interface.router_nic_2.1.private_ip_address,
        mgmt_master_net = azurerm_subnet.mgmt_subnet.0.address_prefix,
        mgmt_slave_net = azurerm_subnet.mgmt_subnet.1.address_prefix,
        ctrl_master_net = azurerm_subnet.control_network_subnet.0.address_prefix,
        ctrl_slave_net = azurerm_subnet.control_network_subnet.1.address_prefix,
        master_net = var.vpc_address_space[0],
        slave_net = var.vpc_address_space[1],
        overlay_net = var.overlay_network,
	sshkey = var.ssh_key
  }
}

# Create virtual network in each region
resource "azurerm_virtual_network" "rvbdNetwork" {
    count				= length(var.location)
    name				= "SteelConnect-EX_Headend-${1+count.index}"
	location			= element(var.location, count.index)
	address_space		= [element(var.vpc_address_space, count.index)]
	resource_group_name	= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Route Tables for Director to Router traffic pass through
resource "azurerm_route_table" "rvbd_udr_1" {
    count				= length(var.location)
    name				= "EXRouteTableDir-Router-${1+count.index}"
    location			= element(var.location, count.index)
    resource_group_name	= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
}

# Add CatchAll Route in Route Tables for Director to Router traffic pass through
resource "azurerm_route" "rvbd_route_catchAll" {
    count					= length(var.location)
    name					= "EXRouteDir-CatchAll-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_1.*.name, count.index)
    address_prefix			= "0.0.0.0/0"
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= element(azurerm_network_interface.router_nic_2.*.private_ip_address, count.index)
}

# Add Controller Route in Route Tables for Director to Router traffic
resource "azurerm_route" "rvbd_dirroute_ctrlrNet" {
    count					= length(var.location)
    name					= "EXRouteDir-Controller-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_1.*.name, count.index)
    address_prefix			= element(azurerm_subnet.control_network_subnet.*.address_prefix, count.index)
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= element(azurerm_network_interface.router_nic_2.*.private_ip_address, count.index)
}

# Add Peer Vnet Route in Route Tables for Director to Router traffic
resource "azurerm_route" "rvbd_dirroute_peerNet" {
    count					= length(var.location)
    name					= "EXRouteDir-PeerNet-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_1.*.name, count.index)
    address_prefix			= count.index == 0 ? var.vpc_address_space[1] : var.vpc_address_space[0]
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= element(azurerm_network_interface.router_nic_2.*.private_ip_address, count.index)
}

# Create Route Tables for Router to Controller traffic pass through
resource "azurerm_route_table" "rvbd_udr_2" {
    count				= length(var.location)
    name				= "EXRouteTableRouter-Ctrl-${1+count.index}"
    location			= element(var.location, count.index)
    resource_group_name	= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
}

# Add Route in Route Tables for Router to Controller traffic pass through
resource "azurerm_route" "rvbd_ctrlroute_catchAll" {
    count					= length(var.location)
    name					= "EXRouteCtrl-catchAll-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_2.*.name, count.index)
    address_prefix			= "0.0.0.0/0"
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= element(azurerm_network_interface.controller_nic_2.*.private_ip_address, count.index)
}

# Add Route in Route Tables for Controller to Director Southbound Network
resource "azurerm_route" "rvbd_ctrlroute_dirNet" {
    count					= length(var.location)
    name					= "EXRouteCtrl-dirNet-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_2.*.name, count.index)
    address_prefix			= element(azurerm_subnet.dir_router_network_subnet.*.address_prefix, count.index)
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= element(azurerm_network_interface.router_nic_4.*.private_ip_address, count.index)
}

# Add Route in Route Tables for Controller to peerNet
resource "azurerm_route" "rvbd_ctrlroute_peerNet" {
    count					= length(var.location)
    name					= "EXRouteCtrl-peerNet-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_2.*.name, count.index)
    address_prefix			= count.index == 0 ? var.vpc_address_space[1] : var.vpc_address_space[0]
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= element(azurerm_network_interface.router_nic_4.*.private_ip_address, count.index)
}

# Create Route Tables for Router to Router traffic pass through
resource "azurerm_route_table" "rvbd_udr_3" {
    count				= length(var.location)
    name				= "EXRouteTableRouter-Router-${1+count.index}"
    location			= element(var.location, count.index)
    resource_group_name	= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
}

# Add Route in Route Tables for Router to Router traffic pass through
resource "azurerm_route" "rvbd_rtrroute_catchAll" {
    count					= length(var.location)
    name					= "EXRouteRouter-catchAll-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_3.*.name, count.index)
    address_prefix			= "0.0.0.0/0"
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= count.index == 0 ? azurerm_network_interface.router_nic_3[1].private_ip_address : azurerm_network_interface.router_nic_3[0].private_ip_address 
}

# Add Route in Route Tables for Router to Router vnet peering
resource "azurerm_route" "rvbd_rtrroute_peerNet" {
    count					= length(var.location)
    name					= "EXRouteRouter-peerNet-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	route_table_name		= element(azurerm_route_table.rvbd_udr_3.*.name, count.index)
    address_prefix			= count.index == 0 ? var.vpc_address_space[1] : var.vpc_address_space[0]
    next_hop_type			= "VirtualAppliance"
    next_hop_in_ip_address	= count.index == 0 ? azurerm_network_interface.router_nic_3[1].private_ip_address : azurerm_network_interface.router_nic_3[0].private_ip_address 
}

# Create Management Subnet in each region
resource "azurerm_subnet" "mgmt_subnet" {
    count					= length(var.location)
    name					= "MGMT-NET-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	virtual_network_name	= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
	address_prefix			= cidrsubnet("${element(azurerm_virtual_network.rvbdNetwork.*.address_space[count.index], count.index)}","${var.newbits_subnet}",1)
}

# Create Traffic Subnet for Director, Router and Analytics
resource "azurerm_subnet" "dir_router_network_subnet" {
    count					= length(var.location)
    name					= "Director-Router-Network-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	virtual_network_name	= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
	address_prefix			= cidrsubnet("${element(azurerm_virtual_network.rvbdNetwork.*.address_space[count.index], count.index)}","${var.newbits_subnet}",2)
}
# Add route table association for Director and Analytics
resource "azurerm_subnet_route_table_association" "dir_router_assoc" {
    count = length(var.location)
    subnet_id = element(azurerm_subnet.dir_router_network_subnet.*.id, count.index)
    route_table_id = element(azurerm_route_table.rvbd_udr_1.*.id, count.index)
}

# Create Traffic Subnet for Router and Router connectivity
resource "azurerm_subnet" "router_network_subnet" {
    count					= length(var.location)
    name					= "Router-Router-Network-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	virtual_network_name	= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
	address_prefix			= cidrsubnet("${element(azurerm_virtual_network.rvbdNetwork.*.address_space[count.index], count.index)}","${var.newbits_subnet}",3)
}
# Add Router to Router route table association
resource "azurerm_subnet_route_table_association" "router_router_assoc" {
    count = length(var.location)
    subnet_id = element(azurerm_subnet.router_network_subnet.*.id, count.index)
    route_table_id = element(azurerm_route_table.rvbd_udr_3.*.id, count.index)
}
# Create Traffic Subnet for Router and Controller (Control Network)
resource "azurerm_subnet" "control_network_subnet" {
    count					= length(var.location)
    name					= "CONTROL-NET-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    virtual_network_name	= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
    address_prefix			= cidrsubnet("${element(azurerm_virtual_network.rvbdNetwork.*.address_space[count.index], count.index)}","${var.newbits_subnet}",4)
}
# Add Control Network route table association
resource "azurerm_subnet_route_table_association" "control_router_assoc" {
    count = length(var.location)
    subnet_id = element(azurerm_subnet.control_network_subnet.*.id, count.index)
    route_table_id = element(azurerm_route_table.rvbd_udr_2.*.id, count.index)
}
# Create Traffic Subnet for Controller and Branch (WAN Network)
resource "azurerm_subnet" "wan_network_subnet" {
    count					= length(var.location)
    name					= "WAN-NET-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	virtual_network_name	= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
	address_prefix			= cidrsubnet("${element(azurerm_virtual_network.rvbdNetwork.*.address_space[count.index], count.index)}","${var.newbits_subnet}",5)
}

# Create Traffic Subnet for Branch and Client (LAN Network)
resource "azurerm_subnet" "lan_network_subnet" {
    count					= length(var.location)
    name					= "LAN-NET-${1+count.index}"
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	virtual_network_name	= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
	address_prefix			= cidrsubnet("${element(azurerm_virtual_network.rvbdNetwork.*.address_space[count.index], count.index)}","${var.newbits_subnet}",6)
}

# Create Public IP for Directors
resource "azurerm_public_ip" "ip_dir" {
    count							= length(var.location)
    name							= "PublicIP_Director-${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    allocation_method	= "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Public IP for Routers
resource "azurerm_public_ip" "ip_router" {
    count							= length(var.location)
    name							= "PublicIP_Router-${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    allocation_method	= "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Public IP for Controllers
resource "azurerm_public_ip" "ip_ctrl" {
    count							= length(var.location)
    name							= "PublicIP_Controller-${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    allocation_method	= "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Public IP for Controllers WAN Interface
resource "azurerm_public_ip" "ip_ctrl_wan" {
    count							= length(var.location)
    name							= "PublicIP_Controller_WAN-${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    allocation_method	= "Static"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Public IP for Analytics
resource "azurerm_public_ip" "ip_van" {
    count							= length(var.location)
    name							= "PublicIP_VAN-${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    allocation_method	= "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}


# Create Network Security Groups and rules
resource "azurerm_network_security_group" "rvbd_nsg" {
    count							= length(var.location)
    name							= "SteelConnect-EX_NSG-${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}
# Create security group rules
resource "azurerm_network_security_rule" "rvbd_nsg_rule1" {
	count = length(var.location) 
	name                       = "SteelConnect-EX_TCP-${1+count.index}"
	description                = "Allow required TCP ports for SteelConnect EX Inbound"
	priority                   = 151
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "Tcp"
	source_port_range          = "*"
	destination_port_ranges     = ["22", "9182-9183", "443", "8009", "9080", "2024", "4566", "4570", "8443", "5432", "9090", "4949", "6080", "20514", "80", "2022", "2812", "3000-3002", "4000", "4566", "4570", "5000", "7000-7001", "7199", "8008", "8080", "8983", "9042", "9160", "1234"]
	source_address_prefix      = "*"
	destination_address_prefix = "*"
	resource_group_name        = element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	network_security_group_name = element(azurerm_network_security_group.rvbd_nsg.*.name, count.index)
}
resource "azurerm_network_security_rule" "rvbd_nsg_rule2" {
	count = length(var.location) 
	name                       = "SteelConnect-EX_UDP-${1+count.index}"
	description                = "Allow required UDP ports for SteelConnect EX Inbound"
	priority                   = 201
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "Udp"
	source_port_range          = "*"
	destination_port_ranges    = ["20514", "53", "123", "500", "4500", "4790"] 
	source_address_prefix      = "*"
	destination_address_prefix = "*"
	resource_group_name        = element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	network_security_group_name = element(azurerm_network_security_group.rvbd_nsg.*.name, count.index)
}
resource "azurerm_network_security_rule" "rvbd_nsg_rule3" {
	count = length(var.location) 
	name                       = "SteelConnect-EX_Outbound-${1+count.index}"
	description                = "Allow all ports outbound from the Vnet"
	priority                   = 251
	direction                  = "Outbound"
	access                     = "Allow"
	protocol                   = "*"
	source_port_range          = "*"
	destination_port_range     = "*"
	source_address_prefix      = "*"
	destination_address_prefix = "*"
	resource_group_name        = element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	network_security_group_name = element(azurerm_network_security_group.rvbd_nsg.*.name, count.index)
}
resource "azurerm_network_security_rule" "rvbd_nsg_rule4" {
	count = length(var.location) 
	name                       = "SteelConnect-EX_Inbound-${1+count.index}"
	description                = "Allow all ports inbound from within the Vnet"
	priority                   = 301
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "*"
	source_port_range          = "*"
	destination_port_range     = "*"
	source_address_prefix      = "VirtualNetwork"
	destination_address_prefix = "*"
	resource_group_name        = element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	network_security_group_name = element(azurerm_network_security_group.rvbd_nsg.*.name, count.index)
}

# Create security group subnet associations
resource "azurerm_subnet_network_security_group_association" "mgmt_sec_assoc" {
  count = length(var.location) 
  subnet_id                 = element(azurerm_subnet.mgmt_subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.rvbd_nsg.*.id, count.index)
}
resource "azurerm_subnet_network_security_group_association" "dir_router_sec_assoc" {
  count = length(var.location) 
  subnet_id                 = element(azurerm_subnet.dir_router_network_subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.rvbd_nsg.*.id, count.index) 
}
resource "azurerm_subnet_network_security_group_association" "router_network_sec_assoc" {
  count = length(var.location) 
  subnet_id                 = element(azurerm_subnet.router_network_subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.rvbd_nsg.*.id, count.index) 
}
resource "azurerm_subnet_network_security_group_association" "control_network_sec_assoc" {
  count = length(var.location) 
  subnet_id                 = element(azurerm_subnet.control_network_subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.rvbd_nsg.*.id, count.index) 
}
resource "azurerm_subnet_network_security_group_association" "wan_network_sec_assoc" {
  count = length(var.location) 
  subnet_id                 = element(azurerm_subnet.wan_network_subnet.*.id, count.index)
  network_security_group_id = element(azurerm_network_security_group.rvbd_nsg.*.id, count.index) 
}

# Create Management network interface for Directors
resource "azurerm_network_interface" "director_nic_1" {
    count								= length(var.location)
    name								= "Director_NIC1-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    ip_configuration {
        name							= "Director_NIC1_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.mgmt_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
        public_ip_address_id			= element(azurerm_public_ip.ip_dir.*.id, count.index)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Southbound network interface for Directors
resource "azurerm_network_interface" "director_nic_2" {
    count								= length(var.location)
    name								= "Director_NIC2-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    ip_configuration {
        name							= "Director_NIC2_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.dir_router_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Management network interface for Routers
resource "azurerm_network_interface" "router_nic_1" {
    count								= length(var.location)
    name								= "Router_NIC1-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    ip_configuration {
        name							= "Router_NIC1_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.mgmt_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
		public_ip_address_id			= element(azurerm_public_ip.ip_router.*.id, count.index)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Northbound network interface for Routers
resource "azurerm_network_interface" "router_nic_2" {
    count								= length(var.location)
    name								= "Router_NIC2-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	enable_ip_forwarding				= "true"
    enable_accelerated_networking = "true"
    
    ip_configuration {
        name							= "Router_NIC2_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.dir_router_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create BGP network interface for Routers (Router to Router connectivity)
resource "azurerm_network_interface" "router_nic_3" {
    count								= length(var.location)
    name								= "Router_NIC3-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	enable_ip_forwarding				= "true"
    enable_accelerated_networking = "true"

    ip_configuration {
        name							= "Router_NIC3_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.router_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Southbound network interface for Routers
resource "azurerm_network_interface" "router_nic_4" {
    count								= length(var.location)
    name								= "Router_NIC4-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	enable_ip_forwarding				= "true"
    enable_accelerated_networking = "true"

    ip_configuration {
        name							= "Router_NIC4_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.control_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Management network interface for Controllers
resource "azurerm_network_interface" "controller_nic_1" {
    count								= length(var.location)
    name								= "Controller_NIC1-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    ip_configuration {
        name							= "Controller_NIC1_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.mgmt_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
		public_ip_address_id			= element(azurerm_public_ip.ip_ctrl.*.id, count.index)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Northbound/Control network interface for Controllers
resource "azurerm_network_interface" "controller_nic_2" {
    count								= length(var.location)
    name								= "Controller_NIC2-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
	enable_ip_forwarding				= "true"
    enable_accelerated_networking = "true"

    ip_configuration {
        name							= "Controller_NIC2_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.control_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Southbound/WAN network interface for Controllers
resource "azurerm_network_interface" "controller_nic_3" {
    count								= length(var.location)
    name								= "Controller_NIC3-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    enable_accelerated_networking = "true"
    
    ip_configuration {
        name							= "Controller_NIC3_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.wan_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
		public_ip_address_id			= element(azurerm_public_ip.ip_ctrl_wan.*.id, count.index)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Management network interface for Analytics
resource "azurerm_network_interface" "van_nic_1" {
    count								= length(var.location)
    name								= "VAN_NIC1-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    ip_configuration {
        name							= "VAN_NIC1_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.mgmt_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
		public_ip_address_id			= element(azurerm_public_ip.ip_van.*.id, count.index)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create Southbound network interface for Analytics
resource "azurerm_network_interface" "van_nic_2" {
    count								= length(var.location)
    name								= "VAN_NIC2-${1+count.index}"
    location							= element(var.location, count.index)
    resource_group_name					= element(azurerm_resource_group.rvbd_rg.*.name, count.index)

    ip_configuration {
        name							= "VAN_NIC2_Configuration-${1+count.index}"
		subnet_id						= element(azurerm_subnet.dir_router_network_subnet.*.id, count.index)
        private_ip_address_allocation	= "dynamic"
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Enable global peering between the two virtual network 
resource "azurerm_virtual_network_peering" "peering" {
    count							= length(var.location)
    name							= "VNetPeering-to-${element(azurerm_virtual_network.rvbdNetwork.*.name, 1 - count.index)}"
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    virtual_network_name			= element(azurerm_virtual_network.rvbdNetwork.*.name, count.index)
    remote_virtual_network_id		= element(azurerm_virtual_network.rvbdNetwork.*.id, 1 - count.index)
    allow_virtual_network_access	= true
    allow_forwarded_traffic			= true
    allow_gateway_transit			= false
	depends_on						= [azurerm_virtual_machine.directorVM, azurerm_virtual_machine.routerVM, azurerm_virtual_machine.controllerVM, azurerm_virtual_machine.vanVM]
}
# Create random string generator
resource "random_string" "generator" {
  length = 8
  special = false
  upper = false
}

# Create storage account for boot diagnostics of Director VMs
resource "azurerm_storage_account" "storageaccountDir" {
    count						= length(var.location)
    name						= "dirdiag${1+count.index}${random_string.generator.result}"
    resource_group_name			= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    location					= element(var.location, count.index)
    account_tier				= "Standard"
    account_replication_type	= "LRS"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create storage account for boot diagnostics of Router VMs
resource "azurerm_storage_account" "storageaccountRouter" {
    count						= length(var.location)
    name                        = "routdiag${1+count.index}${random_string.generator.result}"
    resource_group_name			= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    location					= element(var.location, count.index)
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create storage account for boot diagnostics of Controller VMs
resource "azurerm_storage_account" "storageaccountCtrl" {
    count						= length(var.location)
    name                        = "ctrldiag${1+count.index}${random_string.generator.result}"
    resource_group_name			= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    location					= element(var.location, count.index)
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create storage account for boot diagnostics of Analytics VMs
resource "azurerm_storage_account" "storageaccountVAN" {
    count						= length(var.location)
    name                        = "vandiag${1+count.index}${random_string.generator.result}"
    resource_group_name			= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    location					= element(var.location, count.index)
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create SteelConnect-EX Director Virtual Machines
resource "azurerm_virtual_machine" "directorVM" {
    count							= length(var.location)
    name                  			= "SteelConnect-EX_Director${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    network_interface_ids 			= [element(azurerm_network_interface.director_nic_1.*.id, count.index), element(azurerm_network_interface.director_nic_2.*.id, count.index)]
	primary_network_interface_id	= element(azurerm_network_interface.director_nic_1.*.id, count.index)
    vm_size               			= var.director_vm_size

    storage_os_disk {
        name              = "Director_OSDisk-${1+count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=element(var.image_director, count.index)
    }

    os_profile {
        computer_name  = element(var.hostname_director, count.index)
        admin_username = "rvbd_devops"
        custom_data = element(data.template_file.user_data_dir.*.rendered, count.index)
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/rvbd_devops/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = element(azurerm_storage_account.storageaccountDir.*.primary_blob_endpoint, count.index)
    }
	
    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create SteelConnect-EX Router FlexVNF Machines
resource "azurerm_virtual_machine" "routerVM" {
    count							= length(var.location)
    name							= "SteelConnect-EX_Router${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    network_interface_ids			= [element(azurerm_network_interface.router_nic_1.*.id, count.index), element(azurerm_network_interface.router_nic_2.*.id, count.index), element(azurerm_network_interface.router_nic_3.*.id, count.index), element(azurerm_network_interface.router_nic_4.*.id, count.index)]
	primary_network_interface_id	= element(azurerm_network_interface.router_nic_1.*.id, count.index)
    vm_size							= var.router_vm_size
	
    storage_os_disk {
        name              = "Router_OSDisk-${1+count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=element(var.image_controller, count.index)
    }

    os_profile {
        computer_name  = "rvbd-flexvnf"
        admin_username = "rvbd_devops"
        custom_data = data.template_file.user_data_ctrl.rendered
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/rvbd_devops/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = element(azurerm_storage_account.storageaccountRouter.*.primary_blob_endpoint, count.index)
    }
	
    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create SteelConnect-EX Controller Virtual Machines
resource "azurerm_virtual_machine" "controllerVM" {
    count							= length(var.location)
    name							= "SteelConnect-EX_Controller${1+count.index}"
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    network_interface_ids			= [element(azurerm_network_interface.controller_nic_1.*.id, count.index), element(azurerm_network_interface.controller_nic_2.*.id, count.index), element(azurerm_network_interface.controller_nic_3.*.id, count.index)]
	primary_network_interface_id	= element(azurerm_network_interface.controller_nic_1.*.id, count.index)
    vm_size							= var.controller_vm_size
	
    storage_os_disk {
        name              = "Controller_OSDisk-${1+count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=element(var.image_controller, count.index)
    }

    os_profile {
        computer_name  = "rvbd-flexvnf"
        admin_username = "rvbd_devops"
        custom_data = data.template_file.user_data_ctrl.rendered
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/rvbd_devops/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = element(azurerm_storage_account.storageaccountCtrl.*.primary_blob_endpoint, count.index)
    }
	
    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

# Create SteelConnect-EX Analytics Virtual Machines
resource "azurerm_virtual_machine" "vanVM" {
    count							= length(var.location)
    name							= "SteelConnect-EX_Analytics${1+count.index}"
    depends_on            = [
        # analytics initialization script (analytics.sh) requires director to be up and running
        azurerm_virtual_machine.directorVM
    ]
    location						= element(var.location, count.index)
    resource_group_name				= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    network_interface_ids			= [element(azurerm_network_interface.van_nic_1.*.id, count.index), element(azurerm_network_interface.van_nic_2.*.id, count.index)]
	primary_network_interface_id	= element(azurerm_network_interface.van_nic_1.*.id, count.index)
    vm_size							= var.analytics_vm_size

    storage_os_disk {
        name              = "VAN_OSDisk-${1+count.index}"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=element(var.image_analytics, count.index)
    }

    os_profile {
        computer_name  = element(var.hostname_van, count.index)
        admin_username = "rvbd_devops"
        custom_data = element(data.template_file.user_data_van.*.rendered, count.index)
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/rvbd_devops/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = element(azurerm_storage_account.storageaccountVAN.*.primary_blob_endpoint, count.index)
    }
	
    tags = {"Riverbed-Community" = "SteelConnect-EX_HA_Headend"}
}

data "azurerm_public_ip" "dir_pub_ip" {
    count					= length(var.location)
    name					= element(azurerm_public_ip.ip_dir.*.name, count.index)
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    depends_on				= [azurerm_virtual_machine.directorVM]
}

data "azurerm_public_ip" "router_pub_ip" {
    count					= length(var.location)
    name					= element(azurerm_public_ip.ip_router.*.name, count.index)
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    depends_on				= [azurerm_virtual_machine.routerVM]
}

data "azurerm_public_ip" "ctrl_pub_ip" {
    count					= length(var.location)
    name					= element(azurerm_public_ip.ip_ctrl.*.name, count.index)
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    depends_on				= [azurerm_virtual_machine.controllerVM]
}

data "azurerm_public_ip" "van_pub_ip" {
    count					= length(var.location)
    name					= element(azurerm_public_ip.ip_van.*.name, count.index)
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    depends_on				= [azurerm_virtual_machine.vanVM]
}

data "azurerm_public_ip" "ctrl_wan_pub_ip" {
    count					= length(var.location)
    name					= element(azurerm_public_ip.ip_ctrl_wan.*.name, count.index)
    resource_group_name		= element(azurerm_resource_group.rvbd_rg.*.name, count.index)
    depends_on				= [azurerm_virtual_machine.controllerVM]
}
