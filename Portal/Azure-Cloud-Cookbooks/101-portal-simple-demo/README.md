# Riverbed Community Cookbooks - Portal Simple Demo

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Friverbed%2FRiverbed-Community-Toolkit%2Fmaster%2FPortal%2FAzure-Cloud-Cookbooks%2F101-portal-simple-demo%2Fazuredeploy.json) [![Deploy to Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Friverbed%2FRiverbed-Community-Toolkit%2Fmaster%2FPortal%2FAzure-Cloud-Cookbooks%2F101-portal-simple-demo%2Fazuredeploy.json)

Deploy [Riverbed Portal](https://www.riverbed.com/products/npm/portal) in your own Azure Cloud subscription in just few clicks with the Riverbed Community Toolkit provided by the [Riverbed Community](https://community.riverbed.com/).

Please have a try and join the [Riverbed Community](https://community.riverbed.com/) to discuss.

## Deployment Steps

1. Hit the "Deploy to Azure" button above
2. Fill usual fields:
    - Subscription
    - Resource Group: create a new, e.g. Riverbed-Portal-Demo
    - Region: Select an Azure Region
3. Fill the parameters
    - Appliance Source Image Blob Uri: uri of the Blob containing the VHD of Portal. The blob name at source must be properly formatred, for example **Portal_3.5.0.vhd**
    - Appliance Size: Size of the Azure VM, Standard_B8ms is a minimum
    - Demo Jumpbox Username: Default is riverbed-community
    - Demo Jumpbox Password: Set a password with enough complexity (8 characters lengths, 1 or more numeric, 1 or more special characters)
4. Hit "Review + create", then hit "Create"
5. Wait for the deployment, approximately 15 min

## Usage

When the deployment is done, grab the the default admin credential from the deployment outputs. They will be required to log on the Portal appliance webconsole.

![Outputs](images/outputs.png)

A simple topology with a Portal VM appliance and a Windows VM will have been created. The Windows VM is a *demo jumpbox* from which you can connect to the Portal webconsole.

![Topology](images/portal-demo-topology.svg)

In the Azure Portal, navigate to the resource group. Then find the virtual machine named "Visibility" and connect via the Bastion using the Jumpbox username and password set in the deployment steps.

| Connect from Azure Portal | Open Session |
| --- | --- |
| ![Bastion](images/visibility-connect-bastion.png) | ![Session](images/visibility-bastion-session.png) |

On the Jumpbox you can launch the web browser, navigate to the Portal webconsole url https://10.100.5.5 and log in with the initial admin credential of the appliance (grabbed earlier from the deployment output).

![Portal Cloudy](images/visibility-portal-login.png)

## Notes

`Tags: Riverbed,Visibility,NPM,Network,Performance,Monitoring,Portal,Dashboard,Unified`
