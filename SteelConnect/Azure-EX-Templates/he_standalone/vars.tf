variable "subscription_id" {
  description = "Subscription ID of Azure account."
}

variable "client_id" {
  description = "Client ID of Terraform account to be used to deploy VM on Azure."
}

variable "client_secret" {
  description = "Client Secret of Terraform account to be used to deploy VM on Azure."
}

variable "tenant_id" {
  description = "Tenant ID of Terraform account to be used to deploy VM on Azure."
}

variable "location" {
  description = "Location where Riverbed Head End setup to be deployed."
}

variable "resource_group" {
  description = "Name of the resource group in which Riverbed Head End setup will be deployed."
  default = "SteelConnect-EX-Headend"
}

variable "ssh_key" {
  description = "SSH Key to be injected into VMs deployed on Azure."
}

variable "vnet_address_space" {
  description = "Virtual Private Network's address space to be used to deploy Riverbed Head end setup."
  default = "10.100.0.0/16"
}

variable "newbits_subnet" {
  description = "This is required to create desired netmask from virtual network."
  default = "8"
}

variable "overlay_network" {
  description = "This is the SDWAN overlay network space. It will be used to install a route on analytics"
  default = "99.00.0.0/8"
}

variable "image_director" {
  description = "Riverbed Director Image ID to be used to deploy SteelConnect-EX Director."
}

variable "image_controller" {
  description = "Controller/FlexVNF Image ID to be used to deploy SteelConnect-EX Controller."
}

variable "image_analytics" {
  description = "Riverbed Analytics Image ID to be used to deploy SteelConnect-EX Analytics."
}

variable "hostname_director" {
  description = "Hostname to be used for SteelConnect-EX Director."
  default = "Director1"
}

variable "hostname_controller" {
  description = "Hostname to be used for SteelConnect-EX Controller."
  default = "Controller1"
}

variable "hostname_analytics" {
  description = "Hostname to be used for SteelConnect-EX Analytics."
  default = "Analytics1"
}

variable "director_vm_size" {
  description = "Size of Riverbed Director VM."
  default = "Standard_F8s_v2"
}

variable "controller_vm_size" {
  description = "Size of Riverbed Controller VM."
  default = "Standard_F8s_v2"
}

variable "analytics_vm_size" {
  description = "Size of Riverbed Analytics VM."
  default = "Standard_F8s_v2"
}

variable "hostnum_director" {
  description = "Hostnum of the Director1. Used in management and control subnets."
  default = "11"
}

variable "hostnum_controller" {
  description = "Hostnum of the Controller1. Used in management, control and uplink subnets."
  default = "21"
}

variable "hostnum_analytics" {
  description = "Hostnum of the Analytics1. Used in management and control subnets."
  default = "31"
}

variable "analytics_port" {
  description = "Southound port of Analytics node"
  default = "1234"
}