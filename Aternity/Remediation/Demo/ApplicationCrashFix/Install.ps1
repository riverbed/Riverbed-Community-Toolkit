#requires -runasadministrator

<#
.Usage
    .\step1-Install.ps1
#>

#Install, default dir
$installDir = "C:\Program Files\FinApp2"
$tempDir = "$installDir\temp"
$glPath = "$installDir\temp\GeneralLedger.csv" 
New-Item -Path "$installDir\temp" -ItemType Directory
New-Item -Path "$installDir\temp\GeneralLedger.csv" -ItemType File
Copy-Item FinApp*.* -Destination $installDir

#Check
if (-not (Test-Path $installDir) -or -not (Test-Path "$installDir\temp\GeneralLedger.csv") -or -not (Test-Path "$installDir\FinApp2.exe")) {
    throw "FinApp2 is not installed correctly"
} else {
    Write-Output "FinApp2 looks correctly installed"
}