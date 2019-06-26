<#
.Synopsis
   Aternity - Remediation Script: SCCM-Run-MachinePolicyRetrieval
.DESCRIPTION
	Perform a Machine Policy Retrieval & Evaluaton Cycle on the SCCM Agent (Request and Evaluate MachinePolicy)
	Using the generic TriggerSchedule method
	
	Use case: Need to immediately trigger a deployment recently assigned to a device
	Tested on Windows 10 / ccm agent version 5.0
	
	References:
	* https://docs.microsoft.com/en-us/sccm/develop/reference/core/clients/client-classes/triggerschedule-method-in-class-sms_client
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: SCCM Machine Policy Retrieval - generic
   Description: Perform a Machine Policy Retrieval & Evaluaton Cycle to immediately trigger software deployment. Use TriggerSchedule.
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

function TriggerSchedule() {
	param(
	$actionName = "Machine Policy Assignments Request" ,
	$scheduleId = "{00000000-0000-0000-0000-000000000021}"
	)
	$ReturnValue = (Invoke-WmiMethod -Namespace "Root\CCM" -Class SMS_Client -Name TriggerSchedule -ArgumentList $scheduleId -ErrorAction Stop).ReturnValue
	if ($ReturnValue -eq $null) { 
		$result = "$actionName : done`n" 
	} else { 
		throw "$actionName : Error $ReturnValue"
	}
	return $result
}

$result += TriggerSchedule -actionName "Machine Policy Assignments Request" -scheduleId "{00000000-0000-0000-0000-000000000021}"
$result += TriggerSchedule -actionName "Machine_Policy_Evaluation" -scheduleId "{00000000-0000-0000-0000-000000000022}"

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
