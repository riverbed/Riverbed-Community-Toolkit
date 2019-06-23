<#
.Synopsis
    Export Remediation Signing Certificate

.DESCRIPTION
	Export the "Aternity Remediation Code Signing" certificate into a file Aternity-Remediation-Certificate.cer

    This script can be run on the machine that has been prepared for remediation scripts signing. 
    It exports the certificate into a .cer file (to be deployed on test devices where remediations script will be executed)

.EXAMPLE
	.\Export-RemediationSigningCertificate.ps1
#>

param(
    $subject="Aternity Remediation Code Signing",
    $exportCertFilePath = "Aternity-Remediation-Certificate.cer"
)

Get-ChildItem Cert:\LocalMachine\Root | Where-Object { $_.Subject -eq "CN=$subject" } | Export-Certificate -FilePath  $exportCertFilePath