<#
.Synopsis
   Aternity - Remediation Script: Clear-BrowsingData-Cache-Downloads
.DESCRIPTION
	Clear downloads, windows caches, and cache folder of browsers Google, Firefox and Internet Explorer
    Use case: Fix browsing cache issue
	Tested on Windows 10
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Clear-BrowsingData-Cache-Downloads
   Description: Clear caches and temp folders for browsers Google, Firefox and Internet Explorer
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

"Clear Internet Explorer"
RunDll32.exe InetCpl.cpl,ClearMyTracksByProcess 255

"Clear Temporary Internet Files"
$TIF_path = "$env:LOCALAPPDATA\Microsoft\Windows\Temporary Internet Files"
if (Test-Path $TIF_path)
{
	Remove-Item $TIF_path\* -Force -Recurse
    $result += "Cleared $TIF_path"
}

"Clear Firefox profiles"
$FF_Path = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles"
if (Test-Path $FF_Path)
{
	Remove-Item $FF_Path\* -Force -Recurse
    $result += "Cleared $FF_Path"
}

"Clear Chrome user data"
$Chrome_Path = "$env:LOCALAPPDATA\Google\Chrome\User Data"
if (Test-Path $Chrome_Path)
{
	Remove-Item $Chrome_Path\* -Force -Recurse
    $result += "Cleared $Chrome_Path"
}

"Clear Windows caches"
$Cache_path = "$env:LOCALAPPDATA\Microsoft\Windows\Caches"
if (Test-Path $Cache_path)
{
	Remove-Item $Cache_path\* -Force -Recurse
    $result += "Cleared $Cache_path"
}

"Clear Download folder"
$DL_path = "$env:USERPROFILE\Downloads"
if (Test-Path $DL_path)
{
	Remove-Item $DL_path\* -Force -Recurse
    $result += "Cleared $DL_path"
}

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
