<#
.Synopsis
   Aternity - Remediation Script: Remediation-CollectDriversList-UserSendsResultsViaEmailOutlook

.DESCRIPTION

	Collect the list of drivers installed on the machine and prepare an email in Outlook to send the results.
    The user will have to press “send” in Outlook.

    This remediation accepts a parameter to override the recipient email address. The default can be customized in this script ("it-servicedesk@yourcompany.com")
    
    Aternity Agent requirement: 12.0.1.128 or later

    Tested on Windows 10 / Office 16
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation
    * https://support.office.com/en-us/article/Command-line-switches-for-Microsoft-Office-products-079164CD-4EF5-4178-B235-441737DEB3A6

.EXAMPLE
    Deploy in Aternity (Configuration > Remediation > Add Action) 
    Action Name: Collect drivers and User sends results via Outlook
    Description: When the message is ready in Outlook, the user must hit "Send"
    Action Expiration: 1
    Script Privileges: unchecked (run in User context)
    Allow input parameter: on
        Parameter name: recipient
        Mandatory: false
        Description: Recipient of the email to be send via Outlook
        Sample: it-servicedesk@yourcompany.com
    Message From: IT Service Desk
    Header: We need to collect information about your PC (drivers)
    Question: When the message pops up in Outlook, please hit the send button.
#>

# Default value for the recipient. Can be customized.
$defaultRecipient = "it-servicedesk@yourcompany.com"

# Path to OUTLOOK.EXE on the endpoint. Can be set, for example: $outlookPath = "C:\Program Files\Microsoft Office\root\Office16\outlook.exe"
# If not set the script will try to find the path in some Outlook standard registry keys
$outlookPath = ""

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

# Detect Outlook path in Outlook standard registry path
if (!$outlookPath) {
    # retrieve something like: "C:\Program Files\Microsoft Office\root\Office16\"
    $outlookPath = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Office\16.0\Outlook\InstallRoot -ErrorAction SilentlyContinue).Path
    $outlookPath += "outlook.exe"
}
if (!$outlookPath) {
    Throw "Could not find path to OUTLOOK.EXE"
} elseif (! (Test-Path -Path $outlookPath -ErrorAction SilentlyContinue)) {
    Throw "Path to OUTLOOK.EXE is incorrect: $outlookPath"
}

#variables
$devicename=$env:computername
$user=([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)
$subject="Aternity - Remediation - $resultFilenamePrefix - Device=$devicename / user=$user"
$attachment_path = "$env:USERPROFILE\Aternity-remediation-$resultFilenamePrefix-$(Get-Date -Format 'yyyyMMddHHMMss').csv" 

#collect, prepare results attachment and message body
$wmiResults = Get-WmiObject -Class Win32_PnPSignedDriver -Namespace root\cimv2 | Select-Object friendlyname, driverversion, manufacturer,deviceid,devicename,signer 
$wmiResults | Export-Csv -Force -Path $attachment_path -NoTypeInformation
$result="WMI PnP Signed Drivers attached.`nDrivers Count: $($wmiResults.Count)"

# Prepare email in Outlook
Start-Process -FilePath "$outlookPath" -ArgumentList "/a $attachment_path /c ipm.note /m `"$recipient&subject=$subject&body=$result`""  -WindowStyle Hidden
	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}