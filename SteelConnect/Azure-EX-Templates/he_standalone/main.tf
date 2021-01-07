# Riverbed Community Toolkit
# SteelConnect-EX Standalone Headend - Terraform template

# Configure the Microsoft Azure Provider
provider "azurerm" {
    version = "~>2.0.0"
    subscription_id = var.subscription_id
    client_id       = var.client_id
    client_secret   = var.client_secret
    tenant_id       = var.tenant_id
    features {}
}

# Create a resource group
resource "azurerm_resource_group" "rvbd_rg" {
    name     = var.resource_group
    location = var.location

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Add template to use custom data for Director:
data "template_file" "user_data_dir" {
  template = file("director.sh")
  
  vars = {
    sshkey = var.ssh_key
    hostname_dir = var.hostname_director
    hostname_van = var.hostname_analytics
    dir_mgmt_ip = azurerm_network_interface.director_nic_1.private_ip_address
    dir_ctrl_ip = azurerm_network_interface.director_nic_2.private_ip_address
    van_mgmt_ip = azurerm_network_interface.van_nic_1.private_ip_address
    ctrl_net = azurerm_subnet.control_subnet.address_prefix
    overlay_net = var.overlay_network    

    # assuming the control subnet is a /24, the hostnum of the Azure default gw is .1
    # TODO: variabilize instead of hardcoding
    azure_default_gw_ip_subnet_control = cidrhost(azurerm_subnet.control_subnet.address_prefix,1)
  }
}

# Add template to use custom data for Controller:
data "template_file" "user_data_ctrl" {
  template = file("controller.sh")
  
  vars = {
	sshkey = var.ssh_key
	dir_mgmt_ip = azurerm_network_interface.director_nic_1.private_ip_address
  }
}

# Add template to use custom data for Controller:
data "template_file" "user_data_van" {
  template = file("analytics.sh")
  
  vars = {
    sshkey = var.ssh_key
    hostname_dir = var.hostname_director
    hostname_van = var.hostname_analytics
    dir_mgmt_ip = azurerm_network_interface.director_nic_1.private_ip_address
    van_mgmt_ip = azurerm_network_interface.van_nic_1.private_ip_address
    ctrl_net = azurerm_subnet.control_subnet.address_prefix
    overlay_net = var.overlay_network

    # assuming the control subnet is a /24, the hostnum of the Azure default gw is .1
    # TODO: variabilize instead of hardcoding
    azure_default_gw_ip_subnet_control = cidrhost(azurerm_subnet.control_subnet.address_prefix,1)

    analytics_control_ip = azurerm_network_interface.van_nic_2.private_ip_address
    analytics_port = var.analytics_port
  }
}

# Create virtual network
resource "azurerm_virtual_network" "rvbdNetwork" {
    name                = "SteelConnect-EX_Headend"
    address_space       = [var.vnet_address_space]
    location            = var.location
    resource_group_name = azurerm_resource_group.rvbd_rg.name

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}

    subnet {
        # Define a Bastion subnet for future needs
        name           = "BastionSubnet"
        address_prefix = cidrsubnet(var.vnet_address_space,var.newbits_subnet,0)
    }
}

# Management Subnet for Director, Controller and Analytics
resource "azurerm_subnet" "management_subnet" {
    name                 = "Management"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
	address_prefix       = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",1)
}

# Control Subnet for Director, Controller and Analytics
resource "azurerm_subnet" "control_subnet" {
    name                 = "Control"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
    address_prefix       = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",2)
}

# Define an Analytics Subnet for future need (multiple Analytics nodes)
resource "azurerm_subnet" "analytics_subnet" {
    name                 = "Analytics"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
    address_prefix       = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",3)
}

# WAN Uplink Subnet for Controller
resource "azurerm_subnet" "wan_network_subnet" {
    name                 = "Internet-Uplink"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
    address_prefix       = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",254)
}

# Route Table for the Control subnet
resource "azurerm_route_table" "route_table_control" {
    name                = "SteelConnect-EX_Control"
    location            = var.location
    resource_group_name = azurerm_resource_group.rvbd_rg.name
}

# Route to forward all the traffic to the Controller interface connected to the control subnet
resource "azurerm_route" "route_to_controller" {
    name                = "default-via-controller"
    resource_group_name = azurerm_resource_group.rvbd_rg.name
    route_table_name    = azurerm_route_table.route_table_control.name
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.controller_nic_2.private_ip_address
}

# Associate Route to the Route Table of the Control subnet 
resource "azurerm_subnet_route_table_association" "control_subnet_route_table_association" {
    subnet_id = azurerm_subnet.control_subnet.id
    route_table_id = azurerm_route_table.route_table_control.id
}

# Public IP for Director Management interface
resource "azurerm_public_ip" "ip_dir" {
    name                         = "SteelConnect-EX_Director_Management"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Public IP for Controller Management interface
# TODO: remove if not necessary to have a management public IP on the controller
resource "azurerm_public_ip" "ip_ctrl" {
    name                         = "SteelConnect-EX_Controller_Management"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Public IP for Controller WAN Interface
resource "azurerm_public_ip" "ip_ctrl_wan" {
    name                         = "SteelConnect-EX_Controller-Internet-Uplink"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Static"

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Public IP for Analytics Management interface
resource "azurerm_public_ip" "ip_van" {
    name                         = "SteelConnect-EX_Analytics-Management"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Dynamic"

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Network Security Group and rules
resource "azurerm_network_security_group" "rvbd_nsg" {
    name							= "SteelConnect-EX_Headend"
    location						= var.location
    resource_group_name				= azurerm_resource_group.rvbd_rg.name
    tags = map("Riverbed-Community", "SteelConnect-EX_Headend")
}

# Security group rules
# TODO: limit exposure on Internet
resource "azurerm_network_security_rule" "rvbd_nsg_rule1" {
	name                       = "SteelConnect-EX_ICMP"
	description                = "Simple rule allowing all TCP"
	priority                   = 101
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "Icmp"
	source_port_range          = "*"
	destination_port_range     = "*"
	source_address_prefix      = "*"
	destination_address_prefix = azurerm_network_interface.controller_nic_3.private_ip_address
	resource_group_name        = azurerm_resource_group.rvbd_rg.name
	network_security_group_name = azurerm_network_security_group.rvbd_nsg.name
}

resource "azurerm_network_security_rule" "rvbd_nsg_rule2" {
	name                       = "SteelConnect-EX_TCP"
	description                = "Simple rule allowing all TCP"
	priority                   = 151
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "Tcp"
	source_port_range          = "*"
	destination_port_ranges     = ["22", "9182-9183", "443", "8009", "9080", "2024", "4566", "4570", "8443", "5432", "9090", "4949", "6080", "20514", "80", "2022", "2812", "3000-3002", "4000", "4566", "4570", "5000", "7000-7001", "7199", "8008", "8080", "8983", "9042", "9160", "1234"]
	source_address_prefix      = "*"
	destination_address_prefix = "*"
	resource_group_name        = azurerm_resource_group.rvbd_rg.name
	network_security_group_name = azurerm_network_security_group.rvbd_nsg.name
}
resource "azurerm_network_security_rule" "rvbd_nsg_rule3" {
	name                       = "SteelConnect-EX_UDP"
	description                = "Simple rule allowing all UDP"
	priority                   = 201
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "Udp"
	source_port_range          = "*"
	destination_port_ranges    = ["20514", "53", "123", "500", "4500", "4790"] 
	source_address_prefix      = "*"
	destination_address_prefix = "*"
	resource_group_name        = azurerm_resource_group.rvbd_rg.name
	network_security_group_name = azurerm_network_security_group.rvbd_nsg.name
}
resource "azurerm_network_security_rule" "rvbd_nsg_rule4" {
	name                       = "SteelConnect-EX_Outbound"
	description                = "Simple rule allowing all Outbound"
	priority                   = 251
	direction                  = "Outbound"
	access                     = "Allow"
	protocol                   = "*"
	source_port_range          = "*"
	destination_port_range     = "*"
	source_address_prefix      = "*"
	destination_address_prefix = "*"
	resource_group_name        = azurerm_resource_group.rvbd_rg.name
	network_security_group_name = azurerm_network_security_group.rvbd_nsg.name
}
resource "azurerm_network_security_rule" "rvbd_nsg_rule5" {
	name                       = "SteelConnect-EX_Inbound"
	description                = "Simple rule allowing any inbound initiated from the VNET"
	priority                   = 301
	direction                  = "Inbound"
	access                     = "Allow"
	protocol                   = "*"
	source_port_range          = "*"
	destination_port_range     = "*"
	source_address_prefix      = "VirtualNetwork"
	destination_address_prefix = "*"
	resource_group_name        = azurerm_resource_group.rvbd_rg.name
	network_security_group_name = azurerm_network_security_group.rvbd_nsg.name
}

# Create network security group subnet associations 
resource "azurerm_subnet_network_security_group_association" "mgmt_sec_assoc" {
  subnet_id                 = azurerm_subnet.management_subnet.id
  network_security_group_id = azurerm_network_security_group.rvbd_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "ctrl_sec_assoc" {
  subnet_id                 = azurerm_subnet.control_subnet.id
  network_security_group_id = azurerm_network_security_group.rvbd_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "wan_sec_assoc" {
  subnet_id                 = azurerm_subnet.wan_network_subnet.id
  network_security_group_id = azurerm_network_security_group.rvbd_nsg.id
}

# Create Management network interface for Director
resource "azurerm_network_interface" "director_nic_1" {
    name                      = "SteelConnect-EX_Director_NIC1"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "Director_NIC1_Configuration"
        subnet_id                     = azurerm_subnet.management_subnet.id
        # private_ip_address_allocation = "dynamic"
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.management_subnet.address_prefix,var.hostnum_director)

        public_ip_address_id          = azurerm_public_ip.ip_dir.id
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Create Southbound network interface for Director
resource "azurerm_network_interface" "director_nic_2" {
    name                      = "SteelConnect-EX_Director_NIC2"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "Director_NIC2_Configuration"
        subnet_id                     = azurerm_subnet.control_subnet.id
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.control_subnet.address_prefix,var.hostnum_director)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Create Management network interface for Controller
resource "azurerm_network_interface" "controller_nic_1" {
    name                      = "SteelConnect-EX_Controller_NIC1"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "Controller_NIC1_Configuration"
        subnet_id                     = azurerm_subnet.management_subnet.id
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.management_subnet.address_prefix,var.hostnum_controller)

        # TODO: remove to limit internet exposure
        public_ip_address_id          = azurerm_public_ip.ip_ctrl.id
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Create Northbound/Control network interface for Controller
resource "azurerm_network_interface" "controller_nic_2" {
    name                      = "SteelConnect-EX_Controller_NIC2"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name
	enable_ip_forwarding      = "true"

    # TODO: uncomment when accelerated networking/dpdk is supported
    # enable_accelerated_networking = "true"

    ip_configuration {
        name                          = "Controller_NIC2_Configuration"
        subnet_id                     = azurerm_subnet.control_subnet.id
        # private_ip_address_allocation = "dynamic"
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.control_subnet.address_prefix,var.hostnum_controller)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Create Southbound/WAN network interface for Controller
resource "azurerm_network_interface" "controller_nic_3" {
    name                      = "SteelConnect-EX_Controller_NIC3"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name
    
    # TODO: uncomment when accelerated networking/dpdk is supported
    # enable_accelerated_networking = "true"

    ip_configuration {
        name                          = "Controller_NIC3_Configuration"
        subnet_id                     = azurerm_subnet.wan_network_subnet.id
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.wan_network_subnet.address_prefix,var.hostnum_controller)
		public_ip_address_id		  = azurerm_public_ip.ip_ctrl_wan.id
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Create Management network interface for Analytics
resource "azurerm_network_interface" "van_nic_1" {
    name                      = "SteelConnect-EX_Analytics_NIC1"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "VAN_NIC1_Configuration"
        subnet_id                     = azurerm_subnet.management_subnet.id
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.management_subnet.address_prefix,var.hostnum_analytics)
        public_ip_address_id          = azurerm_public_ip.ip_van.id
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Create Southbound network interface for Analytics
resource "azurerm_network_interface" "van_nic_2" {
    name                      = "SteelConnect-EX_Analytics_NIC2"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "VAN_NIC2_Configuration"
        subnet_id                     = azurerm_subnet.control_subnet.id
        private_ip_address_allocation = "static"
        private_ip_address = cidrhost(azurerm_subnet.control_subnet.address_prefix,var.hostnum_analytics)
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rvbd_rg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storageAccountDiagnostic" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rvbd_rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# SteelConnect-EX Director Virtual Machine
resource "azurerm_virtual_machine" "directorVM" {
    name                  = "SteelConnect-EX_Director"

	depends_on            = [
        #try the following dependency to workaround the image first boot issue impacting cloud-init: DataSourceAzure.py[WARNING]: /dev/sr0 was not mountable
        azurerm_subnet_network_security_group_association.mgmt_sec_assoc,
        azurerm_subnet_network_security_group_association.ctrl_sec_assoc
    ]

    location              = var.location
    resource_group_name   = azurerm_resource_group.rvbd_rg.name
    network_interface_ids = [azurerm_network_interface.director_nic_1.id, azurerm_network_interface.director_nic_2.id]
	primary_network_interface_id = azurerm_network_interface.director_nic_1.id
    vm_size               = var.director_vm_size

    storage_os_disk {
        name              = "SteelConnect-EX_Director_OSDisk"
        create_option     = "FromImage"
    }

    storage_image_reference {
        id=var.image_director
    }

    os_profile {
        computer_name  = var.hostname_director
        custom_data = data.template_file.user_data_dir.rendered

        # admin_username is required by the template but the user account will be created on the vm
        admin_username = "riverbed-community"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/riverbed-community/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.storageAccountDiagnostic.primary_blob_endpoint
    }
	
    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# SteelConnect-EX Controller Virtual Machine
resource "azurerm_virtual_machine" "controllerVM" {
    name                  = "SteelConnect-EX_Controller"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rvbd_rg.name
    network_interface_ids = [azurerm_network_interface.controller_nic_1.id, azurerm_network_interface.controller_nic_2.id, azurerm_network_interface.controller_nic_3.id]
	primary_network_interface_id = azurerm_network_interface.controller_nic_1.id
    vm_size               = var.controller_vm_size
	
    storage_os_disk {
        name              = "SteelConnect-EX_Controller_OSDisk"
        create_option     = "FromImage"
    }

    storage_image_reference {
        id=var.image_controller
    }

    os_profile {
        computer_name  = var.hostname_controller
        custom_data = data.template_file.user_data_ctrl.rendered

        # admin_username is required by the template but the user account will be created on the vm
        admin_username = "riverbed-community"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/riverbed-community/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.storageAccountDiagnostic.primary_blob_endpoint
    }
	
    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

# SteelConnect-EX Analytics Virtual Machine
resource "azurerm_virtual_machine" "vanVM" {
    name                  = "SteelConnect-EX_Analytics"

    depends_on            = [
        #try the following dependency to workaround an image issue with cloud-init: DataSourceAzure.py[WARNING]: /dev/sr0 was not mountable
        azurerm_subnet_network_security_group_association.mgmt_sec_assoc,
        azurerm_subnet_network_security_group_association.ctrl_sec_assoc,

        # analytics initialization script (analytics.sh) requires director to be up and running
        azurerm_virtual_machine.directorVM
    ]

    location              = var.location
    resource_group_name   = azurerm_resource_group.rvbd_rg.name
    network_interface_ids = [azurerm_network_interface.van_nic_1.id, azurerm_network_interface.van_nic_2.id]
	primary_network_interface_id = azurerm_network_interface.van_nic_1.id
    vm_size               = var.analytics_vm_size

    storage_os_disk {
        name              = "SteelConnect-EX_Analytics_OSDisk"
        create_option     = "FromImage"
    }

    storage_image_reference {
        id=var.image_analytics
    }

    os_profile {
        computer_name  = var.hostname_analytics
        custom_data = data.template_file.user_data_van.rendered

        # admin_username is required by the template but the user account will be created on the vm
        admin_username = "riverbed-community"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/riverbed-community/.ssh/authorized_keys"
            key_data = var.ssh_key
        }
    }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.storageAccountDiagnostic.primary_blob_endpoint
    }

    tags = {"Riverbed-Community" = "SteelConnect-EX_Headend"}
}

data "azurerm_public_ip" "dir_pub_ip" {
  name = azurerm_public_ip.ip_dir.name
  resource_group_name   = azurerm_resource_group.rvbd_rg.name
  depends_on = [azurerm_virtual_machine.directorVM]
}

data "azurerm_public_ip" "ctrl_pub_ip" {
  name = azurerm_public_ip.ip_ctrl.name
  resource_group_name   = azurerm_resource_group.rvbd_rg.name
  depends_on = [azurerm_virtual_machine.controllerVM]
}

data "azurerm_public_ip" "van_pub_ip" {
  name = azurerm_public_ip.ip_van.name
  resource_group_name   = azurerm_resource_group.rvbd_rg.name
  depends_on = [azurerm_virtual_machine.vanVM]
}

data "azurerm_public_ip" "ctrl_wan_pub_ip" {
  name = azurerm_public_ip.ip_ctrl_wan.name
  resource_group_name   = azurerm_resource_group.rvbd_rg.name
  depends_on = [azurerm_virtual_machine.controllerVM]
}
