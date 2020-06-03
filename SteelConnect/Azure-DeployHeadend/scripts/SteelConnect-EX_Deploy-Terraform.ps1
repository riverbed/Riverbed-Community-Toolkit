<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for SteelConnect EX in Azure
        
        Init, plan and apply Terraform template

    .Synopsis
        SteelConnect-EX_Stage-DefaultHeadhendStandalone.ps1

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

# get azure context
$azureContext = Get-AzContext
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