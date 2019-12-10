<#
    .DESCRIPTION
        Riverbed Community Toolkit
        Cloud Community Cookbooks for Acceleration in Azure

        Prepare Configuration for CloudSteelHead

    .EXAMPLE

    .\102-scale-out\scripts\Prepare-CloudSteelHeadConfiguration.ps1 -adminPassword "passwordAz19!" -apiPassword "passwordAz19!" `
        -projectName azu -id 100 -shIpAddress "10.1.82.100" -oneTimeToken "" `

    .\102-scale-out\scripts\Prepare-CloudSteelHeadConfiguration.ps1 -adminPassword "passwordAz19!" -apiPassword "passwordAz19!" `
        -projectName azu -id 101 -shIpAddress "10.1.82.101" -oneTimeToken "" `

    .\102-scale-out\scripts\Prepare-CloudSteelHeadConfiguration.ps1 -adminPassword "passwordAz19!" -apiPassword "passwordAz19!" `
        -projectName azu -id 102 -shIpAddress "10.1.82.102" -oneTimeToken "" `

#>


param(
    $projectName = "azu",
    $id = 100,
    $adminPassword = "{{your-user-password}}",
    $shHostname = "$projectName-sh$id",
    $oneTimeToken = "{{your-one-time-token}}",
    $apiUsername = "api-monitoring",
    $apiPassword =  "{{your-api-user-password}}",
    $apiCode = "eyJhdWQiOiAiaHR0cHM6Ly9hbW5lc2lhYy9hcGkvY29tbW9uLzEuMC90b2tlbiIsICJpc3MiOiAiaHR0cHM6Ly9hbW5lc2lhYyIsICJwcm4iOiAiYWRtaW4iLCAianRpIjogIjU4NjFiZDQyLTYzMzktNDc0Ni04MDdhLTY3ODQxYTNhMzM2ZiIsICJleHAiOiAiMCIsICJpYXQiOiAiMTU3NTM3NTU2MyJ9",
    $shIpAddress = "10.1.82.82",

    #########################
    # Staging artifacts
    $inputTemplateConfigurationFile = ".\scripts\Template-CloudSteelHeadConfiguration.cli" , 
    $artifactsDirectory = ".\sample",
    $outputConfigurationFile = "$artifactsDirectory\$shHostname-CloudSteelHeadConfiguration.cli"
)

#region Riverbed Community Lib
Write-Output "$(Get-Date -Format "yyMMddHHmmss"): Prepare-CloudSteelHeadConfiguration"
#endregion


# Customize the template 
$script = (Get-Content $inputTemplateConfigurationFile) 
$script = $script `
    -replace "{{adminPassword}}", $adminPassword `
    -replace "{{shHostname}}", $shHostname `
    -replace "{{oneTimeToken}}", $oneTimeToken `
    -replace "{{apiUsername}}", $apiUsername `
    -replace "{{apiPassword}}", $apiPassword `
    -replace "{{apiCode}}", $apiCode 
$script | Out-File $outputConfigurationFile -Force