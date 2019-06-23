<#
.Synopsis
   Aternity - Remediation Script: Aternity-Record-UserInteraction
.DESCRIPTION
	Record user interaction on the screen to troubleshoot an application and understand the interactions of the user
    Store capture
 	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Record-UserInteraction
   Description: Record user interaction on the screen to troubleshoot an application
   Run the script in the System account: checked
   End-User confirmation message: ON
   Message from: IT Service Desk - Troubleshooting
   Header: Investigation on application problem
   Message: Please click OK to start recording and redo the operation having problem in your application (crash slowness, etc.). The screen interaction will be recorded for 2 min.
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

# Parameters
$duration = "2:00"

# Preparation

if (Get-Process ffmpeg -ErrorAction SilentlyContinue) { 
    throw "Cannot start if ffmpeg is already running." 
}

if (! $env:STEELCENTRAL_ATERNITY_AGENT_HOME) {
    throw "Environment variable missing for Aternity Agent Path: STEELCENTRAL_ATERNITY_AGENT_HOME"
}

$ffmpegPath = "$env:STEELCENTRAL_ATERNITY_AGENT_HOME\..\Assistant\ffmpeg\ffmpeg.exe"

if (! (Test-Path -Path $ffmpegPath)) {
    throw "ffmpeg could not be found in $ffmpegPath"
}

$capturesFolderPath = "$env:ProgramData\Aternity\Recordings"
if (! (Test-Path $capturesFolderPath)) { New-Item -ItemType Directory $capturesFolderPath }
if (! (Test-Path -Path $capturesFolderPath)) {
    throw "Aternity Capture folder path could not be found in $capturesFolderPath"
}

$timestamp = $(Get-Date -Format "yyMMddHHmmss")
$captureName = "Capture-$timestamp.mkv"
$capturePath = "$capturesFolderPath\$captureName"
$primary_screen = "{0}x{1}" -f [System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Width,[System.Windows.Forms.SystemInformation]::PrimaryMonitorSize.Height

# Output
Write-Output "Aternity Agent Path: $env:STEELCENTRAL_ATERNITY_AGENT_HOME"
Write-Output "ffmpeg Path: $ffmpegPath"
Write-Output "Aternity Capture Path: $capturesFolderPath"
Write-Output "Recording: $capturePath"

# Launch
Start-Process -FilePath $ffmpegPath  -WorkingDirectory $capturesFolderPath -ArgumentList "-t $duration -y -f gdigrab -framerate 10 -video_size $primary_screen -i desktop -loglevel warning -an -vcodec libx264 -preset ultrafast -tune zerolatency -s $primary_screen -vsync passthrough -copytb 1 -pix_fmt yuv420p $capturePath " `
-WindowStyle Hidden -Wait

if (! (Test-Path -Path $capturePath)) {
    throw "$capturePath could not be found"
}

$result = "Recorded: $capturePath"

	#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}
