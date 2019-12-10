<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Deploy Integration Service Environment (ISE)

    .EXAMPLE

        # Deploy ISE using subnet ids defined in the template parameters file (default path for template parameter file sample\azuredeploy-ise.parameters.yoursite.json)
        .\scripts\Deploy-ISE.ps1 -ProjectName "yoursite" -Location "your-azure-location" -templateParameterFilePath ".\sample\azuredeploy-ise.parameters.aza.json"

    .EXAMPLE

        # Create new subnets for ISE integration in an existing vnet
        .\scripts\Deploy-ISE -ProjectName "yoursite" -Location "your-azure-location" `
            -VirtualNetworkResourceGroupName "your-vnet-rg" -VirtualNetworkName "your-vnet" `
            -NewSubnetsISE `
            -subnetNameISE1 "ISE1" -subnetNameISE2 "ISE2" -subnetNameISE3 "ISE3" -subnetNameISE4 "ISE4" `
            -subnetPrefixISE1 "10.1.253.0/26" -subnetPrefixISE2 "10.1.253.64/26" -subnetPrefixISE3 "10.1.253.128/26" -subnetPrefixISE4 "10.1.253.192/26" `
            -templateParameterFilePath ".\sample\azuredeploy-ise.parameters.yoursite.json"

    .EXAMPLE

        # Use existing subnets for ISE integration. Fetch the subnets ids for the deloyment parameters, based on the subnets name and virtual network resource name.
        .\scripts\Deploy-ISE -ProjectName "yoursite" -Location "your-azure-location" `
            -VirtualNetworkResourceGroupName "your-vnet-rg" -VirtualNetworkName "your-vnet" `
            -FetchISESubnetsIds `
            -subnetNameISE1 "ISE1" -subnetNameISE2 "ISE2" -subnetNameISE3 "ISE3" -subnetNameISE4 "ISE4" `
            -templateParameterFilePath ".\sample\azuredeploy-ise.parameters.yoursite.json"

    .EXAMPLE

        # Create new subnets for ISE integration for sandbox sample AZE, with default naming for resources and dependencies
        .\scripts\Deploy-ISE.ps1 -ProjectName "aze" -Location "westeurope" -NewSubnetsISE
#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "ise",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope", # ex. "westus"

    # Deployment parameters
    $ResourceGroupName = "$ProjectName-acceleration-$Location", # ex. azu-acceleration-westus
    $templateFilePath = ".\azuredeploy-$component.json", # ex. ".\azuredeploy-ise.json"
    $artifactsDirectory = ".\sample",
    $templateParameterFilePath = "$artifactsDirectory\azuredeploy-$component.parameters.$ProjectName.json", # ex. ".\sample\azuredeploy-ise.parameters.azu.json"

    $VirtualNetworkResourceGroupName = "$ProjectName-hub-$Location", # ex. azu-hub-westus
    $VirtualNetworkName = "$ProjectName-hub-$Location", # ex. azu-hub-westus

    [switch]$FetchISESubnetsIds,
    [switch]$NewSubnetsISE,
    $subnetNameISE1="ISE1",
    $subnetNameISE2="ISE2",
    $subnetNameISE3="ISE3",
    $subnetNameISE4="ISE4",
    $subnetPrefixISE1="10.3.253.0/26", #ex. "10.1.253.0/26"
    $subnetPrefixISE2="10.3.253.64/26", #ex "10.1.253.64/26"
    $subnetPrefixISE3="10.3.253.128/26", #ex "10.1.253.128/26"
    $subnetPrefixISE4="10.3.253.192/26" # "10.1.253.192/26"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Deploy-ISE"

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
$partner_output = Invoke-RestMethod -Method PUT -Uri $uri -Headers @{ 'Authorization' = 'Bearer ' + $accessToken }
} catch {
try { $partner_output += Invoke-RestMethod -Method patch -Uri $uri -Headers @{ 'Authorization' = 'Bearer ' + $accessToken } } catch { $partner_output +="Failed"}
}

#endregion

# Create resource group if it does not exist
if ($null -eq (Get-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
}

#region ISE

# Fetch Virtual Network id
if ($FetchISESubnetsIds -or $NewSubnetsISE) {
    $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $VirtualNetworkResourceGroupName -Name $VirtualNetworkName -ErrorAction Stop
}

# Create ISE subnets
if ($NewSubnetsISE) {
    $iseDelegation = New-AzDelegation -Name "integrationServiceEnvironments" -ServiceName "Microsoft.Logic/integrationServiceEnvironments"
    $output = Add-AzVirtualNetworkSubnetConfig -Name $subnetNameISE1 -VirtualNetwork $virtualNetwork -AddressPrefix $subnetPrefixISE1 -Delegation $iseDelegation -ErrorAction Stop
    $output = Add-AzVirtualNetworkSubnetConfig -Name $subnetNameISE2 -VirtualNetwork $virtualNetwork -AddressPrefix $subnetPrefixISE2 -ErrorAction Stop
    $output = Add-AzVirtualNetworkSubnetConfig -Name $subnetNameISE3 -VirtualNetwork $virtualNetwork -AddressPrefix $subnetPrefixISE3 -ErrorAction Stop
    $output = Add-AzVirtualNetworkSubnetConfig -Name $subnetNameISE4 -VirtualNetwork $virtualNetwork -AddressPrefix $subnetPrefixISE4 -ErrorAction Stop
    $virtualNetwork | Set-AzVirtualNetwork
}

# Fetch Virtual Network id to get subnetid
if ($FetchISESubnetsIds -or $NewSubnetsISE) {
    $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $VirtualNetworkResourceGroupName -Name $VirtualNetworkName
    $subnetIdISE1 = ($virtualNetwork.subnets | Where-Object { $_.name -eq "$subnetNameISE1" } | Select-Object id).id
    $subnetIdISE2 = ($virtualNetwork.subnets | Where-Object { $_.name -eq "$subnetNameISE2" } | Select-Object id).id
    $subnetIdISE3 = ($virtualNetwork.subnets | Where-Object { $_.name -eq "$subnetNameISE3" } | Select-Object id).id
    $subnetIdISE4 = ($virtualNetwork.subnets | Where-Object { $_.name -eq "$subnetNameISE4" } | Select-Object id).id
}

#endregion

# Splat runtime parameters
$parameters = @{
    projectName = $ProjectName
    Name = "$component"
    ResourceGroupName = "$resourceGroupName"
    TemplateFile = "$templateFilePath"
    TemplateParameterFile = "$templateParameterFilePath"
    Verbose = $true
    ErrorVariable = "ErrorMessages"
}

if ($FetchISESubnetsIds -or $NewSubnetsISE) {
    $parameters += @{
        subnetIdISE1 = $subnetIdISE1
        subnetIdISE2 = $subnetIdISE2
        subnetIdISE3 = $subnetIdISE3
        subnetIdISE4 = $subnetIdISE4
    }
}

# Deploy ISE template
New-AzResourceGroupDeployment @parameters