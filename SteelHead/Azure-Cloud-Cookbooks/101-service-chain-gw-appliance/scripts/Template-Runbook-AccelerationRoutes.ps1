<#

    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Set or Bypass Acceleration Routes, attaching/detaching Route Tables to subnets: transit, servernetwork and acceleration.

        This is a script template to be used as a PowerShell Runbook. It requires configuration in the Customization region, setting variables for VNET, resource group, routes details.

        By default , the execution of the script will enable acceleration attaching Acceleration Route Tables.
        Setting parameter $BypassAcceleration will detach acceleration route tables and attach bypass routes instead.
    
    Usage in Azure Automation Runbook

        Requirements in Automation Account, Shared Resources
        * Modules: Az.Accounts, Az.Automation, Az.Network
        * Connections: AzureRunAsAccount

        Runbook definition
        * name: Set-AccelerationRoutes
        * type: PowerShell
        * description: Set or Bypass Acceleration
        * edit PowerShell runbook: copy and paste, configure the Customization region if needed
        * Save and Publish

    .EXAMPLE
        
        # Set acceleration
        Run job without parameters to enable Acceleration

    .EXAMPLE
        
        # Bypass Acceleration 
        Run job with BypassAcceleration = true  ("true" is correct. It is not "$true", as there Azure PowerShell RunBook does not take $ sign)

    .EXAMPLE
        
        # Verbose
        Run job with Verbose = true
#>

# parameters
param(
    [switch][bool]$BypassAcceleration  = $false,
    [switch][bool]$Verbose  = $false, 
    [switch][bool]$WhatIf  = $false
)

#region Customization
$virtualNetworkName = "{{virtualNetworkName}}" # VNET, ex. "azu-hub-westus"
$virtualNetworkResourceGroupName = "{{virtualNetworkResourceGroupName}}"  # ex. "azu-hub-westus"

$AccelerationRoutes = @{
    servernetwork = @{
        AddressPrefix = "{{subnetPrefix_servernetwork}}" # ex. "10.1.1.0/24"
        RouteTableId = "{{routeTableId_servernetwork_ACCELERATION}}" # ex. "/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-servernetwork-ACCELERATION"
    }
    transit = @{
        AddressPrefix = "{{subnetPrefix_transit}}" # ex. "10.1.0.0/24"
        RouteTableId = "{{routeTableId_transit_ACCELERATION}}" # ex."/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-transit-ACCELERATION"
    }
    acceleration = @{
        AddressPrefix = "{{subnetPrefix_acceleration}}" # ex. "10.3.82.0/24"
        RouteTableId = "{{routeTableId_acceleration}}" # ex."/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-acceleration"
    }
}

$BypassRoutes = @{
    servernetwork = @{
        AddressPrefix = "{{subnetPrefix_servernetwork}}" # ex. "10.1.1.0/24"
        RouteTableId = "{{routeTableId_servernetwork}}" # ex. "/subscriptions/1234-12341243-1243-12341324/resourceGroups/azu-acceleration/providers/Microsoft.Network/routeTables/azu-servernetwork"
    }
    transit = @{
        AddressPrefix = "{{subnetPrefix_transit}}" # ex. "10.1.0.0/24"
        RouteTableId = "{{routeTableId_transit}}"  # ex. empty to detach the Route Table
    }
}

#endregion

#region lib

Import-Module Az.Accounts
Import-Module Az.Network
Import-Module Az.Automation

#Use system-maganed identity instead of RunAsAccount
try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

#endregion


#variables
$routes = $AccelerationRoutes
if ($BypassAcceleration) {
    $routes = $BypassRoutes
}

$vnet = Get-AzVirtualNetwork -ResourceGroupName $virtualNetworkResourceGroupName -Name $virtualNetworkName

#verbose
if ($Verbose) {
    # Check subnet name, prefix and route table id
    Write-Output "-----------------"
    Write-Output "INITIAL STATE"
    Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet | % { "$($_.Name) ,  $($_.AddressPrefix) , $($_.RouteTable.Id)" }

    Write-Output "-----------------"

    if ($BypassAcceleration) { Write-Output "BYPASS ACCELERATION ROUTES:" } 
    else { Write-Output "SET ACCELERATION ROUTES:" } 

    foreach ($subnetName in $routes.Keys) { "$subnetName $($routes[$subnetName].AddressPrefix ; $routes[$subnetName].RouteTableId)"  }
}

# Prepare and apply config on the vnet
foreach ($subnetName in $routes.Keys) { 
    $routeTableId = $routes[$subnetName].RouteTableId
    $addressPrefix = $routes[$subnetName].AddressPrefix
    if (!$routeTableId) {
        #Disassociate"
        $subnet = ($vnet.Subnets | Where-Object { $_.Name -eq $subnetName })
        $subnet.RouteTable = $null
    }
    else {
       # Prepare config to associate Route tables to subnets
       $output = Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName -AddressPrefix $addressPrefix -RouteTableId $routeTableId -WarningAction SilentlyContinue
    }
}

#verbose
if ($Verbose) {
    # Check subnet name, prefix and route table id
    Write-Output "-----------------"
    Write-Output "VNET NEW CONFIG TO APPLY"
    Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet | % { "$($_.Name) ,  $($_.AddressPrefix) , $($_.RouteTable.Id)" }
}

# Apply
if (!$WhatIf) {
    Write-Output "-----------------"
    Write-Output "APLYING VNET NEW CONFIG"
    $output = Set-AzVirtualNetwork -VirtualNetwork $vnet
}

#verbose
if ($Verbose) {
    # Check subnet name, prefix and route table id
    Write-Output "-----------------"
    Write-Output "END STATE"
    $vnet = Get-AzVirtualNetwork -ResourceGroupName $virtualNetworkResourceGroupName -Name $virtualNetworkName
    Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet | % { "$($_.Name) ,  $($_.AddressPrefix) , $($_.RouteTable.Id)" }
}
