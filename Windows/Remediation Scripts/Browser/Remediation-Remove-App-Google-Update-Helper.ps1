<#
.Synopsis
   Aternity - Remediation Script: Remove-App-Google-Update-Helper
.DESCRIPTION
	Uninstall the software using MSI
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Remove-App-Google-Update-Helper
   Description: Uninstall the application Google-Update-Helper using MSI
#>

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll

#region Remediation action logic

	# Set the name of the app to remove, for example:
	# $app_name = "Google"
    $app_name = "Google"

    get-wmiobject Win32_Product | where-object { $_.Name -like "*$($app_name)*" } | % { 
        "Uninstalling App: $($_.Name)"
        Write-Output $_.IdentifyingNumber
	    msiexec /x "$($_.IdentifyingNumber)" /qn 
    }

#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
