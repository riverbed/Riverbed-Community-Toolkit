<#
.Synopsis
   Aternity - Remediation Script: Restart-WindowsUpdateService
.DESCRIPTION
	Stop and start services related to Windows Update.
	Use case: fix update issue
	Tested on Windows 10
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Restart-WindowsUpdateService
   Description: Stop and start services related to Windows Update
   Run the script in the System account: checked
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

Stop-Service -Name BITS -Force
Stop-Service -Name wuauserv -Force -ErrorAction Stop
Stop-Service -Name appidsvc -Force
Stop-Service -Name cryptsvc -Force

Start-Service -Name cryptsvc
Start-Service -Name appidsvc
Start-Service -Name BITS 
Start-Service -Name wuauserv -ErrorAction Stop

$result = Get-Service BITS,wuauserv,appidsvc,cryptsvc | Out-String

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
