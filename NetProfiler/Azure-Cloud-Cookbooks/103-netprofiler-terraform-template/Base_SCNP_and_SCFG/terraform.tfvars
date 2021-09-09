#The following variables need to be modified
subscriptionid="some subscription id"
resource_group="some resource group name"

#The supplied password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following:
#Contains an uppercase character, Contains a lowercase character, Contains a numeric digit, Contains a special character,
#Control characters are not allowed
scnp_password="some secret password"
scfg_password="some secret password"
srv_password="some secret password"


#The following variables can be kept as-is
npm_lab_vnet="npm_vnet"
npm_lab_vnet_range="192.168.0.0/24"

scnp_subnet="scnp_subnet"
scnp_subnet_range="192.168.0.0/28"
scnp_private_ip="192.168.0.5"

scfg_subnet="scfg_subnet"
scfg_subnet_range="192.168.0.16/28"
scfg_private_ip="192.168.0.20"

srv_subnet="srv_subnet"
srv_subnet_range="192.168.0.32/28"
srv_private_ip="192.168.0.36"

hostname_scnp_vm="SCNP-VM"
hostname_scfg_vm="SCFG-VM"
scnp_product="netprofiler"
scnp_product_version="latest"
scnp_sku="scnp-ve-base"
scfg_sku="scfg-ve-base"
scfg_product="flowgateway"
scfg_product_version="latest"

scnp_username="mazu"
scfg_username="mazu"

hostname_srv_vm="SRV-VM"
srv_publisher="canonical"
srv_offer="0001-com-ubuntu-pro-trusty"
srv_sku="pro-14_04-lts"
srv_product_version="14.04.20200601"
srv_product="0001-com-ubuntu-pro-trusty"
srv_username="srvadmin"
