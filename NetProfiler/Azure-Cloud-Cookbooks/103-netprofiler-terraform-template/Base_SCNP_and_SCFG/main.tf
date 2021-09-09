#accepting Marketplace agreements
#az vm image terms accept --urn riverbed:netprofiler:scnp-ve-base:latest
#az vm image terms accept --urn riverbed:flowgateway:scfg-ve-base:latest

terraform {
    required_providers {
        azurerm = {
            version = "~> 2"
        }
    }
}

provider "azurerm" {
    subscription_id = var.subscriptionid
    features {}
}


# Create a resource group
resource "azurerm_resource_group" "rg" {
   name     = var.resource_group
   location = var.npm_location
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "npm_lab_vnet" {
  name                = var.npm_lab_vnet
  address_space       = [var.npm_lab_vnet_range]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


# Create SCNP subnet
resource "azurerm_subnet" "scnp_subnet" {
    name                 = var.scnp_subnet
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.npm_lab_vnet.name
    address_prefixes       = [var.scnp_subnet_range]
}

# Create SCFG subnet
resource "azurerm_subnet" "scfg_subnet" {
    name                 = var.scfg_subnet
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.npm_lab_vnet.name
    address_prefixes       = [var.scfg_subnet_range]
}

# Create Server subnet
resource "azurerm_subnet" "srv_subnet" {
    name                 = var.srv_subnet
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.npm_lab_vnet.name
    address_prefixes       = [var.srv_subnet_range]
}

#Create public ip address for SCNP
resource "azurerm_public_ip" "scnp_ip" {
    name                         = "scnp_ip"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
    domain_name_label            = var.domain_label_scnp
}

#Create public ip address for SCFG
resource "azurerm_public_ip" "scfg_ip" {
    name                         = "scfg_ip"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
    domain_name_label            = var.domain_label_scfg
}

#Create public ip address for SRV
resource "azurerm_public_ip" "srv_ip" {
    name                         = "srv-vm-ip"
    location                     = azurerm_resource_group.rg.location
    resource_group_name          = azurerm_resource_group.rg.name
    allocation_method            = "Dynamic"
    domain_name_label            = var.domain_label_srv
}



#Create NSG SCFG & SCNP
resource "azurerm_network_security_group" "sc_nsg" {
    name                = "sc_nsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "HTTPs"
        priority                   = 1003
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "Netflow"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "UDP"
        source_port_range          = "*"
        destination_port_range     = "2055"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

#Create NSG Server
resource "azurerm_network_security_group" "srv_nsg" {
    name                = "srv_nsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

#Create vNIC SCNP
resource "azurerm_network_interface" "scnp_vnic" {
    name                        = "scnp_vnic"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "scnp_nic_configuration"
        subnet_id                     = azurerm_subnet.scnp_subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.scnp_private_ip
        public_ip_address_id          = azurerm_public_ip.scnp_ip.id
    }
}

#Create vNIC SCFG
resource "azurerm_network_interface" "scfg_vnic" {
    name                        = "scfg_vnic"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "scfg_nic_configuration"
        subnet_id                     = azurerm_subnet.scfg_subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.scfg_private_ip
        public_ip_address_id          = azurerm_public_ip.scfg_ip.id
    }
}

#Create vNIC Server
resource "azurerm_network_interface" "srv_vnic" {
    name                        = "srv_vnic"
    location                    = azurerm_resource_group.rg.location
    resource_group_name         = azurerm_resource_group.rg.name

    ip_configuration {
        name                          = "ipconfig1"
        subnet_id                     = azurerm_subnet.srv_subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.srv_private_ip
        public_ip_address_id          = azurerm_public_ip.srv_ip.id
    }
}

#Storage account for diagnostics
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.rg.name
    }

    byte_length = 8
}

resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = azurerm_resource_group.rg.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}

#Create a virtual machine SCNP
resource "azurerm_virtual_machine" "scnp_virtual_machine" {

    name = var.hostname_scnp_vm
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.scnp_vnic.id]
    vm_size="Standard_E4s_v3"


    plan {
        publisher=var.publisher
        product=var.scnp_product
        name=var.scnp_sku
    }

    boot_diagnostics {
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
        enabled = true
    }

    storage_image_reference {
        publisher = var.publisher
        offer = var.scnp_product
        sku = var.scnp_sku
        version = var.scnp_product_version
    }

    storage_os_disk {
        name = "scnp_disk0"
        managed_disk_type = "StandardSSD_LRS"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = var.hostname_scnp_vm
        admin_username = var.scnp_username
        admin_password = var.scnp_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}

#Flow Data
resource "azurerm_managed_disk" "scnp_datadisk1" {
  name                 = "${var.hostname_scnp_vm}-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 500
}

#Shot term cache
resource "azurerm_managed_disk" "scnp_datadisk2" {
  name                 = "${var.hostname_scnp_vm}-disk2"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 250
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach_scnp_datadisk1" {
  managed_disk_id    = azurerm_managed_disk.scnp_datadisk1.id
  virtual_machine_id = azurerm_virtual_machine.scnp_virtual_machine.id
  lun                = "0"
  caching            = "ReadWrite"
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach_scnp_datadisk2" {
  managed_disk_id    = azurerm_managed_disk.scnp_datadisk2.id
  virtual_machine_id = azurerm_virtual_machine.scnp_virtual_machine.id
  lun                = "1"
  caching            = "ReadWrite"
}

#Create a virtual machine SCFG
resource "azurerm_virtual_machine" "scfg_virtual_machine" {
    name = var.hostname_scfg_vm
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.scfg_vnic.id]
    vm_size="Standard_E4s_v3"


    plan {
        publisher=var.publisher
        product=var.scfg_product
        name=var.scfg_sku
    }

    boot_diagnostics {
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
        enabled = true
}

storage_image_reference {
    publisher = var.publisher
    offer = var.scfg_product
    sku = var.scfg_sku
    version = var.scfg_product_version
}

storage_os_disk {
    name = "scfg_disk0"
    managed_disk_type = "StandardSSD_LRS"
    caching = "ReadWrite"
    create_option = "FromImage"
}

os_profile {
    computer_name = var.hostname_scfg_vm
    admin_username = var.scfg_username
    admin_password = var.scfg_password
}
os_profile_linux_config {
    disable_password_authentication = false
  }

}

#Buffered Flow Data
resource "azurerm_managed_disk" "scfg_datadisk1" {
  name                 = "${var.hostname_scfg_vm}-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 250
}

resource "azurerm_virtual_machine_data_disk_attachment" "attach_scfg_datadisk1" {
  managed_disk_id    = azurerm_managed_disk.scfg_datadisk1.id
  virtual_machine_id = azurerm_virtual_machine.scfg_virtual_machine.id
  lun                = "0"
  caching            = "ReadWrite"
}


#Create a virtual machine SRV
resource "azurerm_virtual_machine" "srv_virtual_machine" {
    name = var.hostname_srv_vm
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    network_interface_ids = [azurerm_network_interface.srv_vnic.id]
    vm_size="Standard_A1_v2"

boot_diagnostics {
    storage_uri = ""
    enabled = true
}

    plan {
        name      = var.srv_sku
        product   = var.srv_product
        publisher = var.srv_publisher
    }

storage_image_reference {
    publisher = var.srv_publisher
    offer = var.srv_offer
    sku = var.srv_sku
    version = var.srv_product_version
}

storage_os_disk {
    name = "SRV-VM_OsDisk1"
    managed_disk_type = "StandardSSD_LRS"
    caching = "ReadWrite"
    create_option = "FromImage"
}

os_profile {
    computer_name = var.hostname_srv_vm
    admin_username = var.srv_username
    admin_password = var.srv_password
}
os_profile_linux_config {
    disable_password_authentication = false
  }

}
