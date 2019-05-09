<#
.Synopsis
   Sign Aternity Remediation Script
.DESCRIPTION

.EXAMPLE 1
	New-Item -Type Directory Signed
   ./Sign.ps1 -Source ./Network/Remediation-DNS-ClearCache.ps1 -Destination ./Signed/Remediation-DNS-ClearCache-signed.ps1
.EXAMPLE 2
	New-Item -Type Directory Signed
   ./Sign.ps1 -Source ./Remediation-script.ps1 -Destination ./Signed/Remediation-script-signed.ps1
#>

param(
    $Source="Remediation-script.ps1",
    $Destination="Remediation-script-signed.ps1"
)

Get-Content $Source | Out-File -Encoding ascii -FilePath $Destination
$cert=Get-ChildItem Cert:\CurrentUser\Root | Where-Object { $_.Subject -eq "CN=Aternity Remediation Code Signing" }
Set-AuthenticodeSignature -Certificate $cert -FilePath $Destination