<#
.Synopsis
   Aternity - Remediation Script: Fix FinApp2
.DESCRIPTION
	Patch FinApp2 problem on General Ledger. Fix temp folder permissions
 	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Fix-FinApp2
   Description: FinApp2, fix the General Ledger problem
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

$installDir = "C:\Program Files\FinApp2"
$tempDir = "$installDir\temp"
$glPath = "$installDir\temp\GeneralLedger.csv" 

$acl = Get-Acl $tempDir
$permissions = "BUILTIN\Users", "FullControl", "Containerinherit, ObjectInherit", "None", "Allow"
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permissions
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path $tempDir

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}