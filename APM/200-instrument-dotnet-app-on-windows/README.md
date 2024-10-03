# 200-instrument-dotnet-app-on-windows

This cookbook helps to setup a simple dotnet web application on a Windows Server with the APM agent, to start practicing Digital Experience Monitoring (DEM) with [APM](https://www.riverbed.com/products/application-performance-monitoring/).

## Prerequisites

1. an APM account
2. a Windows Server virtual machine ready to use, for example a Windows Server 2019 instance in the Cloud (AWS, Azure,...)
3. *optionally* a fileshare accessible from your server, for example a storage account or S3 bucket.

## Step by Step

### Connect to APM web console

Navigate to APM > Agents > Install Agents:

1. Find your **CustomerID**, for example *12341234-12341234-13241234*
2. Grab **SaaS Analysis Server Host**, for example *agents.apm.myaccount.aternity.com*
3. Download the **Windows Latest Agent** installer, for example *AppInternals_Agent_12.1.0.597_Win.exe*

### Download the installer for dotnet SDK

Go to https://dotnet.microsoft.com/download/dotnet/3.1 to download the latest installer for Windows, for example *dotnet-sdk-3.1.415-win-x64.exe*

### Store the installers into your storage

Store the installer package in your favorite storage, for example in a Storage Account container (Azure) or S3 bucket (AWS). Then, grab the URLs to be used in the next step.

1. APM Windows Latest Agent
2. dotnet SDK installer

### Grab the Setup script and configure the variables before running it

1. Start a fresh Windows Server
2. Fetch the script [Setup.ps1](Setup.ps1) and configure variables (replace *{{my-S3-BUCKET}}* with the storage url to fetch packages, *{{my-CustomerId}}* and *{{my-SaaSAnalysisServerHost}}* with your APM informations)
3. Execute the script with PowerShell (run as admin)

## It is ready! 

You can now start instrumenting the app. Please visit [Aternity](https://www.aternity.com/) if your need Support or Training.

#### License

Copyright (c) 2022 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
