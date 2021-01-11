<#
.Synopsis
   Aternity - Remediation Script: Reinitialize-PrintSpooler
.DESCRIPTION
	Stop the print spooler service, delete the printing job in the queue, and restart spooler.
	Use case: Fix printing job issue
	Tested on Windows 10
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Reinitialize-PrintSpooler
   Description:  Reinitialize the print spooler service
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

Stop-Service -Name Spooler -Force  -ErrorAction Stop
Remove-Item -Path "$env:SystemRoot\System32\spool\PRINTERS\*.*" -Force
Start-Service -Name Spooler  -ErrorAction Stop
$result = Get-Service Spooler | Out-String

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
