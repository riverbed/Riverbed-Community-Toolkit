variable "resource_group" {}
variable "subscriptionid" {}
variable "location" {}
variable "rvbd_vnet" {}
variable "rvbd_vnet_range" {}
variable "cac_subnet" {}
variable "cac_subnet_range" {}
variable "cac_private_ip" {}
variable "hostname_cac_vm" {}
variable "product" {}
variable "product_version" {}
variable "publisher" { default="riverbed" }
variable "cac_username" {}
variable "cac_password" {}

