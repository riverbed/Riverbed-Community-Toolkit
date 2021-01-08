#change resource group
resource_group="myresourcegroup"

#change to your subscription id
subscriptionid="somesubscription_id"
location="westeurope"

rvbd_vnet="Riverbed_vnet"
rvbd_vnet_range="192.168.0.0/24"

cac_subnet="CAC_subnet"
cac_subnet_range="192.168.0.0/25"
cac_private_ip="192.168.0.5"

hostname_cac_vm="Client_Accelerator_Controller-VM"
product="client-accelerator-controller"
product_version="6.2.0"
cac_username="cacadmin" #will be ignored username is admin
cac_password="welcome1234" #overwriting default password
