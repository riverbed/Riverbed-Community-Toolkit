<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for SteelConnect EX in Azure
        
        Init, plan and apply Terraform template

    .Synopsis
        SteelConnect-EX_Deploy-Terraform.ps1

    .Description

    .EXAMPLE
        
        # prerequisites
        git clone https://github.com/riverbed/Riverbed-Community-Toolkit.git
        cd ./Riverbed-Community-Toolkit/SteelConnect/Azure-DeployHeadend/scripts
        ./SteelConnect-EX_Stage-DefaultHeadhendStandalone.ps1

        ../../Azure-DeployHeadend/scripts/SteelConnect-EX_Deploy-Terraform.ps1

#>

# Parameters
param(
$resourceGroupName="SteelConnect-EX-Headend"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): SteelConnect-EX_Deploy-Terraform"

# get azure context
$azureContext = Get-AzContext

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

$scope = "/subscriptions/$($azureContext.Subscription.SubscriptionId)/resourceGroups/$resourceGroupName"


# Initialize terraform
terraform init

# https://www.terraform.io/docs/providers/azurerm/index.html#skip_provider_registration
$env:ARM_SKIP_PROVIDER_REGISTRATION = "true"

# Fix terraform old AzureRM issue: https://www.terraform.io/docs/providers/azurerm/r/resource_group.html#import
"Importing Resource Group into terraform State"
terraform import azurerm_resource_group.rvbd_rg $scope

# Plan terraform deployment
$timestamp = (Get-Date -Format "yyMMddHHmmss")
$tfplan = "$timestamp.tfplan"
terraform plan -out $tfplan

# Apply terraform plan
terraform apply -auto-approve $tfplan 