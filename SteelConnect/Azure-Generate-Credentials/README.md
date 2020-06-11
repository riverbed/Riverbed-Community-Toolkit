# Generate Azure Credentials for SteelConnect automation

## Steps

### 1. Open Cloud Shell 

Try from shell.azure.com or clicking 
[![Embed launch](https://shell.azure.com/images/launchcloudshell.png "Launch Azure Cloud Shell")](https://shell.azure.com)

### 2. Select PowerShell or Bash Mode

#### Method 1 in PowerShell

Download the the scripts

```PowerShell
# Check the Azure context, i.e check subscription and tenant id are correct
Get-AzContext

# Comment our the line below and replace {your subscription name} if you need to select a different subscription
# Set-AzContext -SubscriptionName "{your subscription name}"

# Get a local copy of the Riverbed Community Toolkit scripts from Github
git clone https://github.com/riverbed/Riverbed-Community-Toolkit.git
```

Run the script and keep the output:

```PowerShell
Set-Location ./Riverbed-Community-Toolkit
Set-Location ./SteelConnect/Azure-Generate-Credentials
./SteelConnect-EX_Generate-AzureCredentials.ps1
```

Copy the details from the output to setup a connector to Azure in the next step:

- Subscription ID
- Tenant ID
- Application ID / Client ID
- Secret Key

#### Method 2 in Bash mode

The following bash commands download the script [azure_credentials_generate.sh](azure_credentials_generate.sh) that create a service principal.

```bash
wget https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/master/SteelConnect/Azure-Generate-Credentials/azure_credentials_generate.sh

chmod +x azure_credentials_generate.sh

azure_credentials_generate.sh
```

About 2 min after, the output will display the generated credential and application details to setup a connector to Azure:

- Subscription ID
- Application ID (client ID)
- Secret Key
- Tenant ID

### 3. Configure SteelConnect

Use the credentials and details to configure the Azure connector in SteelConnect CX or EX:

- in SteelConnect CX from the SCM > Network Design > Azure

- in SteelConnect EX from the Director > Administration > Connectors > CMS, new connector for Azure

![steelconnect-ex-azure-cms-connector](images/steelconnect-ex-azure-cms-connector.png)
