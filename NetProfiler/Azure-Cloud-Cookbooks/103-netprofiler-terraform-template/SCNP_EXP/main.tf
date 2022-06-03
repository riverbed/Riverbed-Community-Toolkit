#accepting Marketplace agreements
#az vm image terms accept --urn riverbed:netprofiler:scnp-ve-exp:latest

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


#Create public ip address for SCNP dispatcher
resource "azurerm_public_ip" "scnp-exp_ip" {
    name                         = "scnp-exp_ip"
    location                     = var.rg_location
    resource_group_name          = var.resource_group
    allocation_method            = "Dynamic"
    domain_name_label            = "scnp-exp-npm-lab-ch"
}

#Create vNIC SCNP-DP
resource "azurerm_network_interface" "scnp-exp_vnic" {
    name                        = "scnp-exp_vnic"
    location                    = var.rg_location
    resource_group_name         = var.resource_group

    ip_configuration {
        name                          = "scnp-exp_nic_configuration"
        subnet_id                     = var.scnp_subnet_id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.scnp-exp_private_ip
        public_ip_address_id          = azurerm_public_ip.scnp-exp_ip.id
    }
}

#Create a virtual machine SCNP-DP
resource "azurerm_virtual_machine" "scnp-exp_virtual_machine" {

    name = var.hostname_scnp-exp_vm
    location = var.rg_location
    resource_group_name = var.resource_group
    network_interface_ids = [azurerm_network_interface.scnp-exp_vnic.id]
    vm_size="Standard_E4s_v3"


    plan {
        publisher=var.publisher
        product=var.scnp_product
        name=var.scnp_sku
    }

    boot_diagnostics {
        storage_uri = var.storage_name
        enabled = true
    }

    storage_image_reference {
        publisher = var.publisher
        offer = var.scnp_product
        sku = var.scnp_sku
        version = var.scnp_product_version
    }

    storage_os_disk {
        name = "scnp-exp_disk0"
        managed_disk_type = "StandardSSD_LRS"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = var.hostname_scnp-exp_vm
        admin_username = var.scnp_username
        admin_password = var.scnp_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}

#Flow Data
resource "azurerm_managed_disk" "scnp-exp_datadisk1" {
  name                 = "${var.hostname_scnp-exp_vm}-disk1"
  location             = var.rg_location
  resource_group_name  = var.resource_group
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 250
}

#Shot term cache
resource "azurerm_managed_disk" "scnp-exp_datadisk2" {
  name                 = "${var.hostname_scnp-exp_vm}-disk2"
  location             = var.rg_location
  resource_group_name  = var.resource_group
  storage_account_type = "StandardSSD_LRS"
  create_option        = "Empty"
  disk_size_gb         = 250
}




