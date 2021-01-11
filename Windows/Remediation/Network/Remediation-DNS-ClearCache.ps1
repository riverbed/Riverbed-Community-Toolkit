<#
.Synopsis
   Aternity - Remediation Script: Remediation-DNS-ClearCache
.DESCRIPTION
	Clear the device DNS Cache
	
	Aternity References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: DNS Clear Cache
   Description: Clear the device DNS Cache
   
#>

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    
#region Remediation action logic

Clear-DnsClientCache
$result="DNS Cache Cleared"
 
#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
