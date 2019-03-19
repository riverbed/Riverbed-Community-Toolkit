<#
.Synopsis
   Aternity - Remediation Script: Remove-App-appname
.DESCRIPTION
	Uninstall the software using MSI
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Remove-App-{{app name}}
   Description: Uninstall the application {{app name}} using MSI
#>

#region Remediation action logic

	# Set the name of the app to remove, for example:
	# $app_name = "Firefox"
    $app_name = "{{app name}}"

    get-wmiobject Win32_Product | where-object { $_.Name -like "*$($app_name)*" } | % { 
        "Uninstalling App: $($_.Name)"
        Write-Output $_.IdentifyingNumber
	    msiexec /x "$($_.IdentifyingNumber)" /qn 
    }

#endregion

#region Aternity remediation status monitoring 
try
{
	# Set the path of the Agent on user device
	$env:STEELCENTRAL_ATERNITY_AGENT_HOME="C:\Program Files (x86)\Aternity Information Systems\Agent"

	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	
	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
#endregion
