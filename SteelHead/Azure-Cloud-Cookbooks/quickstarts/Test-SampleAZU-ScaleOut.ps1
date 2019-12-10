<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Test Sample AZU Scale

    .EXAMPLE

        # Deploy sample sandbox AZU in westus region, no gateway appliance, acceleration with 10 nodes, Runbook.
        Get-AzContext
        .\quickstarts\Test-SampleAZU-ScaleOut.ps1
#>

$ProjectName = "azu"
$Location = "westus"
$subnetPrefix_acceleration = "10.1.82.0/24"

.\quickstarts\Test-SampleAZE-ScaleOut.ps1 -ProjectName $ProjectName -Location $Location -subnetPrefix_acceleration $subnetPrefix_acceleration