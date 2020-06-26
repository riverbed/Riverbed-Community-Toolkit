# SteelConnect-EX Headend Standalone on Azure - Terraform template

## Overview

The Riverbed Community Toolkit provides this Terraform template to automate the deployment on Azure of a simple SteelConnect-EX Headend in standalone mode.
It can be used directly or using the [SteelConnect-EX Deploy Headend cookbook](../../Azure-DeployHeadend) with easy steps.

## Pre-requisites for using this template:

- **Terraform Install:** to Download & Install Terraform, refer Link "www.terraform.io/downloads.html"
- **Terraform Setup for Azure:** to Setup Terraform for Azure Account, refer link "https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure". Here you will get Subscription ID, Client ID, Client Secret and Tenant ID required for terraform login.
- **SteelConnect-EX appliances images** created from .vhd files (refer to [Riverbed Support](https://support.riverbed.com)):
  - SteelConnect-EX Director image
  - SteelConnect-EX Controller image
  - SteelConnect-EX Analytics image
- **Role:** At least &quot;contributor&quot; level role is required to the Terraform user used to run this template.

## Usage

- Download all the files in PC where Terraform is installed. It is recommended that place all the files in new/separate folder as terraform will store the state file for this environment once it is applied:
- Go to the folder containing all the required files
  - terraform.tfvars
  - main.tf
  - var.tf
  - output.tf
  - director.sh
  - controller.sh
  - analytics.sh
- Edit terraform.tfvars to set custom value (see details below)
- Use command `terraform init` to initialize. it will download necessary terraform plugins required to run this template.
- Use command `terraform plan` to plan the deployment. It will show the plan regarding all the resources being provisioned as part of this template.
- Use command `terraform apply` to apply this plan in action for deployment. It will start deploying all the resource on Azure.

### terraform.tfvars file

terraform.tfvars file is being used to set and overrides the values of the template variables. Users can customize to their environment.

#### List of variables that **MUST** be updated
1. tenant_id: Provide the Tenant ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
2. subscription_id: Provide the Subscription ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
3. client_id: Provide the Client ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
4. client_secret: Provide the Client Secret information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
5. resource_group: resource group name where all the SteelConnect-EX resources will be created. For example, "SteelConnect-EX-Headend"
6. location: Provide the location where user wants to deploy Riverbed HE setup. E.g. westus, centralus etc.
7. image_director: resource id of the Azure Image resource for the SteelConnect-EX Director
8. image_controller: resource id of the Azure Image resource for the SteelConnect-EX Controller
9. image_analytics: resource id of the Azure Image resource for the SteelConnect-EX Analytics
10. ssh_key: Provide the ssh public key information here. This key will be injected into instances which can be used to login into instances later on. You can generate your ssh key using "ssh-keygen" or "putty key generator"

#### Variables with preset values
- vnet_address_space : a /16 network range for the virtual network in Azure. For example, 10.100.0.0/16
- newbits_subnet : subnet information to be cut from the network. Set to "8" to split the adress space into multiple /24 subnets. Since network is in /16 and 8 value here will cut the subnet in /24 (16+8). To create /29 subnets then this newbits_subnet value must be set to "13" as (16+13=29).
- overlay_network: SD-WAN overlay network. For example, 99.0.0.0/8
- hostname_director : hostname for SteelConnect-EX Director to be used. For example, "Director1"
- hostname_analytics : hostname for SteelConnect-EX Analytics to be used. For example, "Analytics1"
- director_vm_size : instance type/size which will be used to provision the SteelConnect-EX Director VM Instance. 
- controller_vm_size : instance type/size which will be used to provision the SteelConnect-EX Controller VM Instance.
- analytics_vm_size : instance type/size which will be used to provision the SteelConnect-EX Analytics VM Instance.

### Other files

**main.tf**

main.tf template deploys the following into an Azure Resource Group (default name is "SteelConnect-EX-Headend"):
- Virtual Network (the range can be changed in terraform.tfvars) with Management, Control and Analytics subnets (/24 prefix):
  - First subnet (a /24 subnet) for management.
  - Second subnet (a /24 subnet) for control, connecting control interface of  Director, Controller and Analytics.
  - Third subnet (a /24 subnet) for WAN connectivity to branches, i.e. an Internet Uplink.
- a Public IP nating to the network interface in the Management subnet for each appliance.
- a Static Public IP for Controller WAN interface (Internet uplnik)
- the Route Table for the Control subnet to use controller as a gateway to the overlay network.
- a Network Security Group with simple firewall rules for Headend
- VM for SteelConnect-EX Director appliance with initialization (execute script director.sh via cloud-init):
  - Update system hostname, /etc/network/interface and /etc/hosts
  - Inject the ssh key for Administrator User
  - Configure Director: generate new certificates, vnms-startup
- VM for SteelConnect-EX Controller appliance with initialization (execute script controller.sh via cloud-init):
  - Update system /etc/network/interface
  - Inject the ssh key for administrative user account
- VM for SteelConnect-EX Analytics appliance with initialization (execute script analytics.sh via cloud-init):
  - Update system /etc/network/interface and /etc/hosts
  - Inject the ssh key for administrative user account
  - Configure Analytics: import certificates from Director, vansetup and log-exporter

**var.tf**

var.tf file will have definition for all the variables defined/used as part of this template. User does not need to update anything in this file.

**output.tf**

output.tf file will have information to provide the output for the parameters (e.g. Management IP, Public IP, CLI command, UI Login for all the instances) after terraform apply operation is succeeded. User does not need to update anything in this file.

**director.sh file:**

director.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect-EX Director Instance.

**controller.sh file:**

controller.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect-EX Controller Instance.

**analytics.sh file:**

analytics.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect-EX Analytics Instance.

## License

Copyright (c) 2020 Riverbed Technology, Inc.
The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
