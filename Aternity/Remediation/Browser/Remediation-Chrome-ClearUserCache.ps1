<#
.Synopsis
   Aternity - Remediation Script: Remediation-Chrome-ClearUserCache
.DESCRIPTION
	Clear Chrome user default cache folder. Try to delete files from the cache folder and if any deletion fails then try to close Chrome and retry to delete file in the cache folder.
    Use case: Fix browsing cache issue
	Tested on Windows 10, Chrome 77
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Chrome Clear UserCache
   Description: Clear Chrome user default cache folder
   Run the script in the System account: unchecked (must run in the current user context)
   Message From: IT Service Desk
   Header: Chrome browser needs cleanup (clear cache)
   Question: Please close all Chrome windows and click OK when ready to proceed
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

        # variables
        $Chrome_Cache_Path = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache"

        #Initialize output
        $result = "`n----- INITIAL STATE -----`nUser default cache folder: $Chrome_Cache_Path `n"

        $UserCacheFolderExists = (Test-Path $Chrome_Cache_Path)
        $IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $Chrome_Cache_Path -ErrorAction SilentlyContinue))
       
        if ( $IsCacheEmpty ) {
            $result += "Cache is empty, nothing to do"
        } else {           

            try {

                $result += "Trying to delete files in the cache`n"
                Remove-Item $Chrome_Cache_Path\* -Force -Recurse -ErrorAction Stop

            } catch {

                $IsChromeRunning = (Get-Process -Name Chrome -ErrorAction SilentlyContinue)
                if ($IsChromeRunning) { 
                    $result += "Chrome is running. Trying to stop gracefully`n"
                    Get-Process Chrome -ErrorAction SilentlyContinue | % { if ($_.CloseMainWindow()) { Start-Sleep -Seconds 1 }}
                 }

                $IsChromeRunning = (Get-Process -Name Chrome -ErrorAction SilentlyContinue)
                if ($IsChromeRunning) { 
                    $result += "Chrome is still running. Stopping remaining instances`n"
                    Get-Process -Name Chrome -ErrorAction SilentlyContinue | Kill -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Seconds 1 
                }

                $result += "Deleting remaining files in the cache`n"
                Remove-Item $Chrome_Cache_Path\* -Force -Recurse -ErrorAction SilentlyContinue

            }

            #check
            $IsCacheEmpty = $UserCacheFolderExists -and (! (Get-ChildItem $Chrome_Cache_Path -ErrorAction SilentlyContinue))
            if (!$IsCacheEmpty) { throw "Could not empty cache`n"+$result }
            
            #output
            $result += "`n----- END STATE -----`nUser default cache folder: $Chrome_Cache_Path `nCache is empty"            
        }

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
