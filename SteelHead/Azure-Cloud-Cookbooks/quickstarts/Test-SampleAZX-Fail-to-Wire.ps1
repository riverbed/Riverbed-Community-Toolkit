<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Test Sample AZX

    .EXAMPLE

        # Deploy sample sandbox AZX in eastus2 region
        Get-AzContext
        .\quickstarts\Test-SampleAZX-Fail-to-Wire.ps1
#>

$ProjectName = "azx"
$Location = "eastus2"
$subnetPrefix_acceleration = "10.6.82.0/24"
$subnetPrefixISE1="10.6.253.0/26"
$subnetPrefixISE2="10.6.253.64/26"
$subnetPrefixISE3="10.6.253.128/26"
$subnetPrefixISE4="10.6.253.192/26"

.\quickstarts\Test-SampleAZE-Fail-to-Wire.ps1 -ProjectName $ProjectName -Location $Location -subnetPrefix_acceleration $subnetPrefix_acceleration `
    -subnetPrefixISE1 $subnetPrefixISE1 -subnetPrefixISE2 $subnetPrefixISE2 -subnetPrefixISE3 $subnetPrefixISE3 -subnetPrefixISE4 $subnetPrefixISE4