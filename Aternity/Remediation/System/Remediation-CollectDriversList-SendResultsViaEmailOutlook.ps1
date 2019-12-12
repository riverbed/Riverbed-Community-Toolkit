<#
.Synopsis
   Aternity - Remediation Script: Remediation-CollectDriversList-SendResultsViaEmailOutlook

.DESCRIPTION

	Collect the list of drivers installed on the machine and send the results via Outlook.

    This remediation accepts a parameter to override the recipient email address. The default can be customized in this script ("it-servicedesk@yourcompany.com")
    
    Aternity Agent requirement: 12.0.1.128 or later
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation
    * https://support.office.com/en-us/article/Command-line-switches-for-Microsoft-Office-products-079164CD-4EF5-4178-B235-441737DEB3A6


.EXAMPLE
    Deploy in Aternity (Configuration > Remediation > Add Action) 
    Action Name: Collect drivers and send results via Outlook
    Description: Collect WMI PnP Signed Drivers and send with the user Outlook account
    Action Expiration: 1
    Script Privileges: unchecked (run in User context)
    Allow input parameter: on
        Parameter name: recipient
        Mandatory: false
        Description: Override the default recipient of the email to be send via Outlook
        Sample: it-servicedesk@yourcompany.com
    Message From: IT Service Desk
    Header: We need to collect information about your PC (drivers)
    Question: It will take 15 seconds to collect and send the results via Outlook
#>

# Default value for the recipient. Can be customized.
$defaultRecipient = "it-servicedesk@yourcompany.com"

# Prefix for the filename that stores results (string with alphanumerics and "-" characters)
$resultFilenamePrefix = "CollectDriversList"

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

# Extract remediation parameter
if ($args[0]) {
    $recipient=$args[0] 
} else {
  $recipient=$defaultRecipient 
}

$devicename=$env:computername
$user=([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
$subject="Aternity - Remediation - $resultFilenamePrefix - Device=$devicename / user=$user"
$attachment_path = "$env:USERPROFILE\Aternity-remediation-$resultFilenamePrefix-$(Get-Date -Format 'yyyyMMddHHMMss').csv" 

#collect, prepare results attachment and message body
$wmiResults = Get-WmiObject -Class Win32_PnPSignedDriver -Namespace root\cimv2 | Select-Object friendlyname, driverversion, manufacturer,deviceid,devicename,signer 
$wmiResults | Export-Csv -Force -Path $attachment_path -NoTypeInformation
$result="WMI PnP Signed Drivers attached. Drivers Count: $($wmiResults.Count)"

#email preparation
$cmd = "`$outlook= New-Object -comObject Outlook.Application ; `$message= `$outlook.CreateItem(0) ; `$message.Subject = `"$subject`" ; `$message.Body = `"$result`" ; `$message.Recipients.Add(`"$recipient`") ; `$message.Attachments.Add(`"$attachment_path`") ; `$message.Send()"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($cmd)
$encodedCommand = [Convert]::ToBase64String($bytes)
Start-Process -FilePath powershell  -ArgumentList "-encodedCommand $encodedCommand" -WindowStyle Hidden

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}