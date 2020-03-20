# Deploying Acceleration in an existing VPC having a gateway appliance (VPN or SD-WAN)

SH-101 scenario deploys a steelhead instance in your existing AWS infrastructure. Typically, VPN or SD-WAN solutions have a gateway inside the AWS VPC to interconnect with other sites gateways. It is a one click deployment solution and the Administrator will be responsible for configuring the access to SteelHead & routing via SteelHead.

## Please follow below steps:
### Step 1: Launch Stack in AWS
Click below button to launch stack in AWS. It will redirect you to AWS cloudformation console.

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=SH-Deployment-In-VPC&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/SH-Deployment-In-VPC.template)

**Note**:- By default the SteelHead appliance will be deployed in AWS region - ap-south-1. You can copy the url and change the region parameter accordingly in the URL. In below URL change **region=ap-south-1** with your region.
```PowerShell
https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=SH-Deployment-In-VPC&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/SH-Deployment-In-VPC.template
```
