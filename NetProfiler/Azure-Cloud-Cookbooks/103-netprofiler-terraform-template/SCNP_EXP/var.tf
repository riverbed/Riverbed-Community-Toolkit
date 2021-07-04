variable "subscriptionid" {}
variable "rg_location" {
  default="westeurope"
}

variable resource_group {}

variable npm_lab_vnet {}
variable npm_lab_vnet_range {}

variable scnp_subnet {}
variable scnp_subnet_id {}
variable scnp_subnet_range {}
variable scnp-exp_private_ip {}

variable hostname_scnp-exp_vm {}

variable scnp_product {}
variable scnp_product_version {}
variable scnp_sku {}

variable scnp_username {}
variable scnp_password {}

variable "publisher" {
  default="riverbed"
}

variable storage_name {}