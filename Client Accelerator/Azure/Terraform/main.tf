# Deploy Client Accelerator Controller in Azure

terraform {
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "~>2"
        }
    }
}

provider "azurerm" {
    subscription_id = var.subscriptionid
    features {}
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "rvbd_vnet" {
  name                = var.rvbd_vnet
  address_space       = [var.rvbd_vnet_range]
  location            = var.location
  resource_group_name = var.resource_group
}


# Create Client Accelerator controller (CAC) subnet
resource "azurerm_subnet" "cac_subnet" {
    name                 = var.cac_subnet
    resource_group_name  = var.resource_group
    virtual_network_name = azurerm_virtual_network.rvbd_vnet.name
    address_prefixes       = [var.cac_subnet_range]
}

#Create public ip address for
resource "azurerm_public_ip" "cac_ip" {
    name                         = "cac_ip"
    location                     = var.location
    resource_group_name          = var.resource_group
    allocation_method            = "Dynamic"
    domain_name_label            = "cac"
}

#Create NSG CAC
resource "azurerm_network_security_group" "cac_nsg" {
    name                = "cac_nsg"
    location            = var.location
    resource_group_name = var.resource_group

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
        name                       = "HTTP"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
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
        name                       = "SteelHead_Mobile_Client"
        priority                   = 1004
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7870"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "in-path"
        priority                   = 1005
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7800"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    security_rule {
        name                       = "out-path"
        priority                   = 1006
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "7810"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

#Create vNIC CAC
resource "azurerm_network_interface" "cac_vnic" {
    name                        = "cac_vnic"
    location                    = var.location
    resource_group_name         = var.resource_group

    ip_configuration {
        name                          = "cac_nic_configuration"
        subnet_id                     = azurerm_subnet.cac_subnet.id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.cac_private_ip
        public_ip_address_id          = azurerm_public_ip.cac_ip.id
    }
}

# Connect the security group to the network interface CAC
resource "azurerm_network_interface_security_group_association" "cac_association" {
    network_interface_id      = azurerm_network_interface.cac_vnic.id
    network_security_group_id = azurerm_network_security_group.cac_nsg.id
}

#Storage account for diagnostics
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = var.resource_group
    }
    byte_length = 8
}


resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${lower(random_id.randomId.hex)}"
    resource_group_name         = var.resource_group
    location                    = var.location
    account_replication_type    = "LRS"
    account_tier                = "Standard"
}


#Create a virtual machine CAC
resource "azurerm_virtual_machine" "cac_virtual_machine" {

    name = var.hostname_cac_vm
    location = var.location
    resource_group_name = var.resource_group
    network_interface_ids = [azurerm_network_interface.cac_vnic.id]
    vm_size="Standard_A2_v2"


    plan {
        publisher=var.publisher
        product=var.product
        name=var.product
    }

    boot_diagnostics {
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
        enabled = true
    }

    storage_image_reference {
        publisher = var.publisher
        offer = var.product
        sku = var.product
        version = var.product_version
    }

    storage_os_disk {
        name = "cac_disk0"
        managed_disk_type = "StandardSSD_LRS"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = var.hostname_cac_vm
        admin_username = var.cac_username
        admin_password = var.cac_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}

resource "azurerm_managed_disk" "cac_datadisk0" {
  name                 = "${var.hostname_cac_vm}-disk1"
  location             = var.location
  resource_group_name  = var.resource_group
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100
}

resource "azurerm_virtual_machine_data_disk_attachment" "cac_datadisk_attachment" {
  managed_disk_id    = azurerm_managed_disk.cac_datadisk0.id
  virtual_machine_id = azurerm_virtual_machine.cac_virtual_machine.id
  lun                = "0"
  caching            = "ReadWrite"
}