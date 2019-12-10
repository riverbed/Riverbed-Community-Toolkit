<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Test Sample AZK

    .EXAMPLE

        # Deploy sample sandbox AZK in koreacentral region
        Get-AzContext
        .\quickstarts\Test-SampleAZK.ps1

        # ProjectName = "azk"
        # Location = "koreacentral"
        # subnetPrefix_acceleration = "10.82.82.0/24"
        # sshPublicKeyFilePath =  ".\sample\community-test-sshkey.pub"
) 
#>

$startDate = Get-Date

#region Prerequisites

## Create artifacts folder
if (! (Test-Path "artifacts")) { md artifacts }

## Check Azure account and subscription is connected
Get-AzContext

## or Select-AzSubscription -SubscriptionName Dev

##  Deploy sandbox sample topology without gateway
.\101-service-chain-gw-appliance\scripts\Deploy-Sandbox.ps1 -ProjectName "azk" -Location "koreacentral" -CreateVirtualMachine_gateway skip -adminPublicKey (Get-Content ".\101-service-chain-gw-appliance\sample\community-test-sshkey.pub")  `
    -templateFilePath "101-service-chain-gw-appliance\azuredeploy-sandbox.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-sandbox.parameters.azk.json" `
    -artifactsDirectory "artifacts" 

#endregion

#endregion

#region Acceleration

# Create the subnet acceleration
.\101-service-chain-gw-appliance\scripts\Create-SubnetAcceleration.ps1 -VirtualNetworkResourceGroupName "azk-hub-koreacentral" -VirtualNetworkName "azk-hub-koreacentral" -SubnetPrefix_acceleration "10.82.82.0/24"

# Deploy acceleration (post-deployment steps required: configure SteelHead appliance)
.\101-service-chain-gw-appliance\scripts\Deploy-Acceleration.ps1 -ProjectName "azk" -Location "koreacentral" -ResourceGroupName "azk-acceleration-koreacentral" -fetchVirtualNetworkId -VirtualNetworkResourceGroupName "azk-hub-koreacentral" -VirtualNetworkName "azk-hub-koreacentral" -adminPublicKey (Get-Content ".\101-service-chain-gw-appliance\sample\community-test-sshkey.pub") `
    -templateFilePath "101-service-chain-gw-appliance\azuredeploy-acceleration.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-acceleration.parameters.azk.json" `
    -artifactsDirectory "artifacts"

## Deploy route tables
.\101-service-chain-gw-appliance\scripts\Deploy-RouteTables.ps1 -ProjectName "azk" -Location "koreacentral" -ResourceGroupName "azk-acceleration-koreacentral" `
    -templateFilePath  "101-service-chain-gw-appliance\azuredeploy-routetables.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-routetables.parameters.azk.json" `
    -artifactsDirectory "artifacts"

#endregion

#region Automation

## Deploy Runbook (post-deployment steps required: create RunAsAccount in Automation Account)
.\101-service-chain-gw-appliance\scripts\Deploy-Automation.ps1 -ProjectName "azk" -Location "koreacentral" -ResourceGroupName "azk-acceleration-koreacentral" -automationAccountName "azk-automation-koreacentral" 

### Create the runbook for the sample AZK, mapping the names of actual subnets and route tables
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
.\101-service-chain-gw-appliance\scripts\Create-AccelerationRoutes-Runbook.ps1 -ProjectName "azk" -Location "koreacentral" -AutomationAccountName "azk-automation-koreacentral" -searchResourcesDetailByName @parameters `
    -inputTemplateScriptFile "101-service-chain-gw-appliance\scripts\Template-Runbook-AccelerationRoutes.ps1" `
    -artifactsDirectory "artifacts"

#endregion

#####################################

#region Post-Deployment

$endDate = Get-Date
"Duration: $($endDate - $startDate)"

Write-Output "Post-deployment configuration required:"
Write-Output "1. Deploy Gateway appliance in the VNET"
Write-Output "2. Configure SteelHead"
Write-Output "3. Create RunAsAccount in Automation"
Write-Output "4. Execute the Runbook to set acceleration"

# Execute the Runbook to set acceleration (requires RunAsAccount to be created)
# Start-AzAutomationRunbook -ResourceGroupName "azk-acceleration-koreacentral" -AutomationAccountName "azk-automation-koreacentral" -Name "azk-Runbook-AccelerationRoutes"

#endregion
