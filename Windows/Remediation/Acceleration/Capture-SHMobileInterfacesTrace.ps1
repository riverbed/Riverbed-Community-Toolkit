<#
.Synopsis
   Aternity - Remediation Script: Capture-SHMobileInterfacesTrace
.DESCRIPTION
	Launch a network capture on the SteelHead Mobile agent 
 	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Capture-SHMobileInterfacesTrace
   Description: Launch a network capture on the SteelHead Mobile agent 
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

# Parameters
$duration = "120s"

# Check if rbtdebug is installed. Default install path is "C:\Program Files (x86)\Riverbed\Steelhead Mobile\"
Get-Command rbtdebug.exe -ErrorAction Stop

if (Get-Process rbtdebug -ErrorAction SilentlyContinue) { 
    throw "Cannot start if rbtdebug is already running." 
}

#preparation
$timestamp = $(Get-Date -Format "yyMMddHHmmss")
$traceFileName = "Trace-$timestamp"

# Capture trace
rbtdebug.exe --trace-all $duration $traceFileName

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
