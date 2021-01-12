#Requires -RunAsAdministrator

<#
.Synopsis
    Import the Remediation Signing certificate for Trust

.DESCRIPTION
	Trust the remediation self-signed certificate used for code signing importing into both TrustedPublisher and Root CA certificate store

.EXAMPLE
	Import-RemediationSigningCertificate.ps1
#>

param(
    $certFilePath = "Aternity-Remediation-Certificate.cer"
)

Import-Certificate -FilePath $certFilePath -CertStoreLocation Cert:\LocalMachine\Root
Import-Certificate -FilePath $certFilePath -CertStoreLocation Cert:\LocalMachine\TrustedPublisher