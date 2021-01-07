<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Deploy Route Tables

    .EXAMPLE

        # 1. Create a template parameters file
        # 2. Deploy route tables in a specific Resource Group name and Location
        .\scripts\Deploy-RouteTables.ps1 -ProjectName "azk" -Location "koreacentral" -ResourceGroupName "your-acceleration-rg" `
            -templateParameterFilePath ".\sample\azuredeploy-routetables.parameters.azk.json"

    .EXAMPLE

        # Deploy route tables for sandbox sample AZE topology without gateway (default path for template parameter file sample\azuredeploy-routetables.parameters.yoursite.json)
        .\scripts\Deploy-RouteTables.ps1 -ProjectName "aze" -Location "westeurope"
#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "routetables",
    $ProjectName = "aze",  # ex. "azu"
    $Location = "westeurope", # ex. "westus"

    # Deployment standard parameters
    $ResourceGroupName = "$ProjectName-acceleration-$Location", # ex. azu-acceleration-westus
    $templateFilePath = ".\azuredeploy-$component.json", # ex. ".\azuredeploy-routetables.json"
    $artifactsDirectory = ".\sample",
    $templateParameterFilePath = "$artifactsDirectory\azuredeploy-$component.parameters.$ProjectName.json" # ex. ".\sample\azuredeploy-routetables.parameters.azu.json"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Deploy-RouteTables"

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

# Create resource group if it does not exist
if ($null -eq (Get-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
}

# Splat runtime parameters
$parameters = @{
    projectName = "$ProjectName"
    Name = "$component"
    ResourceGroupName = "$resourceGroupName"
    Location = $Location
    TemplateFile = "$templateFilePath"
    TemplateParameterFile = "$templateParameterFilePath"
    Verbose = $true
    ErrorVariable = "ErrorMessages"
}

# Deploy template with overrides
New-AzResourceGroupDeployment @parameters