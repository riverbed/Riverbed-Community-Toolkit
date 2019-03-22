<#
.Synopsis
   Aternity - Remediation Script: Remediation-Repair-Volumes-offline
.DESCRIPTION
	If possible perform an offline scan and fix of volumes, or schedule at next reboot (ex. system disk).
		
	Aternity References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Repair Volumes offline
   Description: Perform an offline scan and fix of volumes or schedule at next reboot
   Run the script in the System account: checked
   
#>

#region Remediation action logic

$all_repairStatus=@()
Get-Volume | % { 
	$driveLetter=$_.DriveLetter
	if ($driveLetter) {
		$repairStatus=(Repair-Volume $driveLetter -OfflineScanAndFix)
		$all_repairStatus += "$driveLetter $repairStatus"		
	}
}
$result = $all_repairStatus -join ";"
 
#endregion

#region Aternity remediation status monitoring 
try
{
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
