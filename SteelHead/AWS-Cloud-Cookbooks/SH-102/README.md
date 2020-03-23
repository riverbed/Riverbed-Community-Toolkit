# Create VPC, Subnets, Workload, Acceleration and service chain with gateway appliance
This scenario will create a VPC, required Subnets, workloads, SteelHead appliance and then service chain with gateway appliance. Administrator will be responsible for deplying & configuring the gateway appliance in the given subnet.

### Step 1: Create VPC, Subnets and Workload
The below launch stack button will create:
- a VPC to seperate resources (Subnets & VMs) from other network.
- servernetwork: connecting some Virtual Machines and PAAS services.(ToDo)
- gateway downlink network: To deploy SteelHead appliance.

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=Create-VPC-And-Subnets&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/Create-VPC-And-Subnets.template)

**Note**:- By default the SteelHead appliance will be deployed in AWS region - ap-south-1. You can copy the url and change the region parameter accordingly in the URL. In below URL change **region=ap-south-1** with your region.
```PowerShell
https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=Create-VPC-And-Subnets&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/Create-VPC-And-Subnets.template
```

### Step 2: Deploy Acceleration in an existing VPC
Click below button to launch stack in AWS.

[![Launch Stack](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/new?stackName=SH-Deployment-In-VPC&templateURL=https://rvbd-community-toolkit.s3-eu-west-1.amazonaws.com/SH-Deployment-In-VPC.template)

Follow [SH-101 README](../SH-101/README.md) steps to deploy acceleration in a VPC created in Step 1.

### Step 3: Service Chain with Gateway appliance
To Do.

## License

Copyright (c) 2019 Riverbed Technology, Inc.
The scripts provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
