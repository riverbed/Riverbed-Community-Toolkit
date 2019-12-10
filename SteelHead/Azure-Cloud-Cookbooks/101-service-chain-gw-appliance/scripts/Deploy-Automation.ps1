<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Deploy Automation

    .EXAMPLE

        # Deploy the automation for sample AZK with specific name and Resource Group name
        .\scripts\Deploy-Automation.ps1 -ProjectName "azk" -Location "koreacentral" -automationAccountName "azk-automation-koreacentral" -ResourceGroupName "your-acceleration-rg"

    .EXAMPLE

        # Deploy route tables for sandbox sample AZE, using the default naming
        .\scripts\Deploy-Automation.ps1 -ProjectName "aze" -Location "westeurope"
#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "automation",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope", # ex. "westus"

    # Deployment parameters
    $ResourceGroupName = "$ProjectName-acceleration-$Location", # ex. azu-acceleration-westus
    $automationAccountName = "$ProjectName-$component-$Location" ,  # ex. azu-automation-westus
    $Plan = "Basic"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Deploy-Automation"

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

# Create automation
New-AzAutomationAccount -ResourceGroupName $resourceGroupName -Location $Location -Plan Basic -Name $automationAccountName -ErrorAction Stop