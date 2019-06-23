<#
.Synopsis
    Sign Aternity Remediation Script

.DESCRIPTION
    Sign Aternity Remediation Scripts with existing code-signing certificate.

    This script must be run on the machine that has been prepared for remediation scripts signing.

.EXAMPLE 1
	New-Item -Type Directory Signed
   .\Sign.ps1 -Source .\Network/Remediation-DNS-ClearCache.ps1 -Destination .\Signed\Remediation-DNS-ClearCache-signed.ps1

.EXAMPLE 2
	New-Item -Type Directory Signed
   .\Sign.ps1 -Source .\Remediation-script.ps1 -Destination .\Signed\Remediation-script-signed.ps1
#>

param(
    $subject="Aternity Remediation Code Signing",
    $Source=".\Remediation-script.ps1",
    $Destination=".\Signed\Remediation-script-signed.ps1"
)

Get-Content $Source | Out-File -Encoding ascii -FilePath $Destination
$cert=Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=$subject" }
Set-AuthenticodeSignature -Certificate $cert -FilePath $Destination