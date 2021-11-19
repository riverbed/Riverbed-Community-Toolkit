# 101-instrument-dotnet-app-on-windows

## Prerequisites

1. an Aternity APM account
2. a Windows Server virtual machine ready to use, for example an instance in the Cloud (AWS, Azure,...)
3. *optionaly* a fileshare accessible from your server, for example a storage account or S3 bucket.

## Step by Step

### Go to Aternity APM webconsole (in Aternity APM > Agents > Install Agents)

1. Find your **CustomerID**, for example 12341234-12341234-13241234
2. Grab **SaaS Analysis Server Host**, for agents.apm.myaccount.aternity.com
3. Download the Windows Latest Agent installer and store in your favorite storage, for example in an S3 bucket (AWS).

### Download the installer for dotnet SDK

### Grab the script and set variable

1. Start a fresh Windows Server, for example an instance in the Cloud (AWS, Azure,...)

2. Run a PowerShell as admin to run the script [Setup.ps1](Setup.ps1)

You will need to adapt the script:
- Replace {{my-S3-BUCKET}} with your storage url
- Replace {{my-CustomerId}} and {{my-SaaSAnalysisServerHost}} with your Aternity APM informations
