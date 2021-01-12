<#
.Synopsis
   Aternity - Remediation Script: Disable-SHMobileOptimization
.DESCRIPTION
	Disable optimization on the SteelHead mobile agent
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Disable-SHMobileOptimization
   Description: Disable optimization on the SteelHead mobile agent
   Run the script in the System account: checked
   Requires confirmation: No
#>

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	
	#region Remediation action logic

		# Add your remediation code here and set the variable $result with the Output Message to be visible visible in Aternity's dashboards.
		#
		# For example:
		# 	Clear-DnsClientCache
		# 	$result="DNS Cache Cleared"

Get-Command rbtdebug.exe -ErrorAction Stop

#Default install path is "C:\Program Files (x86)\Riverbed\Steelhead Mobile\"

rbtdebug.exe --optimize disable

Start-Sleep -Seconds 3

$result = rbtdebug.exe --status-all

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}