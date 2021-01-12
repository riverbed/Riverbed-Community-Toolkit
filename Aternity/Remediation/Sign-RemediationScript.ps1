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

$cert=Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=$subject" }

if (!$cert) {
    Write-Error "Cannot find any certficate with the subject: $subject"
} elseif ($cert.GetType().Name -eq "Object[]") {
    Write-Error "Cannot choose which certificate to use. Multiple certs found with the same subject: $subject.`nPlease remove extra certs, keep only one cert and retry.`nYou can delete all certs using .\Clean-RemediationSigning.ps1"
} else {
    Get-Content $Source | Out-File -Encoding ascii -FilePath $Destination 
    Set-AuthenticodeSignature -Certificate $cert -FilePath $Destination
}