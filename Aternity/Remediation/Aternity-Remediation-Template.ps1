<#
.Synopsis
   Aternity - Remediation Script: {{Action Name}}
.DESCRIPTION
	{{Remediation Description}}
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: {{action}}
   Description: {{description}}   
#>

#region Remediation action logic

	# Add your remediation code here and set the variable $result with the Output Message to be visible visible in Aternity's dashboards.
	#
	# For example:
	# 	Clear-DnsClientCache
	# 	$result="DNS Cache Cleared"

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
