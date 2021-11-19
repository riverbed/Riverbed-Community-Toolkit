# 101-instrument-dotnet-app-on-windows

This is a cookbook for a simple setup with Aternity APM to instrument a dotnet web application on a windows server.

## Prerequisites

1. an Aternity APM account
2. a Windows Server virtual machine ready to use, for example an instance in the Cloud (AWS, Azure,...)
3. *optionaly* a fileshare accessible from your server, for example a storage account or S3 bucket.

## Step by Step

### Go to Aternity APM webconsole (in Aternity APM > Agents > Install Agents)

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for *agents.apm.myaccount.aternity.com*
3. Download the Windows Latest Agent installer and store in your favorite storage, for example in an S3 bucket (AWS).

### Download the installer for dotnet SDK

Links: https://dotnet.microsoft.com/download/dotnet/3.1

### Grab the script and set variable

1. Start a fresh Windows Server, for example an instance in the Cloud (AWS, Azure,...)

2. Run a PowerShell as admin to run the script [Setup.ps1](Setup.ps1)

You will need to adapt the script:
- Replace {{my-S3-BUCKET}} with your storage url
- Replace {{my-CustomerId}} and {{my-SaaSAnalysisServerHost}} with your Aternity APM informations

#### License
Copyright (c) 2021 Aternity. The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
