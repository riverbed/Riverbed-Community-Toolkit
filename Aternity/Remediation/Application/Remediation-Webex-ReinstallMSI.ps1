<#
.Synopsis
   Aternity - Remediation Script: Remediation-Webex-ReinstallMSI
.DESCRIPTION
	Clean any Webex installation (User Profile install or msi) and reinstall the msi.
    The script must be configured setting 2 variables in the Customization code region:
    - $installersLibrayUNC: Path containing webexapp.msi and CiscoWebexRemoveTool.exe. Examples: 'C:\ProgramData\IT-ServiceDesk-Installers\', '\\sharedrive\Installers'
    - $siteurl: Default site url for Webex. Example '"riverbed.webex.com"
	 	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation
    * https://help.webex.com/en-us/WBX21799/Are-Admin-Rights-Required-to-Install-the-Webex-Meeting-Manager-Software
	* https://help.webex.com/en-us/WBX000026378/Meeting-Services-Removal-Tool

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Webex Reinstall MSI
   Description: Resolve Webex crash issues, cleaning Webex and installing the msi
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

#region Customization

$installersLibraryUNC = 'C:\ProgramData\your-path-to-Installers\'
$siteurl = "your-webex-url.webex.com"

#endregion

#region Installers path

$msifile = 'webexapp.msi'
$removalfile = 'CiscoWebexRemoveTool.exe'
$msipath = $installersLibraryUNC + $msifile
$removalpath = $installersLibraryUNC + $removalfile

if (! (Test-Path $msipath)) { throw "Cannot find installers in $msipath" }
if (! (Test-Path $removalpath)) { throw "Cannot find installers in $removalpath" }

#endregion

#region WebEx specific

function Test-WebexMSIInstallationPresence() {
    $out = New-PSDrive -PSProvider Registry -Name HKEY_USERS -Root HKEY_USERS
    $webexDefaultUserRegkey = "HKEY_USERS:\.DEFAULT\Software\WebEx\ProdTools"
    return Test-Path $webexDefaultUserRegkey
}

function Test-WebexUserProfileInstallationPresence() {
    $webexDefaultProfileSubfolder = "\AppData\Local\WebEx"
    $WebexUserProfileInstallationDetection = $false
    Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | ForEach-Object { 
        $profilePath = $_.GetValue('ProfileImagePath') 
        if (Test-Path "$profilePath$webexDefaultProfileSubfolder" ) {
            $WebexUserProfileInstallationDetection = $true
        }
    }
    return $WebexUserProfileInstallationDetection
}

#endregion

#region Cleanup and install Logic

# Prepare msiexec parameters
$installargs = -join('/i ', $msipath, ' /qn SITEURL=', $siteurl)
$uninstallargs = -join('/x ', $msipath, ' /qn')

# Clean any msi installation
if(Test-WebexMSIInstallationPresence) { 
    "Uninstalling Webex MSI"
    Start-Process msiexec.exe -Wait -ArgumentList $uninstallargs
}
if(Test-WebexMSIInstallationPresence) { throw "Webex MSI is still present while it should have been uninstalled" }

#Clean any "automatic installer" installation 
if(Test-WebexUserProfileInstallationPresence) { 
    "Removing any Webex User Profiler installation"
    Start-Process $removalpath -WindowStyle Hidden -Wait
}
if(Test-WebexUserProfileInstallationPresence) { throw "Webex User Profile installation is still present while it should have been uninstalled" }

#Install Webex MSI
"Installing Webex MSI"
Start-Process msiexec.exe -Wait -ArgumentList $installargs 

#Perform post installation validation
if(!(Test-WebexMSIInstallationPresence)) { throw "Post install check failed: Could not find MSI installation trace" }

$result = "Webex (msi) has been resinstalled with site url $siteurl"

#endregion

   [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
