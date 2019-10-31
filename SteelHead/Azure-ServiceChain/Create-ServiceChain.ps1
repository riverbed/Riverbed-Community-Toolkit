<#
    .DESCRIPTION

        Create Route Tables for the Acceleration Service Chain
#>

# parameters
param(
$SiteName = "aze",
$SubscriptionId, # ex. "234123143-1234-1234-1234-1234",
$Location = "westeurope", # Location of the resources
$ResourceGroupName_hub = "aze-hub-singleUL", # Resource group to store Route Tables ex. "sitename"
$VirtualNetworkName = "hub-westeurope", #ex. "hub-australiaeast"
$SteelConnectEX_ip = "10.3.0.254",

$SteelHead_ip = "10.3.82.82",
$ResourceGroupName_acceleration = "aze-acceleration",

$Prefix_WAN = "10.0.0.0/8",
$Prefix_SiteLocal = "10.3.0.0/16",
$Prefix_Site_servernetwork = "10.3.1.0/24",
$Prefix_Uplink = "192.168.1.0/24",
$Prefix_OOB = "10.3.254.0/24",
$Prefix_RemoteAccess = "80.80.80.0/24"
)

Select-AzSubscription -SubscriptionId $SubscriptionId

#variables
$acceleration_route_name_suffix = "ACCELERATION"
$vnet = Get-AzVirtualNetwork -Name $VirtualNetworkName -ResourceGroup $ResourceGroupName_hub
$subnets = @{}

# Set ACCELERATION Route Table for servernetwork subnet
$subnetName = "servernetwork"
$routeTableName = "$SiteName-$subnetName-$acceleration_route_name_suffix"
$resourceGroupName = $ResourceGroupName_acceleration

Remove-AzRouteTable -ResourceGroupName $resourceGroupName -Name  $routeTableName -ErrorAction SilentlyContinue
$RouteTable = New-AzRouteTable -ResourceGroupName $resourceGroupName -Name  $routeTableName -Location $Location -Force -ErrorAction Stop

Add-AzRouteConfig -Name "default_via_SteelConnectEX" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $SteelConnectEX_ip  -RouteTable $RouteTable
Add-AzRouteConfig -Name "wan_via_acceleration" -AddressPrefix $Prefix_WAN -NextHopType "VirtualAppliance" -NextHopIpAddress $SteelHead_ip  -RouteTable $RouteTable
Add-AzRouteConfig -Name "block_UL_Internet1" -AddressPrefix $Prefix_Uplink -NextHopType "None" -RouteTable $RouteTable
Add-AzRouteConfig -Name "$($SiteName)_local" -AddressPrefix $Prefix_SiteLocal -NextHopType "VnetLocal" -RouteTable $RouteTable
Add-AzRouteConfig -Name "servernetwork_local" -AddressPrefix $Prefix_Site_servernetwork -NextHopType "VnetLocal" -RouteTable $RouteTable
Add-AzRouteConfig -Name "oob_management" -AddressPrefix $Prefix_RemoteAccess -NextHopType "Internet" -RouteTable $RouteTable
Set-AzRouteTable -RouteTable $RouteTable -ErrorAction Stop

$subnets["$subnetName"] = @{
    route_table_id = $RouteTable.Id
}

# Set ACCELERATION Route Table for acceleration subnet
$subnetName = "acceleration"
$routeTableName = "$SiteName-$subnetName"
$resourceGroupName = $ResourceGroupName_acceleration

Remove-AzRouteTable -ResourceGroupName $resourceGroupName -Name  $routeTableName -ErrorAction SilentlyContinue
$RouteTable = New-AzRouteTable -ResourceGroupName $resourceGroupName -Name  $routeTableName -Location $Location -Force -ErrorAction Stop

Add-AzRouteConfig -Name "default_via_SteelConnectEX" -AddressPrefix 0.0.0.0/0 -NextHopType "VirtualAppliance" -NextHopIpAddress $SteelConnectEX_ip  -RouteTable $RouteTable
Add-AzRouteConfig -Name "wan_via_SteelConnectEX" -AddressPrefix $Prefix_WAN -NextHopType "VirtualAppliance" -NextHopIpAddress $SteelConnectEX_ip  -RouteTable $RouteTable
Add-AzRouteConfig -Name "block_UL_Internet1" -AddressPrefix $Prefix_Uplink -NextHopType "None" -RouteTable $RouteTable
Add-AzRouteConfig -Name "$($SiteName)_local" -AddressPrefix $Prefix_SiteLocal -NextHopType "VnetLocal" -RouteTable $RouteTable
Add-AzRouteConfig -Name "servernetwork_local" -AddressPrefix $Prefix_Site_servernetwork -NextHopType "VnetLocal" -RouteTable $RouteTable
Add-AzRouteConfig -Name "block_oob" -AddressPrefix $Prefix_OOB -NextHopType "None" -RouteTable $RouteTable
Set-AzRouteTable -RouteTable $RouteTable  -ErrorAction Stop

$subnets["$subnetName"] = @{
    route_table_id = $RouteTable.Id
}

# Set ACCELERATION Route Table for transit subnet
$subnetName = "transit"
$routeTableName = "$SiteName-$subnetName-$acceleration_route_name_suffix"
$resourceGroupName = $ResourceGroupName_acceleration

Remove-AzRouteTable -ResourceGroupName $resourceGroupName -Name  $routeTableName -ErrorAction SilentlyContinue
$RouteTable = New-AzRouteTable -ResourceGroupName $resourceGroupName -Name  $routeTableName -Location $Location -Force -ErrorAction Stop

Add-AzRouteConfig -Name "$($SiteName)_via_acceleration" -AddressPrefix $Prefix_SiteLocal -NextHopType "VirtualAppliance" -NextHopIpAddress $SteelHead_ip -RouteTable $RouteTable
Add-AzRouteConfig -Name "servernetwork_via_acceleration" -AddressPrefix $Prefix_Site_servernetwork  -NextHopType "VirtualAppliance" -NextHopIpAddress $SteelHead_ip -RouteTable $RouteTable
Set-AzRouteTable -RouteTable $RouteTable  -ErrorAction Stop

$subnets["$subnetName"] = @{
    route_table_id = $RouteTable.Id
}

### Output
foreach ($subnet in $subnets.Keys) { $subnet ; $subnets[$subnet].Values }