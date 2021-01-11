<#
.Synopsis
   Aternity - Remediation Script: Remediation-WebProxy-SetExplicit
.DESCRIPTION
	Set an explicit Proxy in Internet Settings

    Require Aternity Agent 12.0.1.128 or later

	Aternity References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Set explicit web proxy
   Description: Set the web proxy in Internet Settings
   Script Privileges: unchecked (run in User context)
   Script parameter
       Parameter name: Proxy
       Mandatory: checked
       Description: Proxy IP address
       Sample: 10.82.82.82:8080
       Message From: IT Service Desk
    Header: Reset Web Proxy in Internet Settings
    Question: Click OK to apply
#>

$Proxy = $args[0]

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

#region Remediation action logic

    # parameters
    if (! $Proxy) { throw "Proxy parameter is empty`n" }

    # variables
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
    if (! (Test-Path $registryPath)) { throw "Could not find $registryPath" }

    #lib
    function Get-ProxySettings() {
        $ProxyEnableValue = (Get-ItemProperty -Name ProxyEnable -path $registryPath -ea SilentlyContinue).ProxyEnable
        $ProxyServerValue = (Get-ItemProperty -Name ProxyServer -path $registryPath -ea SilentlyContinue).ProxyServer
        $ProxyOverrideValue = (Get-ItemProperty -Name ProxyOverride -path $registryPath -ea SilentlyContinue).ProxyOverride
        $AutoConfigURLValue = (Get-ItemProperty -Name AutoConfigURL -path $registryPath -ea SilentlyContinue).AutoConfigURL
    
        $result = @"

$registryPath
ProxyEnable   : $ProxyEnableValue
ProxyServer   : $ProxyServerValue
ProxyOverride : $ProxyOverrideValue
AutoConfigURL : $AutoConfigURLValue

"@

        return $result
    }

    # initialize output
    $result = @"
Proxy param   : $Proxy
`n----- INITIAL STATE -----
"@
    $result += Get-ProxySettings

    #logic

    $result += "----- LOGIC -----`n"

    try {
        Set-itemproperty -Path $registryPath -name ProxyEnable -value 1
    }
    catch {
        $result += "*1: create ProxyEnable`n"
        New-ItemProperty  -Path $registryPath -name ProxyEnable -value 1 -PropertyType String -Force 
    }

    try {
        Set-ItemProperty -Path $registryPath -name "ProxyServer" -Value $Proxy
    }
    catch {
        $result += "*2: create ProxyServer`n"
        New-ItemProperty  -Path $registryPath -name "ProxyServer" -Value $Proxy -PropertyType String -Force 
    }

    try {
        Set-itemproperty -Path $registryPath -name ProxyOverride -value "<local>"
    }
    catch {
        $result += "*3: create ProxyOverride`n"
        New-ItemProperty -Path $registryPath -Name ProxyOverride -Value "<local>" -PropertyType String -Force 
    }

    try {
        Set-ItemProperty -Path $registryPath -name AutoConfigURL -value ""
    }
    catch {
        $result += "*4: create AutoConfigURL`n"
        New-ItemProperty -Path $registryPath -name AutoConfigURL -value "" -PropertyType String -Force 
    }            
                
    # Output
    $result += "`n----- END STATE -----"
    $result += Get-ProxySettings

#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message+$result)
}