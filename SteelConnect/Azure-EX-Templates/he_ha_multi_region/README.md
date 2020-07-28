This Terraform Template is intended to Automate the bringing up Riverbed Head End setup on Azure in redundant mode. It will bring up 2 instances of Riverbed Director, Riverbed Controller and Riverbed Analytics in different regions.

# Pre-requisites for using this template:

- **Terraform Install:** To Download & Install Terraform, refer Link "www.terraform.io/downloads.html"
- **Terraform Setup for Azure:** To Setup Terraform for Azure Account, refer link "https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure".
  Here you will get Subscription ID, Client ID, Client Secret and Tenant ID required for terraform login.
- **Riverbed Head End Images:** Image available and added in Azure in .vhd format for:
  - Riverbed Director
  - Riverbed Controller
  - Riverbed Analytics
  
- **Role:** At least &quot;contributor&quot; role on the subscription is required to the Terraform user used to run this template.

# Usage:

- Download all the files in PC where Terraform is installed. It is recommended that place all the files in new/separate folder as terraform will store the state file for this environment once it is applied.
- Go to the folder where all the required files are placed using command prompt.
- Use command `terraform init` to initialize. it will download necessary terraform plugins required to run this template.
- Then use command `terraform plan` to plan the deployment. It will show the plan regarding all the resources being provisioned as part of this template.
- At last use command `terraform apply` to apply this plan in action for deployment. It will start deploying all the resource on Azure.


It will require below files to run it.

- main.tf file.
- var.tf file.
- terraform.tfvars file.
- output.tf file.
- director-1.sh file.
- director-2.sh file.
- controller.sh file.
- van-1.sh file.
- van-2.sh file.

**main.tf file:**

main.tf template file will perform below actions/activities when executed:

- Provision one resource group with name "Riverbed_HE_HA-1" and "Riverbed_HE_HA-2" in respective region. Resource Group name can be changed if required after updating terraform.tfvars file.
- Provision one Virtual Network "10.54.0.0/16" in region one and another Virtual Network "10.55.0.0/16" in another region. This can be changed after updating terraform.tfvars file.
- Provision 6 Subnets with /24 network in each region. This can be changed after updating terraform.tfvars file.
  - First subnet for management of all the Riverbed HE instances. Here Public IP will be assigned to each port.
  - Second subnet for Director SB, Router NB and Analytics SB ports.
  - Third subnet will be for Router to Router connectivity to run BGP between routers.
  - Fourth subnet will be for Router SB and Controller NB ports. This is Control network.
  - Fifth subnet will be for Controller SB and Branch NB ports. This is WAN network.
  - Sixth subnet will be for Branch SB ports. This is LAN network.
- Provision the VNet Peering between these networks across region.
- Provision Public IP for all the instances for Management Port and also one Static Public IP for Controller WAN Port.
- Provision User Defined Routes.
- Provision Network Security Group and add all the firewall rules required for HE setup.
- Provision Network Interfaces for all the instances.
- Install Riverbed Director instances in each region and run cloud-init script for:
  - Updating the /etc/network/interface file.
  - Updating the /etc/hosts and hostname file.
  - Install necessary routes for controller and overlay networks into /etc/rc.local. *THIS MEANS YOU DO NOT NEED TO ADD THE ROUTES IN THE UI*
  - Inject the ssh key for Administrator User
  - Generate the new certificates.
  - Execute vnms-startup script in non-interactive mode.
- Install Riverbed Router instances in each region and run cloud-init script for:
  - Updating /etc/network/interface file.
  - Inject the ssh key for admin user
- Install Riverbed Controller instances in each region and run cloud-init script for:
  - Updating /etc/network/interface file.
  - Inject the ssh key for admin user
- Install Riverbed Analytics instances in each region and run the cloud-init script for:
  - Updating the /etc/network/interface file.
  - Updating the /etc/hosts file.
  - Install necessary routes for controller and overlay networks into /etc/rc.local.
  - Inject the ssh key for analytics user
  - Copy certificates from Riverbed Director and install this certificate into Analytics.

**var.tf file:**

var.tf file will have definition for all the variables defined/used as part of this template. User does not need to update anything in this file.

**terraform.tfvars file:**

terraform.tfvars file is being used to get the variables values from user. User need to update the required fields according to their environment. This file will have below information:

- subscription_id : Provide the Subscription ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- client_id : Provide the Client ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- client_secret : Provide the Client Secret information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- tenant_id : Provide the Tenant ID information here. This information will be obtained as part of terraform login done above under Pre-requisites step.
- location : Provide the location where user wants to deploy Riverbed HE setup. User need to update both the locations where redundant setup is required. E.g. westus and centralus.
- resource_group : Provide the resource group name where all the resources belonging to Riverbed HE Setup will be created. Default resource group name "Riverbed_HE_HA" will be used.
- ssh_key : Provide the ssh public key information here. This key will be injected into instances which can be used to login into instances later on. Azure does not provide the option to generate the keys. User has to generate the ssh key using "sshkey-gen" or "putty key generator" tool to generate the ssh keys. Here Public key information is required.
- vpc_address_space : Provide the address space information to create the network in azure in both regions. By default, 10.54.0.0/16 and 10.55.0.0/16 network will be created in respective region.
- newbits_subnet : Provide the subnet information to be cut from the network. By default, /24 subnet will be cut from the network provisioned above. Here, newbits_subnet will have value "8" for this parameter. Since network is in /16 and 8 value here will cut the subnet in /24 (16+8). E.g., If user need to create a subnet of /29 then this newbits_subnet value will be "13" as (16+13=29).
- overlay_network: Provide the SD-WAN overlay network address space. This will be used for installing routes on the Director and Analytics nodes to point to the controllers.
- image_director : Provide the Riverbed Director Image ID for both the regions.
- image_controller : Provide the Riverbed Controller Image ID for both the regions.
- image_analytics : Provide the Riverbed Analytics Image ID for both the regions.
- hostname_director : Provide the hostname for both Riverbed Director instances to be used. By default, "Director1" and "Director2" hostname is being used for each instance.
- hostname_van : Provide the hostname for both Riverbed Analytics instances to be used. By default, "Analytics1" and "Analytics2" hostname is being used for each instance.
- director_vm_size : Provide the instance type/size which will be used to provision the Riverbed Director Instance. By default, Standard_DS3 will be used.
- controller_vm_size : Provide the instance type/size which will be used to provision the Riverbed Controller Instance. By default, Standard_DS3 will be used.
- router_vm_size : Provide the instance type/size which will be used to provision the Riverbed Router Instance. By default, Standard_DS3 will be used.
- analytics_vm_size : Provide the instance type/size which will be used to provision the Riverbed Analytics Instance. By default, Standard_DS3 will be used.

**output.tf file:**

output.tf file will have information to provide the output for the parameters (e.g. Management IP, Public IP, CLI command, UI Login for all the instances) after terraform apply operation is succeeded. User does not need to update anything in this file.

**director-1.sh file:**

director-1.sh file will have bash script which will be executed as part of cloud-init script on Riverbed Director-1 Instance. Don't update anything in this file.

**director-2.sh file:**

director-2.sh file will have bash script which will be executed as part of cloud-init script on Riverbed Director-2 Instance. Don't update anything in this file.

**controller.sh file:**

controller.sh file will have bash script which will be executed as part of cloud-init script on Riverbed Controller Instance. Don't update anything in this file.

**van-1.sh file:**

van-1.sh file will have bash script which will be executed as part of cloud-init script on Riverbed Analytics-1 Instance. Don't update anything in this file.

**van-2.sh file:**

van-2.sh file will have bash script which will be executed as part of cloud-init script on Riverbed Analytics-2 Instance. Don't update anything in this file.

As part of this terraform template below topology will be brought up:

 ![Topology](https://raw.githubusercontent.com/gleyfer/Riverbed-Community-Toolkit/master/SteelConnect/Azure-EX-Templates/he_ha_multi_region/Topology_Riverbed_HE_HA_Azure.png)

## License

Copyright (c) 2019 Riverbed Technology, Inc.
The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
