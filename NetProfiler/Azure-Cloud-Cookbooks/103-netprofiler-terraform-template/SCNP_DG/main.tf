#accepting Marketplace agreements
#az vm image terms accept --urn riverbed:netprofiler:scnp-ve-dp:latest

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
resource "azurerm_public_ip" "scnp-dp_ip" {
    name                         = "scnp-dp_ip"
    location                     = var.rg_location
    resource_group_name          = var.resource_group
    allocation_method            = "Dynamic"
    domain_name_label            = "scnp-dp-npm-lab-ch"
}

#Create vNIC SCNP-DP
resource "azurerm_network_interface" "scnp-dp_vnic" {
    name                        = "scnp-dp_vnic"
    location                    = var.rg_location
    resource_group_name         = var.resource_group

    ip_configuration {
        name                          = "scnp-dp_nic_configuration"
        subnet_id                     = var.scnp_subnet_id
        private_ip_address_allocation = "Static"
        private_ip_address            = var.scnp-dp_private_ip
        public_ip_address_id          = azurerm_public_ip.scnp-dp_ip.id
    }
}

#Create a virtual machine SCNP-DP
resource "azurerm_virtual_machine" "scnp-dp_virtual_machine" {

    name = var.hostname_scnp-dp_vm
    location = var.rg_location
    resource_group_name = var.resource_group
    network_interface_ids = [azurerm_network_interface.scnp-dp_vnic.id]
    vm_size="Standard_E32s_v3"


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
        name = "scnp-dp_disk0"
        managed_disk_type = "StandardSSD_LRS"
        caching = "ReadWrite"
        create_option = "FromImage"
    }

    os_profile {
        computer_name = var.hostname_scnp-dp_vm
        admin_username = var.scnp_username
        admin_password = var.scnp_password
    }

    os_profile_linux_config {
        disable_password_authentication = false
    }

}




