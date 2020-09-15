# Overview

This Terraform Template is intended to automate the deployment of a High Availability SteelConnect EX Head End in Azure. It will bring up 2 instances of the SteelConnect EX Director, Controller and Service node Router in two different regions. Additionally, it will create an Analytics cluster with a configurable number of nodes in the primary region and a Log Forwarder Cluster with a configurable number nodes in the secondary region. The topology created by the template is pictured below:

 ![Topology](https://raw.githubusercontent.com/gleyfer/Riverbed-Community-Toolkit/master/SteelConnect/Azure-EX-Templates/he_ha_multi_region/SteelConnect-EX_HE_HA_Azure.png)

The Router service nodes must be configured to send traffic destined to the overlay subnet via routes learned over BGP from the Controller in the local region and peer Router in the other region. All other communication between instances uses the Azure backbone gateway.
 
# Pre-requisites for using this template:

- **Terraform Install:** To Download & Install Terraform, refer Link "www.terraform.io/downloads.html". Alternatively, Terraform can be used directly from the Azure Cloud Shell.
- **Terraform Setup for Azure:** To Setup Terraform for Azure Account, refer link "https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure".
  Here you will get Subscription ID, Client ID, Client Secret and Tenant ID required for terraform login.
- **SteelConnect-EX Head End Images:** Please contact Riverbed Support to obtain the images in .vhd format for:
  - SteelConnect-EX Director
  - SteelConnect-EX Controller
  - SteelConnect-EX Analytics
  
- **Role:** At least &quot;contributor&quot; role on the subscription is required to the Terraform user used to run this template.

# Usage:

- Download the Riverbed Community Toolkit either to the PC running terraform or to cloud shell storage:

```PowerShell
# Get a local copy of the Riverbed Community Toolkit scripts from Github
git clone https://github.com/riverbed/Riverbed-Community-Toolkit.git
```

- Change to the HA template folder:

```PowerShell
cd ./Riverbed-Community-Toolkit/SteelConnect/Azure-EX-Templates/he_ha_multi_region/
```

- Fill in the necessary values in the terraform.tfvars file.
- Use the command `terraform init` to initialize. it will download necessary terraform plugins required to run this template.
- Then use the command `terraform plan` to plan the deployment. It will show the plan regarding all the resources being provisioned as part of this template.
- Lastly, use the command `terraform apply` to start deploying all of the resources in Azure.


It will require below files to run it.

- main.tf file.
- vars.tf file.
- terraform.tfvars file.
- output.tf file.
- director-1.sh file.
- director-2.sh file.
- controller.sh file.
- van.sh file.
- fwd.sh file.

**main.tf file:**

main.tf template file will perform below actions/activities when executed:

- Provision one resource group with name "SteelConnect-EX-HE-1" and "SteelConnect-EX-HE-2" in respective region. Resource Group name can be changed if required by updating terraform.tfvars file.
- Provision one Virtual Network "10.54.0.0/16" in region one and another Virtual Network "10.55.0.0/16" in another region. This can be changed by updating terraform.tfvars file.
- Provision 7 Subnets with /24 network in each region. This can be changed by updating terraform.tfvars file.
  - First subnet for management of all the SteelConnect EX HE instances. Here, a Public IP will be assigned to each instance.
  - Second subnet for Director SB, Router NB and Analytics SB ports.
  - Third subnet will be for Router to Router connectivity to run BGP between routers.
  - Fourth subnet will be for Router SB and Controller NB ports. This is Control network.
  - Fifth subnet will be for Controller SB and Branch NB ports. This is WAN network.
  - Sixth subnet will be for Branch SB ports. This is LAN network.
  - Seventh subnet will be for the Analytics/Forwarder internal cluster communication.
- Provision the VNet Peering between these networks across region.
- Provision Public IP for all the instances for Management Port and also one Static Public IP for Controller WAN Port.
- Provision User Defined Routes.
- Provision Network Security Group and add all the firewall rules required for HE setup.
- Provision Network Interfaces for all the instances.
- Install SteelConnect EX Director instances in each region and run cloud-init script for:
  - Updating the /etc/network/interface file.
  - Updating the /etc/hosts and hostname file.
  - Install necessary routes for controller and overlay networks. *DO NOT NEED TO ADD THE ROUTES IN THE DIRECTOR UI*
  - Inject the ssh key for Administrator User
  - Generate the new certificates.
  - Execute vnms-startup script in non-interactive mode.
- Install SteelConnect EX Router instances in each region and run cloud-init script for:
  - Updating /etc/network/interface file.
  - Inject the ssh key for admin user
- Install SteelConnect EX Controller instances in each region and run cloud-init script for:
  - Updating /etc/network/interface file.
  - Inject the ssh key for admin user
- Install SteelConnect EX Analytics instances in primary region and run the cloud-init script for:
  - Updating the /etc/network/interface file.
  - Updating the /etc/hosts file.
  - Install necessary routes for controller and overlay networks into /etc/rc.local.
  - Inject the ssh key for analytics user
  - Copy certificates from SteelConnect EX Director and install this certificate into Analytics.
- Install SteelConnect EX Log Forwarder instances in secondary region and run the cloud-init script for:
  - Updating the /etc/network/interface file.
  - Updating the /etc/hosts file.
  - Install necessary routes for controller and overlay networks into /etc/rc.local.
  - Inject the ssh key for analytics user

**var.tf file:**

var.tf file will have definition for all the variables defined/used as part of this template. User does not need to update anything in this file.

**terraform.tfvars file:**

terraform.tfvars file is being used to get the variables values from user. User need to update the required fields according to their environment. This file will have below information:

- subscription_id : Provide the Subscription ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- client_id : Provide the Client ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- client_secret : Provide the Client Secret information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- tenant_id : Provide the Tenant ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- location : Provide the regions where user wants to deploy SteelConnect EX HE setup. User need to update both the locations where redundant setup is required. E.g. westus and centralus.
- resource_group : Provide the resource group name prefix where all the resources belonging to SteelConnect EX HE Setup will be created. Default resource group name prefix "SteelConnect-EX-HE" will be used and a resource group will be created for each specified region.
- ssh_key : Provide the ssh public key information here. This key will be injected into instances which can be used to login into instances later on. Azure does not provide the option to generate the keys. User has to generate the ssh key using "sshkey-gen" or "putty key generator" tool to generate the ssh keys. Here Public key information is required.
- vpc_address_space : Provide the address space information to create the network in azure in both regions. By default, 10.54.0.0/16 and 10.55.0.0/16 network will be created in respective region.
- newbits_subnet : Provide the subnet information to be cut from the network. By default, /24 subnet will be cut from the network provisioned above. Here, newbits_subnet will have value "8" for this parameter. Since network is in /16 and 8 value here will cut the subnet in /24 (16+8). E.g., If user need to create a subnet of /29 then this newbits_subnet value will be "13" as (16+13=29).
- overlay_network: Provide the SD-WAN overlay network address space. This will be used for installing routes on the Director and Analytics nodes to point to the controllers. By default, 172.30.0.0/15 will be used.
- image_director : Provide the SteelConnect EX Director Image ID for both the regions.
- image_controller : Provide the SteelConnect EX Controller Image ID for both the regions.
- image_analytics : Provide the SteelConnect EX Analytics Image ID for both the regions.
- hostname_director : Provide the hostname for both SteelConnect EX Director instances to be used. By default, "Director1" and "Director2" hostname is being used for each instance.
- hostname_analytics : Provide the hostname for SteelConnect EX Analytics instances to be created in the primary region. Adding more hostnames dynamically grows the Analytics cluster. By default, a two node cluster consisting of "Analytics" and "Search" hostnames is created. This can be expanded by adding more hostnames in this variable delimited by commas. E.g. hostname_analytics = ["Analytics1","Analytics2","Search1","Search2"] would create a four node cluster in the primary region.
- hostname_forwarders : Provide the hostname for SteelConnect EX Log Forwarder instances to be created in the secondary region. Adding more hostnames dynamically grows the Log forwarder cluster. By default, a two node cluster consisting of "Forwarder1" and "Forwarder2" hostnames is created. This can be expanded by adding more hostnames in this variable delimited by commas. E.g. hostname_forwarders = ["Forwarder1","Forwarder2","Forwarder3","Forwarder4"] would create a four node cluster in the secondary region.
- director_vm_size : Provide the instance type/size which will be used to provision the SteelConnect EX Director Instance. By default, Standard_F8s_v2 will be used.
- controller_vm_size : Provide the instance type/size which will be used to provision the SteelConnect EX Controller Instance. By default, Standard_F8s_v2 will be used.
- router_vm_size : Provide the instance type/size which will be used to provision the SteelConnect EX Router Instance. By default, Standard_F4s_v2 will be used.
- analytics_vm_size : Provide the instance type/size which will be used to provision the SteelConnect EX Analytics Instance. By default, Standard_F8s_v2 will be used.
- forwarder_vm_size : Provide the instance type/size which will be used to provision the SteelConnect EX Log Forwarder Instances. By default, Standard_F4s_v2 will be used.

**output.tf file:**

output.tf file will have information to provide the output for the parameters (e.g. Management IP, Public IP, CLI command, UI Login for all the instances) after terraform apply operation is succeeded. User does not need to update anything in this file.

**director-1.sh file:**

director-1.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect EX Director-1 Instance. Don't update anything in this file.

**director-2.sh file:**

director-2.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect EX Director-2 Instance. Don't update anything in this file.

**controller.sh file:**

controller.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect EX Controller Instance. Don't update anything in this file.

**van.sh file:**

van.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect EX Analytics Instances. Don't update anything in this file.

**fwd.sh file:**

fwd.sh file will have bash script which will be executed as part of cloud-init script on SteelConnect EX Log Forwarder Instances. Don't update anything in this file.

## License

Copyright (c) 2020 Riverbed Technology, Inc.
The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
