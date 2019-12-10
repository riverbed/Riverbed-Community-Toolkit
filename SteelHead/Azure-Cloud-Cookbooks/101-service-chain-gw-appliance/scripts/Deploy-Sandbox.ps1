<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Create a simple test environment in your subscription

    .EXAMPLE

        # Deploy sample AZK without gateway
        .\scripts\Deploy-Sandbox.ps1 -ProjectName "azk" -Location "koreacentral" `
            -CreateVirtualMachine_gateway skip -ResourceGroupName "your-rg" -VirtualNetworkName "azk-hub-koreacentral"

    .EXAMPLE

        # Deploy sandbox sample AZE topology without gateway, using default naming for related resources
        .\scripts\Deploy-Sandbox.ps1 -ProjectName "aze" -Location "westeurope" -CreateVirtualMachine_gateway skip 
#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "hub",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope", # ex. "westus"

    # Deployment standard parameters
    $ResourceGroupName = "$ProjectName-$component-$Location", # ex. "aze-hub-westeurope"
    $templateFilePath = ".\azuredeploy-sandbox.json", # ex. ".\azuredeploy.json"
    $artifactsDirectory = ".\sample",
    $templateParameterFilePath = "$artifactsDirectory\azuredeploy-sandbox.parameters.$ProjectName.json", # ex. ".\azuredeploy.parameters.azu.json"

    $VirtualNetworkName = "$ProjectName-hub-$Location", # ex. "aze-hub-westeurope"
    $CreateVirtualMachine_gateway = "create" , # "create" or "skip" 

    $adminPublicKey, # set your own public ssh key to skip ssh keypair generation

    #########################
    # Staging artifacts
    $passphrase="riverbed-community" # passphrase used in ssh keypair generation
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Deploy-Sandbox"

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

#Generate an ssh keypair if ssh public key is not provided
if (!$adminPublicKey) {
$keyFileName = "$artifactsDirectory\$ProjectName-vm-sshkey-$(Get-Date -Format "yyMMddHHmmss")"
ssh-keygen -q -f $keyFileName -t rsa -b 2048 -N $passphrase -C "riverbed-community"
$adminPublicKey = Get-Content "$keyFileName.pub"
Write-Output "Generated key pair: $keyFileName / $keyFileName.pub"
}

# Splat runtime parameters
$parameters = @{
    projectName = $ProjectName
    Name = $component 
    ResourceGroupName = $resourceGroupName
    TemplateFile = $templateFilePath
    TemplateParameterFile = $templateParameterFilePath
    Verbose = $true
    ErrorVariable = "ErrorMessages"
}

# Set optional template parameters overrides
if ($CreateVirtualMachine_gateway) { $parameters += @{ CreateVirtualMachine_gateway = $CreateVirtualMachine_gateway } }
if ($VirtualNetworkName) { $parameters += @{ VirtualNetworkName = $VirtualNetworkName } }
if ($adminPublicKey) { $parameters += @{ adminPublicKey_gw = "$adminPublicKey" ;  adminPublicKey_workload = "$adminPublicKey" } }

# Deploy template
New-AzResourceGroupDeployment @parameters