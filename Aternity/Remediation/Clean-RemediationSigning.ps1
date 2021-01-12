#Requires -RunAsAdministrator

<#

.Synopsis
    Clean Certificate Code Signing to test Remediation scripts

.DESCRIPTION
    Remove certificates from the current user certificate store 
    and from the machine Root CA.

.EXAMPLE
	.\Clean-RemediationSigning.ps1
#>

param(
    $subject="Aternity Remediation Code Signing"
)

Get-ChildItem Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=$subject" } | Remove-Item
Get-ChildItem Cert:\LocalMachine\Root | Where-Object { $_.Subject -eq "CN=$subject" } | Remove-Item