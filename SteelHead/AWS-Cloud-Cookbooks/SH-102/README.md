# Create VPC, Subnets, Workload, Acceleration and service chain with gateway appliance
This scenario will create a VPC, required Subnets, workloads, SteelHead appliance and then service chain with gateway appliance. Administrator will be responsible for deplying & configuring the gateway appliance in the given subnet.

### Step 1: Create VPC, Subnets and Workload
The below launch stack button will create:
- a VPC to seperate resources (Subnets & VMs) from other network.
- servernetwork: connecting some Virtual Machines and PAAS services.
- gateway downlink to connect with SteelHead appliance.

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=SH-Deployment-In-VPC&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/SH-Deployment-With-VPC-And-Subnets.template)

**Note**:- By default the SteelHead appliance will be deployed in AWS region - ap-south-1. You can copy the url and change the region parameter accordingly in the URL. In below URL change **region=ap-south-1** with your region.
```PowerShell
https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=SH-Deployment-In-VPC&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/SH-Deployment-In-VPC.template
```
