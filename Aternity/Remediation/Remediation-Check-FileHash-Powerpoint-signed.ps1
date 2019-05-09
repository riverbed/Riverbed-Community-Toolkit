<#
.Synopsis
   Aternity - Remediation Script: Check-Filehash-Powerpoint
.DESCRIPTION
	Check the MD5 file hash of powerpoint
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: Check-Filehash-Powerpoint
   Description: Check the MD5 file hash of powerpoint
#>

try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
	
#region Remediation action logic

	#Set the path of the binary to check
	$app_executable_path = "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE" 
	try{
		$result = (Get-FileHash -Path $app_executable_path  -Algorithm  MD5).Hash
	}
	catch {
		$result = "Exception"
		
	}

#endregion

	# Set Output message
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetScriptOutput($result)
}
catch
{
    [ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed($_.Exception.Message)
}

# SIG # Begin signature block
# MIIFowYJKoZIhvcNAQcCoIIFlDCCBZACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvzLMT0qNQv40sObqQV+ThbZv
# OsKgggMsMIIDKDCCAhCgAwIBAgIQE1y6sqDxc4JKzV2mvo96OTANBgkqhkiG9w0B
# AQsFADAsMSowKAYDVQQDDCFBdGVybml0eSBSZW1lZGlhdGlvbiBDb2RlIFNpZ25p
# bmcwHhcNMTkwNTA3MTMxMTU2WhcNMjAwNTA3MTMzMTU2WjAsMSowKAYDVQQDDCFB
# dGVybml0eSBSZW1lZGlhdGlvbiBDb2RlIFNpZ25pbmcwggEiMA0GCSqGSIb3DQEB
# AQUAA4IBDwAwggEKAoIBAQC41uzqnZVt6sU3+DUYExEBCDqGudN6mCuF+DQmmK2E
# eGMD9yzeBwmteJyg3TyimC0ZtwJGjlUnjMutReO8eUIlrP7fxT2brB0pgMaBC5b/
# tURh4aZWfFq7jlfP7S+Tc9bobIr1g5X6yd6Qf0wOT5pjt5ZAzBcb3rarMVeXDKf6
# jZ7CsbBmn/mQ1Sa7nnGoTZmdg8J14WfvBhlifmThmuH4mjHydHFPjERBSeoKdbWe
# dseuSjZK9cYFsM+InPg5ElzPFnuU8x2gXbifWIIIw3GQ8/SV1CDEnGgwzWmOxU/S
# iP0en/Tn5pLTwQFuX5vwszo+b5PsX/rSMZ153jP/M4rhAgMBAAGjRjBEMA4GA1Ud
# DwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQU0DSGmyjD
# vAkAzYrCxJPMkKv2FUAwDQYJKoZIhvcNAQELBQADggEBAALgRFHOxNb59zaOid4E
# +JXlxqjH9TtoVpLunHl54LO++No++dQJMViYIW0o0I3zrp2a6qR+JIVQRcs/aQYh
# uA7OiFHCPwh5bGdxFcTV/pOkQI+Ssi+cS/eCqynkjo7eKRslA+ydaA8HnsP7kHJ5
# p1mSh+SuyVwUq9uU1ETMQwEUv0xiOzzBvaCU8hLaDmNPv1fnNg9xvwxoge3USya9
# Uh4mwXWqR7oTW2m8gBwjVPe/hBDP4zuC75CnIqiM6ngeDhR5jTva3Q0JVumjvQ/3
# xhjy0KIqIa1HiCMnQ4CwMezg7ydLRGtQe+po2uxFmTflCKbIPLqtvx0Ob+fqaQ4c
# ZmUxggHhMIIB3QIBATBAMCwxKjAoBgNVBAMMIUF0ZXJuaXR5IFJlbWVkaWF0aW9u
# IENvZGUgU2lnbmluZwIQE1y6sqDxc4JKzV2mvo96OTAJBgUrDgMCGgUAoHgwGAYK
# KwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIB
# BDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU
# E98PGW5/m2upYUttX/B9kvrr1WIwDQYJKoZIhvcNAQEBBQAEggEAtk8IkfPBvLPW
# uXRBjMtXluYQvfrkiRSGJT9nlkM/jHc/PVX9b05/5DPpx3v7gtn3ZywNgMKBDOAn
# hayrVZZ5xTd6ADqcpu0qOe4vFRjPM4scx6RF9iOrxMWIYIgfr4YjGleRxiJ3zdpd
# Q+v4YcP1hMAvQcPz4ZctHNCwAb7ASS7qdS9uEMYb1+RNZUBYBxLGfZmWy2YCeIad
# 1CimATyZ2KTr47yY2ZuS209v1Uj0UnHse6JD+SaA2BECiZ0dPmOt7Kdyfa87Ibkz
# J9WZd7dBQ02K7L2LyNIVzYSncy7AcuVWf9faFTi/7bI+Un+nOpkiSa3zDrPG709T
# 6GNVrPd+xw==
# SIG # End signature block
