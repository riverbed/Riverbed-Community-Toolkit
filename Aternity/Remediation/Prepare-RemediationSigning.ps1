#Requires -RunAsAdministrator

<#

.Synopsis
    Prepare Certificate Code Signing to test Remediation scripts

.DESCRIPTION
    Create a self-signed certificate for code signing in the current user certificate store,
    add in the machine Root CA trust and export into a .cer file (to be deployed on test devices where remediations script will be executed)
    This script has to be run once on the machine and user session where remediation scripts will be signed.

.EXAMPLE
	.\Prepare-RemediationSigning.ps1
#>

param(
    $subject="Aternity Remediation Code Signing",
    $exportCertFilePath = "Aternity-Remediation-Certificate.cer"
)

$cert=New-SelfSignedCertificate -Subject $subject -Type CodeSigningCert -CertStoreLocation cert:\CurrentUser\My
Export-Certificate -Cert $cert -FilePath  $exportCertFilePath
$output = Import-Certificate -FilePath $exportCertFilePath -CertStoreLocation cert:\LocalMachine\Root