# Cookbook - Cluster of 2 active Cloud SteelHead appliances

## Fast-forward

Click the button "Deploy in Azure" to open the ARM template in the Azure Portal where you can customize the parameters before deploying the resources:

[![Deploy To Azure](https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Friverbed%2FRiverbed-Community-Toolkit%2Fmaster%2FSteelHead%2FAzure-Cloud-Cookbooks%2F103-deploy-active-active%2Fazuredeploy-active-active-azcsh.json)

## 1 - Overview

The cookbook contains technical artifacts to deploy a cluster of 2 active Cloud SteelHead appliances in Azure.
The code comes from some 2017 contributions and might need review or refinement.

> You might also be interested by the other cookbook [102 - Acceleration Scale Out in Azure](../102-scale-out), that allow to deploy a similar setup with more recent and generic templates and scripts.

## 2 - Quickstart

After deploying in Azure using the ARM template. The Steelhead can be configured via CLI using the configuration script.


### License

Copyright (c) 2017 Riverbed Technology, Inc.
The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.