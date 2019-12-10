<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Deploy Automation

    .EXAMPLE

        # Create the runbook mapping network resources name to the sample model
        $parameters = @{
            VirtualNetworkName = "azk-hub-koreacentral"
            VirtualNetworkResourceGroupName = "azk-hub-koreacentral"
            RouteTablesResourceGroupName = "azk-acceleration-koreacentral"
            subnetName_transit = "transit"
            subnetName_servernetwork = "servernetwork"
            subnetName_acceleration = "acceleration"
            routeTableName_servernetwork = "azk-servernetwork"
            routeTableName_acceleration = "azk-acceleration"
            routeTableName_transit = "azk-transit-ACCELERATION"
            routeTableName_servernetwork_ACCELERATION = "azk-servernetwork-ACCELERATION"
        }
        .\scripts\Create-AccelerationRoutes-Runbook.ps1 -ProjectName "azk" -Location "koreacentral" -AutomationAccountName "azk-automation-koreacentral" -searchResourcesDetailByName @parameters

    .EXAMPLE

        # Create the runbook for the sandbox sample AZE, using default naming for existing objects
        .\scripts\Create-AccelerationRoutes-Runbook.ps1 -ProjectName "aze" -Location "westeurope" -searchResourcesDetailByName


#>

param(
    $SubscriptionId, # ex. "234123143-1234-1234-1234-1234",

    # Parameters used resources and configuration elements naming
    $component = "automation",
    $ProjectName = "aze", # ex. "azu"
    $Location = "westeurope", # ex. "westus"

    # Deployment parameters
    $ResourceGroupName = "$ProjectName-acceleration-$Location", # Resource Group where to create new resources ex. azu-acceleration-westus
    $AutomationAccountName = "$ProjectName-$component-$Location" , # Name of the automation account where to create the Runbook ex. azu-automation-westus

    ## Subnets mapping details

    ### Method1: Set manually all details:
    $VirtualNetworkId = "" , # ex. "/subscriptions/1234-12341234-1234-1234/resourceGroups/azu-hub-westus/providers/Microsoft.Network/virtualNetworks/azu-hub-westus"
    $subnetPrefix_transit, # ex. "10.1.0.0/24"
    $subnetPrefix_servernetwork, # ex. "10.1.1.0/24"
    $subnetPrefix_acceleration, # ex. "10.1.82.0/24"
    $routeTableId_servernetwork , # ex. "/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-servernetwork"
    $routeTableId_acceleration , # ex."/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-acceleration"
    $outeTableId_transit , # ex. empty
    $routeTableId_transit_ACCELERATION ,  # ex."/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-transit-ACCELERATION"
    $routeTableId_servernetwork_ACCELERATION , # ex. "/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-servernetwork-ACCELERATION"

    ### Method2: Search Resources Details. The switch parameter searchResourcesDetailByName mst be set with all parameters for resources names (subnet, vnet, resource groups)
    [switch]$searchResourcesDetailByName,
    $VirtualNetworkName = "$ProjectName-hub-$Location", # VNET, ex. "azu-hub-westus"
    $VirtualNetworkResourceGroupName = "$ProjectName-hub-$Location",  # ex. "azu-hub-westus"
    $RouteTablesResourceGroupName = "$ProjectName-acceleration-$Location",  # ex. "azu-acceleration-westus"
    $subnetName_transit = "transit", # ex. "transit"
    $subnetName_servernetwork = "servernetwork", # ex. "servernetwork"
    $subnetName_acceleration = "acceleration",  # ex. "acceleration"
    $routeTableName_servernetwork = "$ProjectName-servernetwork", # ex. "azu-servernetwork"
    $routeTableName_acceleration = "$ProjectName-acceleration", # ex. "azu-acceleration"
    $routeTableName_transit , # ex. empty
    $routeTableName_transit_ACCELERATION = "$ProjectName-transit-ACCELERATION", # ex. "azu-transit-ACCELERATION"
    $routeTableName_servernetwork_ACCELERATION = "$ProjectName-servernetwork-ACCELERATION", # ex. "azu-servernetwork-ACCELERATION"

    #########################
    # Staging artifacts
    $inputTemplateScriptFile = ".\scripts\Template-Runbook-AccelerationRoutes.ps1" , # Template script of the runbook ex. "Template-Runbook-AccelerationRoutes.ps1"
    $artifactsDirectory = ".\sample",
    $outputScriptFile = "$artifactsDirectory\$ProjectName-Runbook-AccelerationRoutes.ps1" , # ex. "azu-Runbook-AccelerationRoutes.ps1"
    $runbookName = "$ProjectName-Runbook-AccelerationRoutes"  # The runbook name must be the same as the script name ex. "azu-Runbook-AccelerationRoutes"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Create-AccelerationRoutes-Runbook"

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

## url from https://www.powershellgallery.com/
$urlAzAccounts="https://psg-prod-eastus.azureedge.net/packages/az.accounts.1.6.4.nupkg"
$urlAzNetwork = "https://psg-prod-eastus.azureedge.net/packages/az.network.2.1.0.nupkg"
$urlAzAutomation="https://psg-prod-eastus.azureedge.net/packages/az.automation.1.3.4.nupkg" 

# Function to deploy Automation module synchronously
# Requires global variables
#   * $ResourceGroupName
#   * $AutomationAccountName
# Example: DeployAutomationModuleGallery -moduleName "Az.Accounts" -moduleUrl $urlAzAccounts
function DeployAutomationModuleGallery() {
    param(
        $moduleName, $moduleUrl,
        $polling_interval = 15
    )

    while($true) {
        if ($statusModule.ProvisioningState -ne "Succeeded") {
            $statusModule = Get-AzAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $moduleName -ErrorAction SilentlyContinue
            if (! $statusModule) {
                $statusModule = New-AzAutomationModule -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName  -Name $moduleName -ContentLinkUri  $moduleUrl
            }
        }
        Write-Output "$($statusModule.Name): $($statusModule.ProvisioningState)"
        if ($statusModule.ProvisioningState -eq "Failed") {
            Throw("error with Automation modules, please delete module $moduleName in failed state and retry.")
        } elseif ( $statusModule.ProvisioningState -eq "Succeeded") {
            break
        }
        Start-Sleep -Seconds $polling_interval
    }
}

  

#endregion

Write-Output "Setting prerequisites..."

# Add modules Az.Accounts and then Az.Automation and Az.Network, if not already installed
DeployAutomationModuleGallery -moduleName "Az.Accounts" -moduleUrl $urlAzAccounts
DeployAutomationModuleGallery -moduleName "Az.Network" -moduleUrl $urlAzNetwork
DeployAutomationModuleGallery -moduleName "Az.Automation" -moduleUrl $urlAzAutomation

# Cleanup Tutorial runbooks
try {
    Remove-AzAutomationRunbook -Name "AzureAutomationTutorial" -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Force -ErrorAction SilentlyContinue
    Remove-AzAutomationRunbook -Name "AzureAutomationTutorialPython2" -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Force -ErrorAction SilentlyContinue
    Remove-AzAutomationRunbook -Name "AzureAutomationTutorialScript" -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Force -ErrorAction SilentlyContinue

    # TODO: fix the following commented code to limit Run As Account permissions to the minimum: https://docs.microsoft.com/en-us/azure/automation/manage-runas-account#limiting-run-as-account-permissions
    # $automationConnection = Get-AzAutomationConnection -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name "AzureRunAsConnection" 
    # $applicationId = $automationConnection.FieldDefinitionValues.ApplicationId

} catch {
    Write-Warning "Please check the AutomationAccount has an AzureRunAsConnection set properly."
}

Write-Output "Preparing Runbook..."

# If Method2 has been selected then search missing Resources Details
if($searchResourcesDetailByName) {
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $VirtualNetworkResourceGroupName -Name $VirtualNetworkName -ErrorAction Stop
    if (!$subnetPrefix_servernetwork) { $subnetPrefix_servernetwork = ($vnet.subnets | Where-Object { $_.name -eq $subnetName_servernetwork } | Select-Object addressPrefix).addressPrefix }
    if (!$subnetPrefix_transit) { $subnetPrefix_transit = ($vnet.subnets | Where-Object { $_.name -eq $subnetName_transit } | Select-Object addressPrefix).addressPrefix }
    if (!$subnetPrefix_acceleration) { $subnetPrefix_acceleration = ($vnet.subnets | Where-Object { $_.name -eq $subnetName_acceleration } | Select-Object addressPrefix).addressPrefix }
    if (!$routeTableId_servernetwork) { $routeTableId_servernetwork = (Get-AzRouteTable -ResourceGroupName $RouteTablesResourceGroupName -Name $routeTableName_servernetwork -ErrorAction Stop).Id }
    if (!$routeTableId_acceleration) { $routeTableId_acceleration = (Get-AzRouteTable -ResourceGroupName $RouteTablesResourceGroupName -Name $routeTableName_acceleration -ErrorAction Stop).Id }
    if (!$routeTableId_servernetwork_ACCELERATION) { $routeTableId_servernetwork_ACCELERATION = (Get-AzRouteTable -ResourceGroupName $RouteTablesResourceGroupName -Name $routeTableName_servernetwork_ACCELERATION -ErrorAction Stop).Id }
    if (!$routeTableId_transit) { if ($routeTableName_transit) { $routeTableId_transit = (Get-AzRouteTable -ResourceGroupName $RouteTablesResourceGroupName -Name $routeTableName_transit -ErrorAction Stop).Id } }
    if (!$routeTableId_transit_ACCELERATION) { $routeTableId_transit_ACCELERATION = (Get-AzRouteTable -ResourceGroupName $RouteTablesResourceGroupName -Name $routeTableName_transit_ACCELERATION -ErrorAction Stop).Id }
}

# Customize the template and Import it as a PowerShell Runbook
$script = (Get-Content $inputTemplateScriptFile) 
$script = $script `
            -replace "{{subscriptionId}}", $subscriptionId `
            -replace "{{virtualNetworkName}}", $VirtualNetworkName `
            -replace "{{virtualNetworkResourceGroupName}}", $VirtualNetworkResourceGroupName `
            -replace "{{subnetPrefix_servernetwork}}", $subnetPrefix_servernetwork `
            -replace "{{subnetPrefix_transit}}", $subnetPrefix_transit `
            -replace "{{subnetPrefix_acceleration}}", $subnetPrefix_acceleration `
            -replace "{{routeTableId_servernetwork}}", $routeTableId_servernetwork `
            -replace "{{routeTableId_acceleration}}", $routeTableId_acceleration `
            -replace "{{routeTableId_servernetwork_ACCELERATION}}", $routeTableId_servernetwork_ACCELERATION `
            -replace "{{routeTableId_transit}}", $routeTableId_transit `
            -replace "{{routeTableId_transit_ACCELERATION}}", $routeTableId_transit_ACCELERATION
$script | Out-File $outputScriptFile -Force

Write-Output "Publishing..."
$runbook = Import-AzAutomationRunbook  -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $runbookName -Path $outputScriptFile -Type PowerShell -Force 
Publish-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $runbookName