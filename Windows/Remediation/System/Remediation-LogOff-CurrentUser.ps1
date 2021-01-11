<#
.Synopsis
   Aternity - Remediation Script: LogOff-CurrentUser
.DESCRIPTION
	This script will logoff the current user
	
	References:
	* https://www.riverbed.com
	* https://help.aternity.com/search?facetreset=yes&q=remediation

.EXAMPLE
   Deploy in Aternity (Configuration > Remediation > Add Action) 
   Action Name: LogOff-CurrentUser
   Description: Log the current user off the system
   SCRIPT PARAMETER
       Parameter Name: Force
       Mandatory: unchecked
       Description: Force log off
       Sample: use "Yes" to force the log off.
   Run the script in the System account: unchecked
#>
# Parameters
$timeout = 60
$comment1 = "Force Logoff of Current User"
$comment2 = "Logged Off Current User"
try
{
	# Load Agent Module
    Add-Type -Path $env:STEELCENTRAL_ATERNITY_AGENT_HOME\ActionExtensionsMethods.dll
    #Add-Type -AssemblyName PresentationCore,PresentationFramework

    #region Remediation action logic

    $Force = $args[0] 

    If($Force -eq 'Yes')
		{
	     shutdown /L /f 
         $timeout 
         $comment1

         $result = "Forced - Logged Off Current User"
         	
        }
	else
		{
         shutdown /L
         $timeout 
         $comment2

         $result = "Logged Off Current User"
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
# MIIFrwYJKoZIhvcNAQcCoIIFoDCCBZwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEGaoORWxnj4GbYI4LkiaqawD
# lSugggM0MIIDMDCCAhigAwIBAgIQasI1FvoLAIBECSZ4K8LprjANBgkqhkiG9w0B
# AQsFADAwMS4wLAYDVQQDDCVBdGVybml0eSBSZW1lZGlhdGlvbiBDb2RlIFNpZ25p
# bmcgTmV3MB4XDTE5MTExNDE1MzQzNloXDTIwMTExNDE1NTQzNlowMDEuMCwGA1UE
# AwwlQXRlcm5pdHkgUmVtZWRpYXRpb24gQ29kZSBTaWduaW5nIE5ldzCCASIwDQYJ
# KoZIhvcNAQEBBQADggEPADCCAQoCggEBANpXDkGW5hgFFZaO2e8vYkuJTWRxe3S6
# AdXQEDdaTnqEZJryKQdAAgI4PeTGZHadn2pWkk8lS4jAdzXC6z55pSVw5EaSTbO/
# toZOuzT0cRjS3ipR/S+1nTtx4HPyqfF5B0xi6DSnfH4cq/LTunMi8ZUKiPYGzjx2
# uP0x4SYShSELERbRg5dZjWY25MxRooj0Nq8gNzc+maUhzOReyN33zT3fkcoQy8Ao
# VJ2yLWlrpuFDfUBdVhSjSmJ3W4QMEJ+tRBXKA5JuVV8TgefGYZme2CCcbNNMzPI7
# 0XI/8vJSiopcnWgtX8d+ckNX49Vv06rAvSRnLkmLPtipk2DgEUurCRkCAwEAAaNG
# MEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0GA1UdDgQW
# BBRlEKAXxHL090LNyhwSW9OcZ8NvaTANBgkqhkiG9w0BAQsFAAOCAQEAeaUVrHXq
# T68Y8QBYUptrz12WwlfzkWNJiG/AjCcaHmQ6WjU9uXgI9paNSbenq70V/938OQ9c
# LYIKOKMrVuB5Z3MSH6qXj7cY+/6CbBFH7/aC3fDxNEXssCxzOjncv2SymF+JXo6J
# ObjHbSwy9purETd4yD1NEHyr2N7QgIKc0F48IamvjZ3oYL9BY9GNjhXcieXc4QOR
# FTyr4EJBpKLWj8Snli40FckaPEv8CUBq+804RGvBnF7Ea7mO81jGp0rcsNvDN/kF
# QavzKEKK/ZIZJfDt8HBIsj2iZAkdWpBzgosQ98l2QbYzMArAq4Ln4HC9RARP1DuU
# nJeYIysa/weYGTGCAeUwggHhAgEBMEQwMDEuMCwGA1UEAwwlQXRlcm5pdHkgUmVt
# ZWRpYXRpb24gQ29kZSBTaWduaW5nIE5ldwIQasI1FvoLAIBECSZ4K8LprjAJBgUr
# DgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMx
# DAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkq
# hkiG9w0BCQQxFgQUx0BPJbCY5EC4J5AOU1o8EwLRNrEwDQYJKoZIhvcNAQEBBQAE
# ggEAJ4UmISGioBDMaWUwP4kph5PLgZWqrx6iVnZ4ZjCgeo1UnkezMGxRiIKxRnoR
# r7XDUC+xuk5nAxGIsYIhpjizksyRbi0rCdaTWk9C4aYaGrfB8PoFTDPJW0fbkaIL
# Q6mNBJedmY6+k56ORyRAtmcsqxfc8xDtnWW3eL2kzuhsgP6EUkdagaqq/XfmEg4b
# mSlgHRMX5/HS9Vb6uHrIG7kpPaSw+QyC5Pcraq17qVzbe7QBTrMVBcyvHD+qn5tY
# AW12VXEFrfUbch32ymSJT0vrDGM1IYKvNo+vXQYJcr+ALgeU1hTv48HaVnvETfOP
# VxatIHrwv7a0FG/jnGlxBvAF6A==
# SIG # End signature block
