<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Create Subnet Acceleration in an existing Azure Virtual Network

    .EXAMPLE

        .\Create-SubnetAcceleration.ps1 -VirtualNetworkResourceGroupName "azu-hub-westus" -VirtualNetworkName "azu-hub-westus" -SubnetPrefix_acceleration "10.1.82.0/24"

    .EXAMPLE

        # Create subnet using default naming convention for related resources
        .\Create-SubnetAcceleration.ps1 -ProjectName "azu" -component "hub" -Location "westus" -SubnetPrefix_acceleration "10.1.82.0/24"

#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used for default naming of resources and configuration elements
    $component = "hub",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope",  # ex. "westus"

    $VirtualNetworkResourceGroupName = "$ProjectName-$component-$Location", # ex. "azu-hub-westus"
    $VirtualNetworkName = "$ProjectName-$component-$Location", # ex. "azu-hub-westus"
    $SubnetPrefix_acceleration = "10.3.82.0/24", # must be a /24 ex. "10.1.82.0/24"
    $SubnetName_acceleration = "acceleration"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Create-SubnetAcceleration"

# Set Azure context
if ($SubscriptionId) { Select-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop }
$azContext = Get-AzContext -ErrorAction Stop
$subscriptionId = $azContext.Subscription.Id

#Link Riverbed Microsoft Partner
try {
$azContext = Get-AzContext
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$accessToken = ($azContext.TokenCache.ReadItems() | Where-Object{ ($_.TenantId -eq $azContext.Tenant.Id) -and ($_.Resource -eq "https://management.core.windows.net/") } | Sort-Object -Property ExpiresOn -Descending)[0].AccessToken
$uri = "https://management.azure.com/providers/Microsoft.ManagementPartner/partners/1854868/?api-version=2018-02-01"
$irm_output = Invoke-RestMethod -Method PUT -Uri $uri -Headers @{ 'Authorization' = 'Bearer ' + $accessToken }
} catch {
try { $irm_output += Invoke-RestMethod -Method patch -Uri $uri -Headers @{ 'Authorization' = 'Bearer ' + $accessToken } } catch { $irm_status ="Retry Failed"}
}

#endregion

# Fetch Virtual Network and create the subnet acceleration
$virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $VirtualNetworkResourceGroupName -Name $VirtualNetworkName
$output = Add-AzVirtualNetworkSubnetConfig -Name $subnetName_acceleration -VirtualNetwork $virtualNetwork -AddressPrefix $SubnetPrefix_acceleration
$virtualNetwork | Set-AzVirtualNetwork

# check the subnet has been created
$subnetConfig = Get-AzVirtualNetworkSubnetConfig -Name $SubnetName_acceleration -VirtualNetwork $virtualNetwork
if (!$subnetConfig) { Throw "cannot find Acceleration subnet in the VNET" }