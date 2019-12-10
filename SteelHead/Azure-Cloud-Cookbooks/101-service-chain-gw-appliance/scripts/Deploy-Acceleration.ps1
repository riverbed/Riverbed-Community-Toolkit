<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Deploy SteelHead acceleration

    .EXAMPLE
        # 1. Create a template parameters file and set values for ProjectName, subnetPrefix for acceleration, VirtualNetworkId and adminPublicKey
        # 2. Deploy acceleration in a specific resource group and location
        .\scripts\Deploy-Acceleration.ps1 -ProjectName "yoursite" -ResourceGroupName "your-rg-name" -Location "your-azure-location" -templateParameterFilePath ".\yourpath\azuredeploy-acceleration.parameters.yoursite.json"

    .EXAMPLE
        # Deploy acceleration with details to fetch the network inline parameters (default path for template parameters file sample\azuredeploy-acceleration.parameters.yoursite.json)
         .\scripts\Deploy-Acceleration.ps1 -ProjectName "yoursite" -Location "koreacentral" `
            -fetchVirtualNetworkId -VirtualNetworkResourceGroupName "vnet-rg" -VirtualNetworkName "vnet"

    .EXAMPLE
        # Deploy acceleration with inline parameters to generate a new ssh keypair (default path for template parameters file sample\azuredeploy-acceleration.parameters.yoursite.json)
        .\scripts\Deploy-Acceleration.ps1 -ProjectName "yoursite" -Location "koreacentral" -generateKeypair

        .EXAMPLE
        # Deploy acceleration with at least subnetPrefix set in the template parameters (default path for template parameters file sample\azuredeploy-acceleration.parameters.yoursite.json)
        # Generating a new ssh keypair, fetching/creating resources using the default naming.
        .\scripts\Deploy-Acceleration.ps1 -ProjectName "yoursite" -Location "koreacentral" -generateKeypair -fetchVirtualNetworkId
#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "acceleration",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope",  # ex. "westus"

    # Deployment standard parameters
    $ResourceGroupName = "$ProjectName-acceleration-$Location", # ex. azu-acceleration-westeurope
    $templateFilePath = ".\azuredeploy-acceleration.json", # ex. ".\azuredeploy-acceleration.json"
    $artifactsDirectory = ".\sample",
    $templateParameterFilePath = "$artifactsDirectory\azuredeploy-acceleration.parameters.$ProjectName.json", # ex. ".\sample\azuredeploy-acceleration.parameters.azu.json"

    # Virtual Network Identification
    [switch]$fetchVirtualNetworkId, # the script will fetch the network id based on the inline parameters VirtualNetworkName and VirtualNetworkResourceGroupName. Used to override template parameters and create a new subnet
    $VirtualNetworkName = "$ProjectName-hub-$Location", # ex. azu-hub-westus
    $VirtualNetworkResourceGroupName = "$ProjectName-hub-$Location", # ex. azu-hub-westus

    # Subnet acceleration
    $subnetPrefix_acceleration, # ex. "10.1.82.0/24"
    $NewOrExistingSubnetAcceleration = "existing", # If not set to "new", the script will skip the creation of the subnet

    # Appliance SSH public key
    ## Method1: set public key in inline parameters
    $adminPublicKey, # set your own public ssh key to skip ssh keypair generation
    ## Method2: generate in a local file
    [switch]$generateKeypair, # set to generate an ssh keypair for the appliance
    $passphrase="riverbed-community" # passphrase used in ssh keypair generation
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Deploy-Acceleration"

# Accept Marketplace Terms for SteelHead
$terms = Get-AzMarketplaceTerms -Publisher "riverbed" -Product "riverbed-steelhead-9-9-1"  -Name "riverbed-steelhead-9-9-1"
Set-AzMarketplaceTerms -Publisher "riverbed" -Product "riverbed-steelhead-9-9-1" -Name "riverbed-steelhead-9-9-1" -Accept -Terms $terms

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

# Set Azure context
if ($SubscriptionId) { Select-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop }
$azContext = Get-AzContext -ErrorAction Stop
$subscriptionId = $azContext.Subscription.Id

#endregion

# Create resource group if it does not exist
if ($null -eq (Get-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
}

# Fetch Virtual Network id
$virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $VirtualNetworkResourceGroupName -Name $VirtualNetworkName
$VirtualNetworkId = $virtualNetwork.Id

# Create the subnet acceleration
if ($NewOrExistingSubnetAcceleration -eq "new") {
    $virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $VirtualNetworkResourceGroupName -Name $VirtualNetworkName
    $output = Add-AzVirtualNetworkSubnetConfig -Name $subnetName_acceleration -VirtualNetwork $virtualNetwork -AddressPrefix $subnetPrefix_acceleration -ErrorAction Stop
    $virtualNetwork | Set-AzVirtualNetwork
}

#Generate an ssh keypair if ssh public key is not provided
if ($generateKeypair -and (!$adminPublicKey)) {
$keyFileName = "$artifactsDirectory\$ProjectName-sh-sshkey-$(Get-Date -Format "yyMMddHHmmss")"
ssh-keygen -q -f $keyFileName -t rsa -b 2048 -N $passphrase -C "riverbed-community"
$adminPublicKey = Get-Content "$keyFileName.pub"
Write-Output "Generated key pair: $keyFileName / $keyFileName.pub"
}

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

# Set optional template parameters overrides
if ($fetchVirtualNetworkId) { $parameters += @{ VirtualNetworkId = "$VirtualNetworkId" } }
if ($subnetPrefix_acceleration) { $parameters += @{ subnetPrefix_acceleration = "$subnetPrefix_acceleration" } }
if ($adminPublicKey) { $parameters += @{ adminPublicKey = "$adminPublicKey"  } }

# Deploy template
New-AzResourceGroupDeployment @parameters