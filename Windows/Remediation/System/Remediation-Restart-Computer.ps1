<#
.Synopsis
   Aternity - Remediation Script: Restart-Computer
.DESCRIPTION
	Restart computer
    Use case: The computer needs reboot to refresh resources
	Tested on Windows 10
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Restart-Computer
   Description: Reboot the computer
   Run the script in the System account: checked
#>

# Parameters
$timeout = 60
$comment = "Triggerbed by IT Service Desk - Aternity Remediation"

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

# Major:Minor : Other (Planned)
shutdown /r /t $timeout /d p:0:0 /c $comment 

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
