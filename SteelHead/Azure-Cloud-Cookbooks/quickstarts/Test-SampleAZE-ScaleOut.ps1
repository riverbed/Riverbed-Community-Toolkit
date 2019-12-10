<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Test Sample AZE Scale

    .EXAMPLE

        # Deploy sample sandbox AZE in westeurope region and acceleration
        Get-AzContext
        .\quickstarts\Test-SampleAZE-ScaleOut.ps1
#>

param(
$ProjectName = "aze",
$Location = "westeurope", 
$subnetPrefix_acceleration = "10.3.82.0/24"
) 

$startDate = Get-Date

#region Prerequisites 

## Create artifacts folder
if (! (Test-Path "artifacts")) { md artifacts }

## Check Azure account and subscription is connected
Get-AzContext

## or Select-AzSubscription -SubscriptionName Dev

##  Deploy sandbox topology without gateway (post-deployment steps required: deploy gateway appliance, ex. sd-wan) - less than 10 min.
.\101-service-chain-gw-appliance\scripts\Deploy-Sandbox.ps1 -ProjectName $ProjectName -Location $Location -CreateVirtualMachine_gateway skip `
    -templateFilePath "101-service-chain-gw-appliance\azuredeploy-sandbox.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-sandbox.parameters.$ProjectName.json" `
    -artifactsDirectory "artifacts" 

#endregion

#region Acceleration

## Create the subnet acceleration - approx. 30 secs
.\101-service-chain-gw-appliance\scripts\Create-SubnetAcceleration.ps1 -ProjectName $ProjectName -Location $Location -subnetPrefix_acceleration $subnetPrefix_acceleration

## Deploy acceleration (post-deployment steps required: configure SteelHead appliance) - less than 10 min.
.\101-service-chain-gw-appliance\scripts\Deploy-Acceleration.ps1 -ProjectName $ProjectName -Location $Location -generateKeypair -fetchVirtualNetworkId `
    -templateFilePath "102-scale-out\azuredeploy-acceleration-scale.json" `
    -templateParameterFilePath  "102-scale-out\sample\azuredeploy-acceleration-scale.parameters.$ProjectName.json" `
    -artifactsDirectory "artifacts"

## Deploy route tables - approx. 1 min
.\101-service-chain-gw-appliance\scripts\Deploy-RouteTables.ps1 -ProjectName $ProjectName -Location $Location `
    -templateFilePath  "101-service-chain-gw-appliance\azuredeploy-routetables.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-routetables.parameters.$ProjectName.json" `
    -artifactsDirectory "artifacts"

## Prepare configurations
.\102-scale-out\scripts\Prepare-CloudSteelHeadConfiguration.ps1 -adminPassword "passwordAz19!" -apiPassword "passwordAz19!" `
    -projectName azu -id 100 -shIpAddress "10.1.82.100" -oneTimeToken "" `
    -artifactsDirectory "artifacts" -inputTemplateConfigurationFile ".\102-scale-out\scripts\Template-CloudSteelHeadConfiguration.cli"

.\102-scale-out\scripts\Prepare-CloudSteelHeadConfiguration.ps1 -adminPassword "passwordAz19!" -apiPassword "passwordAz19!" `
    -projectName azu -id 101 -shIpAddress "10.1.82.101" -oneTimeToken "" `
    -artifactsDirectory "artifacts" -inputTemplateConfigurationFile ".\102-scale-out\scripts\Template-CloudSteelHeadConfiguration.cli"

.\102-scale-out\scripts\Prepare-CloudSteelHeadConfiguration.ps1 -adminPassword "passwordAz19!" -apiPassword "passwordAz19!" `
    -projectName azu -id 102 -shIpAddress "10.1.82.102" -oneTimeToken "" `
    -artifactsDirectory "artifacts" -inputTemplateConfigurationFile ".\102-scale-out\scripts\Template-CloudSteelHeadConfiguration.cli"

#endregion

#region Automation

## Deploy Runbook (post-deployment steps required: create RunAsAccount in Automation Account) - approx. 10s
.\101-service-chain-gw-appliance\scripts\Deploy-Automation.ps1 -ProjectName  $ProjectName -Location $Location

### Create the runbook - approx. 5 min
.\101-service-chain-gw-appliance\scripts\Create-AccelerationRoutes-Runbook.ps1 -ProjectName  $ProjectName -Location $Location -searchResourcesDetailByName `
    -inputTemplateScriptFile "101-service-chain-gw-appliance\scripts\Template-Runbook-AccelerationRoutes.ps1" `
    -artifactsDirectory "artifacts"

#endregion

#####################################

#region Post-Deployment

$endDate = Get-Date
Write-Output "Duration: $($endDate - $startDate)"
Write-Output "---"
Write-Output "Post-deployment configuration required:"
Write-Output "1. Deploy Gateway appliance in the VNET"
Write-Output "2. Configure SteelHead"
Write-Output "3. Create RunAsAccount in Automation"
Write-Output "4. Execute the Runbook to set acceleration"

# Execute the Runbook to set acceleration (requires RunAsAccount to be created)
# Start-AzAutomationRunbook -ResourceGroupName "$ProjectName-acceleration-$Location" -AutomationAccountName "$ProjectName-automation-$Location" -Name "$ProjectName-Runbook-AccelerationRoutes"

#endregion