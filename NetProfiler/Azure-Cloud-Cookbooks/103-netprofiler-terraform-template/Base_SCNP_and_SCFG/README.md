# Netprofiler and Flowgateway virtual appliances 
## Description
A step by step guide to bring up a netprofiler and flowgateway base in Microsoft Azure.

# Steps
### 1. Login into Azure Cloud Shell
### 2. Copy the terraform files from Github onto the Cloud Shell
The terraform files will be used to bring up the following appliances:  
1. Netprofiler  
2. Flowgateway  
3. Ubuntu Linux 14.04 (for testing purposes)
```
curl -O https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/master/NetProfiler/Azure-Cloud-Cookbooks/103-netprofiler-terraform-template/Base_SCNP_and_SCFG/main.tf
curl -O https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/master/NetProfiler/Azure-Cloud-Cookbooks/103-netprofiler-terraform-template/Base_SCNP_and_SCFG/terraform.tfvars
curl -O https://raw.githubusercontent.com/riverbed/Riverbed-Community-Toolkit/master/NetProfiler/Azure-Cloud-Cookbooks/103-netprofiler-terraform-template/Base_SCNP_and_SCFG/var.tf
```
### 3. Accept the legal terms for the appliances
```
az vm image terms accept --urn riverbed:netprofiler:scnp-ve-base:latest
az vm image terms accept --urn riverbed:flowgateway:scfg-ve-base:latest
az vm image terms accept --urn canonical:0001-com-ubuntu-pro-trusty:pro-14_04-lts:latest
```
### 4. Make the changes in the terraform.tfvars file  
   a. add subscription id  
   b. define resource name  
   c. add strong passwords and verify login names  
   d. change the domain name labels  
   

### 5. Initialize terraform
```
terraform init
```
### 6. Generate the configuration plan
```
terraform plan -out=npm-plan
```
### 7. Deploy the configuration
```
terraform apply npm-plan
```
### 8. Connect to NP & FG via HTTPS://<ip|dns>:
initially you see: "Running /usr/mazu/etc/firstboot.d/02-cascade-disk-setup.sh"  
then finally "The application is initializing, please try again later."  
takes quite a bit eg about 40+ min for FlowGateway  

### 9. list resource state
```
terraform state list
```
### 10. destroy the deployment
```
terraform destroy
```