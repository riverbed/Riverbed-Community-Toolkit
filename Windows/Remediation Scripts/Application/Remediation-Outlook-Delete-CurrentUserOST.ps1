<#
.Synopsis
   Aternity - Remediation Script: Outlook-Delete-CurrentUserOST
.DESCRIPTION
	Delete the Outlook .ost file of the current user
    Use case: Fix synchronization issue in Outlook
	Tested on Windows 10 / Office 2016
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Outlook-Delete-CurrentUserOST
   Description: Delete .OST file
   Run the script in the System account: unchecked (must run in the current user context)
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

foreach ($process in (Get-Process -Name Outlook -ErrorAction SilentlyContinue)) {
 $process.CloseMainWindow()
 Start-Sleep -Seconds 5
}

if (Get-Process -Name Outlook -ErrorAction SilentlyContinue) { throw "Outlook still running" }

$OST_path = "$env:LOCALAPPDATA\Microsoft\Outlook"
if (! (Test-Path "$OST_path\*.ost")) { throw "Could not find any .ost in folder $OST_path" }

$result = "Deleting:`n"
Get-ChildItem "$OST_path\*.ost" | % {
    Remove-Item $_ -Force -ErrorAction Stop
    $result += "$($_.Name)`n"
} 

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
