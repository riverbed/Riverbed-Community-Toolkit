<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Test Sample AZI

        ! Currently Automation service and Runbooks are not available in Azure westindia region

    .EXAMPLE
        Get-AzContext
        .\quickstarts\Test-SampleAZI.ps1
#>

param(
$ProjectName = "azi",
$Location = "westindia", 
$subnetPrefix_acceleration = "10.5.82.0/24"
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
    -templateFilePath "101-service-chain-gw-appliance\azuredeploy-acceleration.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-acceleration.parameters.$ProjectName.json" `
    -artifactsDirectory "artifacts"

## Deploy route tables  - approx 1 min
.\101-service-chain-gw-appliance\scripts\Deploy-RouteTables.ps1 -ProjectName $ProjectName -Location $Location `
    -templateFilePath  "101-service-chain-gw-appliance\azuredeploy-routetables.json" `
    -templateParameterFilePath  "101-service-chain-gw-appliance\sample\azuredeploy-routetables.parameters.$ProjectName.json" `
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
Write-Output "3. Attach Route tables"

#endregion