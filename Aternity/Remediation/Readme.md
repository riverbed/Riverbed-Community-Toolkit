## Remediation scripts

In this repo, you will be able to find examples of Remediation scripts shared by the Riverbed Community

Related links:
- Ask the community: https://community.riverbed.com
- Watch how to Improve Service Desk KPIs with SteelCentral Automated Remediation: https://www.youtube.com/watch?v=01GPFS21A9E
- Read the manual https://help.aternity.com/search?facetreset=yes&q=remediation
- Share ideas https://aternity.ideas.riverbed.com 
- Try Aternity http://riverbed.com/try-aternity


## How to contribute?

The community website is currently the best place to start: https://community.riverbed.com.
There you can create questions, attach draft of script, discuss about it,... You can put the word "remediation" in the title or somewhere in your post to find easily.

And if you are already familair with github, please do not hesitate to submit pull requests. More details are coming on this topic.

## FAQ

### Are there generic templates?

A first basic template is available, Aternity-Remediation-Template.ps1.
More advanced, for example with error handling, would be great to have.

### How to return an error status?

The SetFailed method returns a error status with the message in parameter. 
```powershell
[ActionExtensionsMethods.ActionExtensionsMethods]::SetFailed("message")
```

### How to test with signed scripts?

When you have a script (for example, Remediation-DNS-ClearCache.ps1) you have to sign it before configuring it in the Remediation Task in Aternity. The User Device where it will be run must have Aternity agent installed, at least 12.0.0.22, and trust the certificate of the publisher.
The agent installer will by default set Action Policy Execution to Trusted.

Here is how to setup a quick test environment:

**The first time only** 

- Step 1: on your machine, generate a self-signed publisher certificate on your machine and export it to a file:
```powershell
# on the machine where you code Remediation script
$cert=New-SelfSignedCertificate -Subject "Aternity Remediation Code Signing" -Type CodeSigningCert -CertStoreLocation cert:\CurrentUser\My
Export-Certificate -Cert $cert -FilePath  .\Aternity-Remediation-Certificate.cer
Move-Item -Path $cert.PSPath -Destination "Cert:\CurrentUser\Root"
```

- Step 2: on the user test machine, copy the certificate file and import the certificate to the certs stores to setup the trust. The following need to be run with administrator privileges (i.e. Powershell Run as Administrator):
```powershell
# on the test user device
Import-Certificate -FilePath .\Aternity-Remediation-Certificate.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
Import-Certificate -FilePath .\Aternity-Remediation-Certificate.cer -CertStoreLocation Cert:\LocalMachine\Root
``` 

**Each time you need to sign a new script**
Just run the following, replacing "remediation-script.ps1" with the actual name of the script to sign. You can then configure the remediation action in Aternity.
```powershell
# sign
$cert=gci Cert:\CurrentUser\My | Where-Object { $_.Subject -eq "CN=Aternity Remediation Code Signing" }
Set-AuthenticodeSignature -Certificate $cert -FilePath remediation-script.ps1 
```

**Trigger the action in Aternity**
Find the User test device (ex. Search bar), open the Device Events dashboard and run the Remediaction (Run Action button). 
