<#
.Synopsis
   Aternity - Remediation Script: SCCM-Run-MachinePolicyRetrieval
.DESCRIPTION
	Perform a Machine Policy Retrieval & Evaluaton Cycle on the SCCM Agent (Request and Evaluate MachinePolicy)
	
	Use case: Need to immediately trigger a deployment recently assigned to a device
	Tested on Windows 10 / ccm agent version 5.0
	
	References:
	* https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/client-classes/requestmachinepolicy-method-in-class-sms_client
	* https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/client-classes/evaluatemachinepolicy-method-in-class-sms_client
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: SCCM Machine Policy Retrieval
   Description: Perform a Machine Policy Retrieval & Evaluaton Cycle to immediately trigger software deployment
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

$ReturnValue = (Invoke-WMIMethod –Namespace root\ccm –Class SMS_Client –Name RequestMachinePolicy -ErrorAction Stop).ReturnValue
if ($ReturnValue -ne $null) { throw "RequestMachinePolicy Error: $ReturnValue"}
$result += "RequestMachinePolicy : done`n"

$ReturnValue = (Invoke-WMIMethod –Namespace root\ccm –Class SMS_Client –Name EvaluateMachinePolicy -ErrorAction Stop).ReturnValue
if ($ReturnValue -ne $null) { throw "EvaluateMachinePolicy Error: $ReturnValue"}
$result += "EvaluateMachinePolicy : done`n"

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
