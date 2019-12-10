<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Deploy Logic Apps
    
    .EXAMPLE

    # Deploy the Logic Apps with specific resource group name and template parameters.
    # Credentials are provided via SecureStrings inline parameters
    .\scripts\Deploy-LogicApps-Simple.ps1 -ProjectName "yoursite" -Location "your-azure-location" -ResourceGroupName "your-rg" `
        -shApiUsername $shApiUsername_SecureString -shApiPassword shApiPassword_SecureString `
        -templateParameterFilePath ".\sample\azuredeploy-logicapps-simple.parameters.yoursite.json"

    .EXAMPLE

    # Deploy the Logic Apps with inline parameters for Credentials (securedStrings), shFQDN, ISE id and template params file path
    .\scripts\Deploy-LogicApps-Simple.ps1 -ProjectName "yoursite" -Location "your-azure-location" `
        -shApiUsername $shApiUsername_SecureString -shApiPassword shApiPassword_SecureString `
        -integrationServiceEnvironmentId "/subscriptions/1234-12341234/.../integrationServiceEnvironments/your-ise"
        -shFQDN "aze-sh82.your-private-domain.org" `
        -templateParameterFilePath ".\sample\azuredeploy-logicapps-simple.parameters.yoursite.json"

    .EXAMPLE

    # Deploy the Logic Apps searching the ISE by name and generating Set and Bypass webhooks on the existing Automation runboook
    .\scripts\Deploy-LogicApps-Simple.ps1 -ProjectName "aze" -Location "westeurope" `
        -searchIntegrationServiceEnvironmentIdByName "aze-ise-westeurope" `
        -shFQDN "aze-sh82.your-private-domain.org" `
        -shApiUsername (ConvertTo-SecureString -AsPlainText -Force "api-user") -shApiPassword (ConvertTo-SecureString -AsPlainText -Force "api-user-password") `
        -generateRunbookWebhook -AutomationAccountName "your-automation" -ResourceGroupAutomationAccount "your-automation-rg" -RunbookName "your-runbook"

    .EXAMPLE

    # Deploy the Logic Apps for sandbox sample AZE, using default naming (template parameters file path, resource group to search ISE, automation name to generate webhook)
    .\scripts\Deploy-LogicApps-Simple.ps1 -ProjectName "aze" -Location "westeurope" `
        -shApiUsername (ConvertTo-SecureString -AsPlainText -Force "api-user") -shApiPassword (ConvertTo-SecureString -AsPlainText -Force "api-user-password") `
        -generateRunbookWebhook
#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "logicapps-simple",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope", # ex. "westus"

    # Deployment parameters
    $ResourceGroupName = "$ProjectName-acceleration-$Location", # ex. "azu-acceleration-westus"
    $templateFilePath = ".\azuredeploy-$component.json", # ex. ".\azuredeploy-logicapps-simple.json"
    $artifactsDirectory = ".\sample",
    $templateParameterFilePath = "$artifactsDirectory\azuredeploy-$component.parameters.$ProjectName.json", # ".\sample\azuredeploy-logicapps-simple.parameters.azu.json"

    $integrationServiceEnvironmentId, # ex. "/subscriptions/1234-12341234/resourceGroups/azu-orchestration-westus/providers/Microsoft.Logic/integrationServiceEnvironments/azu-ise-westus" 
    $searchIntegrationServiceEnvironmentIdByName, # ex. "$ProjectName-ise-$Location" , "azu-ise-westus". If set, the script will try to fetch the id and set the variable $integrationServiceEnvironmentId

    # Logic Apps parameters
    
    ## Webhook uri
    ### Method1: set in parameters
    $uriSetAccelerationRoutes, # ex. "https://s24events.azure-automation.net/webhooks?token=12345678901"
    $uriBypassAccelerationRoutes, # ex. "https://s24events.azure-automation.net/webhooks?token=12345678902"
    ### Method2: create on the runbook
    [switch]$generateRunbookWebhook ,
    $RunbookName = "$ProjectName-Runbook-AccelerationRoutes", # ex. "azu-Runbook-AccelerationRoutes"
    $ResourceGroupAutomationAccount = $ResourceGroupName, # Resource Grouop that contains the Automation Account ex. "azu-acceleration-westus"
    $AutomationAccountName = "$ProjectName-automation-$Location" , # Name of the automation account , ex. "azu-automation-westus"
    $webhookName_SetAccelerationRoutes = "SetAccelerationRoutes",
    $webhookName_BypassAccelerationRoutes = "BypassAccelerationRoutes",
    $defaultValidityPeriod = 365, # validity period for the webhook (number of days), ex. 365

    ## Other logic apps parameters
    $shFQDN, # ex. "azu-sh82.acceleration.mycompany.com"
    [SecureString]$shApiUsername, # ex/ "api-user"
    [SecureString]$shApiPassword # ex. "api-user-password"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Deploy-LogicApps-Simple"

# Set Azure context
if ($SubscriptionId) { Select-AzSubscription -SubscriptionId $SubscriptionId -ErrorAction Stop }
$azContext = Get-AzContext -ErrorAction Stop
$subscriptionId = $azContext.Subscription.Id

#endregion

# Create resource group if it does not exist
if ($null -eq (Get-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $Location -Verbose -Force -ErrorAction Stop
}

if ($generateRunbookWebhook) {
    Write-Output "Creating webhook..."
    if (!$uriSetAccelerationRoutes) {
        $webhook = New-AzAutomationWebhook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
            -RunbookName $RunbookName -IsEnabled $true -ExpiryTime (Get-Date).AddDays($defaultValidityPeriod) -Force `
            -Name $webhookName_SetAccelerationRoutes
        $uriSetAccelerationRoutes = $webhook.WebhookURI
    }
    if (!$uriBypassAccelerationRoutes) {
        $webhook = New-AzAutomationWebhook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName `
            -RunbookName $RunbookName -IsEnabled $true -ExpiryTime (Get-Date).AddDays($defaultValidityPeriod) -Force `
            -Name $webhookName_BypassAccelerationRoutes -Parameters @{ BYPASSACCELERATION=$true}
        $uriBypassAccelerationRoutes = $webhook.WebhookURI
    }
}

# Splat runtime parameters
$parameters = @{
    projectName = $ProjectName
    Name = $component 
    ResourceGroupName = $resourceGroupName
    Location = $Location
    TemplateFile = $templateFilePath
    TemplateParameterFile = $templateParameterFilePath
    Verbose = $true
    ErrorVariable = "ErrorMessages"
}

# Fetch integrationServiceEnvironmentId template parameter by searching name and deploy
if ((!$integrationServiceEnvironmentId) -and ($searchIntegrationServiceEnvironmentIdByName)) {
    $integrationServiceEnvironmentId = (Get-AzResource -Name $searchIntegrationServiceEnvironmentIdByName -ResourceGroupName $ResourceGroupName -ResourceType "Microsoft.Logic/integrationServiceEnvironments" -ErrorAction Stop).Id
    $parameters += @{ integrationServiceEnvironmentId = $integrationServiceEnvironmentId }
}

# Set optional template parameters overrides
if ($shFQDN) { $parameters += @{ shFQDN = $shFQDN } }
if ($shApiUsername) { $parameters += @{ shApiUsername = $shApiUsername } }
if ($shApiPassword) { $parameters += @{ shApiPassword = $shApiPassword } }
if ($uriSetAccelerationRoutes) { $parameters += @{ uriSetAccelerationRoutes = $uriSetAccelerationRoutes } }
if ($uriBypassAccelerationRoutes) { $parameters += @{ uriBypassAccelerationRoutes = $uriBypassAccelerationRoutes } }

# Deploy
New-AzResourceGroupDeployment @parameters