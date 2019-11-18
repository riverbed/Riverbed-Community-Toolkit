<#
.Synopsis
   Aternity - Remediation Script: Remediation-Disable-SMB1
.DESCRIPTION
	This script will Disable SMB1
    
    Tested on Windows 7 and 10
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Disable SMB1
   Description: Disable SMB1
   Run the script in the System account: checked
#>

Try 
{
# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    #region Remediation action logic
    [string]$OperatingSystemVersion = (Get-WmiObject -Class Win32_OperatingSystem).Version    
    switch -Regex ($OperatingSystemVersion) {
        '(^10\.0.*|^6\.3.*)' 
            {
                # Windows 8.1 / Server 2012 R2 / Windows 10 / Server 2016

                if (((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State) -match 'Enable(d|Pending)') {
                    Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

                    $result += "Disabled SMB1 Win 10"
                }
            }
        '^6\.2.*' 
            {
                # SMB1 Client Settings
                if ((sc.exe qc lanmanworkstation) -match 'MRxSmb10') {
                    Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config lanmanworkstation depend= bowser/mrxsmb20/nsi' -WindowStyle Hidden
                    Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config mrxsmb10 start= disabled' -WindowStyle Hidden
                }
            }
        '^6\.(0|1).*'
            {
                # Windows Vista / Server 2008 / Windows 7 / Server 2008R2
                
                # SMB1 Client Settings
                if ((sc.exe qc lanmanworkstation) -match 'MRxSmb10') {
                    Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config lanmanworkstation depend= bowser/mrxsmb20/nsi' -WindowStyle Hidden
                    Start-Process -FilePath "$env:windir\System32\sc.exe" -ArgumentList 'config mrxsmb10 start= disabled' -WindowStyle Hidden
                     $result += "Disabled SMB1 Win 7"
                }
            }
            }

    # Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)

} Catch {
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}