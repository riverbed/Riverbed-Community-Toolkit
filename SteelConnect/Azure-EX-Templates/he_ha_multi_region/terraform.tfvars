#----------------------------------------------------------------------
# Variable's value defined here
#----------------------------------------------------------------------

subscription_id		= "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
client_id		= "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
client_secret		= "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tenant_id		= "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
location		= ["westus", "eastus"]
resource_group		= "SteelConnect-EX-HE"
ssh_key			= "ssh-rsa xxxxxxxxxxxxxxxxxxxxxxxxxxxx email@domain.com"
vpc_address_space	= ["10.54.0.0/16", "10.55.0.0/16"]
newbits_subnet		= "8"
overlay_network		= "172.30.0.0/15"
image_director		= ["/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/SteelConnectEX_20.2.1_DirectorWest", "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/SteelConnectEX_20.2.1_DirectorEast"]
image_controller	= ["/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/SteelConnectEX_20.2.1_FlexVNFWest", "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/SteelConnectEX_20.2.1_FlexVNFEast"]
image_analytics		= ["/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/SteelConnectEX_20.2.1_AnalyticsWest", "/subscriptions/xxxx/resourceGroups/xxxx/providers/Microsoft.Compute/images/SteelConnectEX_20.2.1_AnalyticsEast"]
# Accelerated Networking is not currently supported for SteelConnect-EX in Azure. Turning this on will limit VM sizes
accel_networking	= "false"
hostname_director	= ["Director1", "Director2"]
# Analytics instances deployed in primary region, Log forwarders in secondary. 
# Hostnames can be added or removed here to grow or shrink the cluster.
hostname_analytics	= ["Analytics", "Search"]
hostname_forwarders	= ["Forwarder1", "Forwarder2"]
director_vm_size	= "Standard_F8s_v2"
controller_vm_size	= "Standard_F8s_v2"
router_vm_size		= "Standard_F4s_v2"
analytics_vm_size	= "Standard_F8s_v2"
forwarder_vm_size	= "Standard_F4s_v2"
