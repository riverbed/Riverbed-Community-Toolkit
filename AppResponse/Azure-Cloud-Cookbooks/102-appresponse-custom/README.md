# Riverbed Community Cookbooks - AppResponse Custom Demo

[![Deploy to Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Friverbed%2FRiverbed-Community-Toolkit%2Fmaster%2FAppResponse%2FAzure-Cloud-Cookbooks%2F102-appresponse-custom%2Fazuredeploy.json) [![Deploy to Azure Gov](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazuregov.svg?sanitize=true)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Friverbed%2FRiverbed-Community-Toolkit%2Fmaster%2FAppResponse%2FAzure-Cloud-Cookbooks%2F102-appresponse-custom%2Fazuredeploy.json)

Deploy [Riverbed AppResponse](https://www.riverbed.com/products/npm/netim.html) in your own Azure Cloud subscription with the Riverbed Community Toolkit provided by the [Riverbed Community](https://community.riverbed.com/).
Please have a try and join the [Riverbed Community](https://community.riverbed.com/) to discuss.

This Cookbook is used in the [AppResponse Simple Demo cookbook](../101-appresponse-simple-demo). It allows to customize the deployment of AppResponse, such as deploying in an existing Virtual Network, changing IP Addresses or VM Sizing.

## Prerequisites

- The VHD source image of AppResponse appliance must have been imported in an accessible Blob Container of Storage Account.

- Existing Virtual Network (VNET) and subnet to deploy the appliance

## Deployment steps

1. Hit the "Deploy to Azure" button above
2. Fill usual fields:
    - Subscription
    - Resource Group: create a new, e.g. Riverbed-AppResponse-Custom
    - Region: Select an Azure Region
3. Fill the parameters for customizations
4. Hit "Review + create", then hit "Create"
5. Wait for the deployment, approximately 10 min

## Notes

`Tags: Riverbed,Visibility,NPM,Network,Performance,Monitoring,AppResponse,Packet,Capture`
