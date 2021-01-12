<#
.Synopsis
   Aternity - Remediation Script: Rebuild-PerfCounters
.DESCRIPTION
	Backup, Rebuild Performance counters and resync with WMI.
	Use case: fix corrupted Performance counters
	Tested on Windows 10
	
	References:
	* https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/lodctr
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Rebuild-PerfCounters
   Description: Rebuild Performance counters to fix a corruption
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

# Save backup of perf counters repository under the folder %ProgramData%\lodctr.bak, ex. C:\ProgramData\lodctr.bak\backup-190616144544.txt
$backupDir = "$env:ProgramData\lodctr.bak"
if (! (Test-Path $backupDir)) { New-Item -ItemType Directory $backupDir }
if (! (Test-Path $backupDir)) { throw "$backupDir directory is missing" }
$timestamp = $(Get-Date -Format "yyMMddHHmmss")
$backupPath = "$backupDir\backup-$timestamp.txt"
lodctr /s:"$backupPath"
if (! (Test-Path $backupPath)) { throw "Failed to backup Perf Counters into $backupPath" }

# Rebuild the Perf Counters and register with WMI
Set-Location $env:SystemRoot\system32
lodctr /R
Set-Location $env:SystemRoot\SysWOW64
lodctr /R
if ($LastExitCode -ne 0) { throw "Failed to restore performance counters settings" }
$result = WINMGMT.EXE /RESYNCPERF
if ($LastExitCode -ne 0) { throw "Resync performance counters with WMI failed" }
# WINMGMT.EXE /verifyrepository
	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
