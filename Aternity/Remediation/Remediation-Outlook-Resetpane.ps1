<#
.Synopsis
   Aternity - Remediation Script: Remediation-Outlook-Resetnavpane
.DESCRIPTION
	Removes all customizations to the navigation pane to fix "cannot start" issue
	
	Known error with Microsoft Outlook
	* https://support.office.com/en-ie/article/i-can-t-start-microsoft-outlook-or-receive-the-error-cannot-start-microsoft-office-outlook-cannot-open-the-outlook-window-d1f69da6-b333-4650-97bf-4d77bd7abb85
	* https://www.ibm.com/developerworks/community/groups/service/html/communitystart?communityUuid=ed951cf8-66d9-481a-a9dc-3454999d7758
	
	Aternity References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Reset Outlook pane
   Description: Removes all customizations to the navigation pane to fix "cannot start" issue
   
#>

#region Remediation action logic

	#If outlook is running do no thing
	$outlookIsRunning = Get-Process outlook -ErrorAction SilentlyContinue
	if ($outlookIsRunning) {
		$result="Failed. Outlook is running"
	} else {

    # Outlook resetnavpane following Microsoft knowledge base 
    Start-Process -FilePath "$env:ProgramFiles\Microsoft Office\root\Office16\OUTLOOK.EXE" -ArgumentList "/resetnavpane"
    $result="Run Outlook resetnavpane"
 
	}
 
#endregion

#region Aternity remediation status monitoring 
try
{
	# Set the path of the Agent on user device
	$env:STEELCENTRAL_ATERNITY_AGENT_HOME="C:\Program Files (x86)\Aternity Information Systems\Agent"

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
