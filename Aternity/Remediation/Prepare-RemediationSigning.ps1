<#
.Synopsis
   Prepare Remediation Signing
.DESCRIPTION
	Create a self-signed certificate for code signing "Aternity Remediation Code Signing" and export as .cer
.EXAMPLE 1
	Prepare-RemediationSigning.ps1
#>

$cert=New-SelfSignedCertificate -Subject "Aternity Remediation Code Signing" -Type CodeSigningCert -CertStoreLocation cert:\CurrentUser\My
Export-Certificate -Cert $cert -FilePath  .\Aternity-Remediation-Certificate.cer
Move-Item -Path $cert.PSPath -Destination "Cert:\CurrentUser\Root"