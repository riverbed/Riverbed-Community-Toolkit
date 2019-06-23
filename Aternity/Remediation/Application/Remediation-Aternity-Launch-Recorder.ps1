<#
.Synopsis
   Aternity - Remediation Script: Aternity-LaunchRecorder
.DESCRIPTION
	Launch Aternity Recorder
 	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Aternity-LaunchRecorder
   Description: Launch Aternity Recorder
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

$recorderPath = "$env:STEELCENTRAL_ATERNITY_AGENT_HOME\..\Assistant\AternityRecorder.exe"

if (! (Test-Path -Path $recorderPath)) {
    throw "Could not find Aternity Recorder in $recorderPath"
}

Start-Process -FilePath "$recorderPath" 


	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
