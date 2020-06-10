# Generate Azure Credentials for SteelConnect automation

## 1. Open Cloud Shell (select Bash mode)

Try from shell.azure.com or clicking 
[![Embed launch](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)

## 2. Run the following bash commands to download and execute the script **azure_credentials_generate.sh**: 

```bash
wget https://raw.githubusercontent.com/riverbed/se-toolkit/master/SteelConnect/Azure-Generate-Credentials/azure_credentials_generate.sh

chmod +x azure_credentials_generate.sh

azure_credentials_generate.sh
```

About 2 min after you will get the output with all the parameters required to add the Azure account in SteelConnect SCM > Network Design > Azure.
