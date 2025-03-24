# Cookbook 401 - APM Analysis Server on AWS EC2

This cookbook deploys the Analysis Server of [Riverbed APM](https://www.riverbed.com/products/application-performance-monitoring/) in few clicks. It creates an EC2 instance into an existing VPC/Subnet in your AWS account.

<div align="center">
<img src="images/alluvio-apm-as-on-aws-ec2_login.png" alt="APM AS on AWS EC2" width="70%" height="auto">
</div>

## Prerequisites

1. an account in AWS
2. a temporary URL of the installer packager. This URL must be accessible for the EC2 instance, for example *https://yourbucket.s3.amazonaws.com/temporary/installer.tar?token=123&validity=12*

> [!TIP]
> Check the [Cookbook FAQ](#FAQ) and refer to the [Riverbed Support website](https://support.riverbed.com/content/support/software/aternity-dem/aternity-apm.html)

## Quick Start

In the table below, hit the **Launch Stack** button of the region where you want to deploy the APM Analysis Server.

It will open the console of AWS CloudFormation, follow the wizard. You will have to provide the **temporary URL** of the installer, select a **Subnet** and a **Security Group**, scroll down and finally hit the **Create Stack** button to deploy the APM Analysis Server.

<div align="center">
  
| Geo  | AWS Region | Hit & Deploy |
| --- | --- | --- | 
| US West | us-west-1 (N. California) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| US West | us-west-2 (Oregon) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| US East | us-east-1 (N. Virginia) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| US East | us-east-2 (Ohio) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| South America | sa-east-1 (Sao Paulo) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=sa-east-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Canada | ca-west-1 (Calgary) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ca-west-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Canada | ca-central-1 (Central) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ca-central-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Africa | af-south-1 (Cape Town) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=af-south-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-west-1 (Ireland) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-west-2 (London) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-west-3 (Paris) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-west-3#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-north-1 (Stockholm) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-north-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-south-1 (Milan) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-south-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-south-2 (Spain) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-south-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Europe | eu-central-1 (Frankfurt) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Israel | il-central-1 (Tel Aviv) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=il-central-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Middle East | me-central-1 (UAE) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=me-central-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-northeast-1 (Tokyo) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-northeast-2 (Seoul) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-northeast-3 (Osaka) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-northeast-3#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-south-1 (Mumbai) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-south-2 (Hyderabad) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-south-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-east-1 (Hong Kong) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-east-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-southeast-1 (Singapore) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-1#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-southeast-2 (Sydney) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |
| Asia Pacific | ap-southeast-3 (Jakarta) | [![Deploy to Azure](https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png)](https://console.aws.amazon.com/cloudformation/home?region=ap-southeast-3#/stacks/create/review?templateURL=https://riverbedcommunity-doz301aoz102pq.s3.eu-west-3.amazonaws.com/cookbook-apm-401/cookbook-alluvio-aternity-apm-as-on-aws-ec2.template.yaml&stackName=Riverbed-Community-Cookbook-ALLUVIO-APM-AS-on-EC2) |

</div>

It is ready after just few minutes (usually less than 5 minutes) and you can connect and log into the web console.


## FAQ

### How to create myself a temporary URL of the installer package?

From the [Riverbed Support page](https://support.riverbed.com/content/support/software/aternity-dem/aternity-apm.html) check for *APM Analysis Server (Linux Installer)* and download the latest version of the installer package. Then you can upload it in a storage of your choice, for example in an AWS S3 Bucket from which you can generate a protected temporary URL, for example *https://yourbucket.s3.amazonaws/temporary/installer.tar?token=123&validity=12*. Whether private or public, the URL must be accessible to the EC2 instance, allowing to fetch the package and install the software.

### How to connect to the APM Analysis Server console?

When the stack is created you should be able to connect to web console using the Public URL or Private URL:

- **Public URL**: [https://ec2-your-instance-ip.your_region.compute.amazonaws.com](https://ec2-your-instance.your_region.compute.amazonaws.com)
- **Private URL**: [https://ec2-your-instance-ip.your_region.compute.internal](https://ec2-your-instance.your_region.compute.internal)

> [!TIP]
> - To find the actual **Public URL** or **Private URL**, check the Outputs tab in the AWS CloudFormation stack. Or in the EC2 service, you should have an instance named **APM Analysis Server**
> - If you cannot reach the page, check the connectivity. Possibly the Security Group associated to the EC2 might be blocking port 443
> - For the login / password, refer to the User Guide on [Riverbed Support](https://support.riverbed.com/content/support/software/aternity-dem/aternity-apm.html)

#### License

Copyright (c) 2024-2025 Riverbed

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License.
