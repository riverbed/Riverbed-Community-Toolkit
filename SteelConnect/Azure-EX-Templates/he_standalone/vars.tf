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
  default = "Riverbed_HE"
}

variable "ssh_key" {
  description = "SSH Key to be injected into VMs deployed on Azure."
}

variable "vpc_address_space" {
  description = "Virtual Private Network's address space to be used to deploy Riverbed Head end setup."
  default = "10.234.0.0/16"
}

variable "newbits_subnet" {
  description = "This is required to create desired netmask from virtual network."
  default = "8"
}

variable "overlay_network" {
  description = "This is the SDWAN overlay network space. It will be used to install a route on analytics"
  default = "172.30.0.0/15"
}

variable "image_director" {
  description = "Riverbed Director Image ID to be used to deploy Riverbed Director."
}

variable "image_controller" {
  description = "Controller/FlexVNF Image ID to be used to deploy Riverbed Controller."
}

variable "image_analytics" {
  description = "Riverbed Analytics Image ID to be used to deploy Riverbed Analytics."
}

variable "hostname_director" {
  description = "Hostname to be used for Riverbed Director."
  default = "rvbd-director"
}

variable "hostname_analytics" {
  description = "Hostname to be used for Riverbed Analytics."
  default = "rvbd-analytics"
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
