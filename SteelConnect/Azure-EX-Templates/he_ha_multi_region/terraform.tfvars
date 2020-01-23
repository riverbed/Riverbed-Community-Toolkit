#----------------------------------------------------------------------
# Variable's value defined here
#----------------------------------------------------------------------

subscription_id		= "xxxx"
client_id			= "xxxx"
client_secret		= "xxxx"
tenant_id			= "xxxx"
location			= ["westus", "eastus"]
resource_group		= "Riverbed_HE_HA"
ssh_key				= "xxxx"
vpc_address_space	= ["10.54.0.0/16", "10.55.0.0/16"]
newbits_subnet		= "8"
overlay_network		= "172.30.0.0/15"
image_director		= ["/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/RVBD_SCEX_161R2-S10-Director", "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/RVBD_EX_161R2-S10-Director"]
image_controller	= ["/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/RVBD_SCEX_161R2-S10-FlexVNF", "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/RVBD_EX_161R2-S10-FlexVNF"]
image_analytics		= ["/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/RVBD_SCEX_161R2-S10-Analytics", "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/RVBD_EX_161R2-S10-Analytics"]
hostname_director	= ["Director1", "Director2"]
hostname_van		= ["Analytics1", "Analytics2"]
director_vm_size	= "Standard_F8s_v2"
controller_vm_size	= "Standard_F8s_v2"
router_vm_size		= "Standard_F8s_v2"
analytics_vm_size	= "Standard_F8s_v2"
