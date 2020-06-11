<#
    .DESCRIPTION
        Riverbed Community Toolkit
                
        Simple script to generate Service Principal in Azure to setup SteelConnect connector

    .Synopsis
        SteelConnect-EX_Generate-AzureCredentials

    .Description

    .EXAMPLE
        
        ./SteelConnect-EX_Generate-AzureCredentials.ps1

#>

# variables
$timestamp = (Get-Date -Format "yyMMddHHmmss")
$ServicePrincipalName = "Riverbed-Community-SteelConnect-$timestamp"

$azureContext = Get-AzContext
$tenantId = $azureContext.Tenant.Id
$subscriptionId = $azureContext.Subscription.Id
# create service principal with the role Contributor on the subscription
$sp = New-AzADServicePrincipal -DisplayName $ServicePrincipalName
$clientSecret = ConvertFrom-SecureString $sp.Secret -AsPlainText
$clientId=$sp.ApplicationId

#output
"Subscription ID: $subscriptionId"
"Tenant ID: $tenantId"
"Application ID / Client ID: $clientId" 
"Secret Key: $clientSecret"
