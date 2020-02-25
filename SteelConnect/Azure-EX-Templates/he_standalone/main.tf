# Configure the Microsoft Azure Provider
provider "azurerm" {
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

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Add template to use custom data for Director:
data "template_file" "user_data_dir" {
  template = file("director.sh")
  
  vars = {
    hostname_dir = var.hostname_director
    hostname_van = var.hostname_analytics
    dir_mgmt_ip = azurerm_network_interface.director_nic_1.private_ip_address
    dir_ctrl_ip = azurerm_network_interface.director_nic_2.private_ip_address
    ctrl_net = azurerm_subnet.ctrl_network_subnet.address_prefix
    sshkey = var.ssh_key
    van_mgmt_ip = azurerm_network_interface.van_nic_1.private_ip_address
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
  template = file("van.sh")
  
  vars = {
    van_mgmt_ip = azurerm_network_interface.van_nic_1.private_ip_address
    van_ctrl_ip = azurerm_network_interface.van_nic_2.private_ip_address
    controller_ip = azurerm_network_interface.controller_nic_2.private_ip_address
    ctrl_net = azurerm_subnet.ctrl_network_subnet.address_prefix
    overlay_net = var.overlay_network
    hostname_dir = var.hostname_director
    hostname_van = var.hostname_analytics
    dir_mgmt_ip = azurerm_network_interface.director_nic_1.private_ip_address
	sshkey = var.ssh_key
  }
}

# Create virtual network
resource "azurerm_virtual_network" "rvbdNetwork" {
    name                = "RVBD_VPC"
    address_space       = [var.vpc_address_space]
    location            = var.location
    resource_group_name = azurerm_resource_group.rvbd_rg.name

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Route Table
resource "azurerm_route_table" "rvbd_udr" {
    name                = "RVBDRouteTable"
    location            = var.location
    resource_group_name = azurerm_resource_group.rvbd_rg.name
}

# Add Route in Route Table
resource "azurerm_route" "rvbd_route" {
    name                = "RVBDRoute"
	resource_group_name = azurerm_resource_group.rvbd_rg.name
	route_table_name    = azurerm_route_table.rvbd_udr.name
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.controller_nic_2.private_ip_address
}

# Create Management Subnet
resource "azurerm_subnet" "mgmt_subnet" {
    name                 = "MGMT-NET"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
	address_prefix = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",1)
}

# Create Traffic Subnet for Director, Controller and Analytics
resource "azurerm_subnet" "ctrl_network_subnet" {
    name                 = "Control-Network"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
	address_prefix = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",2)
}

# Create Traffic Subnet for Controller and Branch
resource "azurerm_subnet" "wan_network_subnet" {
    name                 = "WAN-Network"
    resource_group_name  = azurerm_resource_group.rvbd_rg.name
    virtual_network_name = azurerm_virtual_network.rvbdNetwork.name
	address_prefix = cidrsubnet("${azurerm_virtual_network.rvbdNetwork.address_space.0}","${var.newbits_subnet}",3)
}

# Add route table association for Director and Analytics
resource "azurerm_subnet_route_table_association" "dir_router_assoc" {
    subnet_id = azurerm_subnet.ctrl_network_subnet.id
    route_table_id = azurerm_route_table.rvbd_udr.id
}

# Create Public IP for Director
resource "azurerm_public_ip" "ip_dir" {
    name                         = "PublicIP_Director"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Dynamic"

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Public IP for Controller
resource "azurerm_public_ip" "ip_ctrl" {
    name                         = "PublicIP_Controller"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Dynamic"

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Public IP for Controller WAN Interface
resource "azurerm_public_ip" "ip_ctrl_wan" {
    name                         = "PublicIP_Controller_WAN"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Static"

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Public IP for Analytics
resource "azurerm_public_ip" "ip_van" {
    name                         = "PublicIP_VAN"
    location                     = var.location
    resource_group_name          = azurerm_resource_group.rvbd_rg.name
    allocation_method = "Dynamic"

    tags = {"environment" = "RVBDHeadEndHA"}
}


# Create Network Security Group and rule
resource "azurerm_network_security_group" "rvbd_nsg" {
    name							= "RVBDNSG"
    location						= var.location
    resource_group_name				= azurerm_resource_group.rvbd_rg.name
    tags = map("environment", "RVBDHeadEndHA")
}
# Create security group rules
resource "azurerm_network_security_rule" "rvbd_nsg_rule1" {
	name                       = "RVBD_Security_Rule_TCP"
	description                = "RVBD security group"
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
resource "azurerm_network_security_rule" "rvbd_nsg_rule2" {
	name                       = "RVBD_Security_Rule_UDP"
	description                = "RVBD security group"
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
resource "azurerm_network_security_rule" "rvbd_nsg_rule3" {
	name                       = "RVBD_Security_Rule_Outbound"
	description                = "RVBD security group"
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
resource "azurerm_network_security_rule" "rvbd_nsg_rule4" {
	name                       = "RVBD_Security_Rule_Outbound"
	description                = "RVBD security group"
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
  subnet_id                 = azurerm_subnet.mgmt_subnet.id
  network_security_group_id = azurerm_network_security_group.rvbd_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "ctrl_sec_assoc" {
  subnet_id                 = azurerm_subnet.ctrl_network_subnet.id
  network_security_group_id = azurerm_network_security_group.rvbd_nsg.id
}
resource "azurerm_subnet_network_security_group_association" "wan_sec_assoc" {
  subnet_id                 = azurerm_subnet.wan_network_subnet.id
  network_security_group_id = azurerm_network_security_group.rvbd_nsg.id
}

# Create Management network interface for Director
resource "azurerm_network_interface" "director_nic_1" {
    name                      = "Director_NIC1"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "Director_NIC1_Configuration"
        subnet_id                     = azurerm_subnet.mgmt_subnet.id
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = azurerm_public_ip.ip_dir.id
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Southbound network interface for Director
resource "azurerm_network_interface" "director_nic_2" {
    name                      = "Director_NIC2"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "Director_NIC2_Configuration"
        subnet_id                     = azurerm_subnet.ctrl_network_subnet.id
        private_ip_address_allocation = "dynamic"
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Management network interface for Controller
resource "azurerm_network_interface" "controller_nic_1" {
    name                      = "Controller_NIC1"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "Controller_NIC1_Configuration"
        subnet_id                     = azurerm_subnet.mgmt_subnet.id
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = azurerm_public_ip.ip_ctrl.id
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Northbound/Control network interface for Controller
resource "azurerm_network_interface" "controller_nic_2" {
    name                      = "Controller_NIC2"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name
	enable_ip_forwarding      = "true"
    enable_accelerated_networking = "true"

    ip_configuration {
        name                          = "Controller_NIC2_Configuration"
        subnet_id                     = azurerm_subnet.ctrl_network_subnet.id
        private_ip_address_allocation = "dynamic"
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Southbound/WAN network interface for Controller
resource "azurerm_network_interface" "controller_nic_3" {
    name                      = "Controller_NIC3"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name
    enable_accelerated_networking = "true"

    ip_configuration {
        name                          = "Controller_NIC3_Configuration"
        subnet_id                     = azurerm_subnet.wan_network_subnet.id
        private_ip_address_allocation = "dynamic"
		public_ip_address_id		  = azurerm_public_ip.ip_ctrl_wan.id
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Management network interface for Analytics
resource "azurerm_network_interface" "van_nic_1" {
    name                      = "VAN_NIC1"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "VAN_NIC1_Configuration"
        subnet_id                     = azurerm_subnet.mgmt_subnet.id
        private_ip_address_allocation = "dynamic"
        public_ip_address_id          = azurerm_public_ip.ip_van.id
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create Southbound network interface for Analytics
resource "azurerm_network_interface" "van_nic_2" {
    name                      = "VAN_NIC2"
    location                  = var.location
    resource_group_name       = azurerm_resource_group.rvbd_rg.name

    ip_configuration {
        name                          = "VAN_NIC2_Configuration"
        subnet_id                     = azurerm_subnet.ctrl_network_subnet.id
        private_ip_address_allocation = "dynamic"
    }

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rvbd_rg.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics of Director VM
resource "azurerm_storage_account" "storageaccountDir" {
    name                        = "dirdiag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rvbd_rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create storage account for boot diagnostics of Controller VM
resource "azurerm_storage_account" "storageaccountCtrl" {
    name                        = "ctrldiag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rvbd_rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"environment" = "RVBDHeadEndHA"}
}
# Create storage account for boot diagnostics of Director VM
resource "azurerm_storage_account" "storageaccountVAN" {
    name                        = "vandiag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rvbd_rg.name
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create RVBD Director Virtual Machine
resource "azurerm_virtual_machine" "directorVM" {
    name                  = "RVBD_Director"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rvbd_rg.name
    network_interface_ids = [azurerm_network_interface.director_nic_1.id, azurerm_network_interface.director_nic_2.id]
	primary_network_interface_id = azurerm_network_interface.director_nic_1.id
    vm_size               = var.director_vm_size

    storage_os_disk {
        name              = "Director_OSDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=var.image_director
    }

    os_profile {
        computer_name  = var.hostname_director
        admin_username = "rvbd_devops"
        custom_data = data.template_file.user_data_dir.rendered
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
        storage_uri = azurerm_storage_account.storageaccountDir.primary_blob_endpoint
    }
	
    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create RVBD Controller Virtual Machine
resource "azurerm_virtual_machine" "controllerVM" {
    name                  = "RVBD_Controller"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rvbd_rg.name
    network_interface_ids = [azurerm_network_interface.controller_nic_1.id, azurerm_network_interface.controller_nic_2.id, azurerm_network_interface.controller_nic_3.id]
	primary_network_interface_id = azurerm_network_interface.controller_nic_1.id
    vm_size               = var.controller_vm_size
#	depends_on            = [azurerm_virtual_machine.directorVM]
	
    storage_os_disk {
        name              = "Controller_OSDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=var.image_controller
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
        storage_uri = azurerm_storage_account.storageaccountCtrl.primary_blob_endpoint
    }
	
    tags = {"environment" = "RVBDHeadEndHA"}
}

# Create RVBD Analytics Virtual Machine
resource "azurerm_virtual_machine" "vanVM" {
    name                  = "RVBD_Analytics"
    location              = var.location
    resource_group_name   = azurerm_resource_group.rvbd_rg.name
    network_interface_ids = [azurerm_network_interface.van_nic_1.id, azurerm_network_interface.van_nic_2.id]
	primary_network_interface_id = azurerm_network_interface.van_nic_1.id
    vm_size               = var.analytics_vm_size
#	depends_on            = [azurerm_virtual_machine.controllerVM]

    storage_os_disk {
        name              = "VAN_OSDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_image_reference {
        id=var.image_analytics
    }

    os_profile {
        computer_name  = var.hostname_analytics
        admin_username = "rvbd_devops"
        custom_data = data.template_file.user_data_van.rendered
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
        storage_uri = azurerm_storage_account.storageaccountVAN.primary_blob_endpoint
    }
	
    tags = {"environment" = "RVBDHeadEndHA"}
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
