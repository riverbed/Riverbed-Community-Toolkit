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

When you have a Remediation script ready (for example, Remediation-DNS-ClearCache.ps1) you have to sign it before configuring it in the Remediation action in Aternity. The User Device where it will be run must have Aternity agent installed and trust the certificate of the publisher, as the agent installer will by default set Action Policy Execution to Trusted.

Here is how to setup a quick test environment and sign new Remediation scripts:

#### Seting the test environment, the first time only

- Step 1: On the machine having the Remediation scripts you need to sign, use the script Prepare-RemediationSigning.ps1.
  
It will generate a self-signed publisher certificate for code signing in the local certs store and export it as a certificate file (.cer). In the certs store, the certificate will have the subject "Aternity Remediation Code Signing".

```powershell
.\Prepare-RemediationSigning.ps1
```

Output example:

```output
    Directory: C:\Riverbed-Community-Toolkit\Aternity\Remediation


Mode                LastWriteTime         Length Name
----                -------------         ------ ----
-a----         5/1/2019  12:02 PM            812 Aternity-Remediation-Certificate.cer
```

- Step 2: On the user test machine, copy the certificate file (.cer) in a local directory and from there execute the following Powershell script with administrator privileges (i.e. launch Powershell with Run as Administrator)

It will import the certificate into the machine certs store Root CA and Publishers locations.

```powershell
# on the test user device
Import-Certificate -FilePath .\Aternity-Remediation-Certificate.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
Import-Certificate -FilePath .\Aternity-Remediation-Certificate.cer -CertStoreLocation Cert:\LocalMachine\Root
```

#### Signing a new script

On the machine where the certificate has been generated, the Powershell script Sign-RemediationScript.ps1 is ready to sign Remediation script.

It uses the certificate created previously in the local certs store. The Source parameter is the path of the script to sign and Destination is the path where the signed file will be created.

Example:

```powershell
./Sign-RemediationScript.ps1 -Source .\Remediation-script.ps1 -Destination Signed\Remediation-script-signed.ps1
```

Output example:

```output
    Directory: C:\Riverbed-Community-Toolkit\Aternity\Remediation


SignerCertificate                         Status     Path
-----------------                         ------     ----
E2C88872665FE1B5B8430E53EC7213B1171241E3  Valid      Remediation-script-signed.ps1
```



#### Trigger the action in Aternity

Find the User test device (ex. Search bar), open the Device Events dashboard and run the Remediaction (Run Action button).
