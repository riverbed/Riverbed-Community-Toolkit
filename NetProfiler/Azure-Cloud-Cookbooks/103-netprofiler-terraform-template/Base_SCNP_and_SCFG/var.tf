variable "subscriptionid" {}
variable "npm_location" {
  default="westeurope"
}

variable resource_group {}

variable npm_lab_vnet {}
variable npm_lab_vnet_range {}
variable domain_label_scnp {}
variable domain_label_scfg {}
variable domain_label_srv {}

variable scnp_subnet {}
variable scnp_subnet_range {}
variable scnp_private_ip {}

variable scfg_subnet {}
variable scfg_subnet_range {}
variable scfg_private_ip {}

variable srv_subnet {}
variable srv_subnet_range {}
variable srv_private_ip {}

variable hostname_scnp_vm {}
variable hostname_scfg_vm {}
variable scnp_product {}
variable scnp_product_version {}
variable scnp_sku {}
variable scfg_sku {}
variable scfg_product {}
variable scfg_product_version {}
variable scnp_username {}
variable scfg_username {}
variable scnp_password {}
variable scfg_password {}

variable hostname_srv_vm {}
variable srv_publisher {}
variable srv_offer {}
variable srv_sku {}
variable srv_product_version {}
variable srv_product {}
variable srv_username {}
variable srv_password {}

variable "publisher" {
  default="riverbed"
}