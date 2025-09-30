# 200-instrument-dotnet-app-on-windows

This cookbook sets up a simple environment with [Riverbed APM](https://www.riverbed.com/products/application-performance-monitoring/) instrumentating a dotnet web application on a Windows Server. 

## Prerequisites

1. a Riverbed APM account
2. a Windows Server virtual machine ready to use, for example a Windows Server 2019 instance in the Cloud (AWS, Azure,...)

## Step 1. Install Riverbed APM

Navigate to the APM web console and go to APM > Agents > Install Agents. Copy the **Unattended Agent Installation** script for Windows.

Then on the Windows Server, open a Terminal with PowerShell. Paste the script and run it to start the installation. 

The installation would take few seconds.

## Step 2. Install a dotnet SDK

Download the installer for your .NET SDK. 
For example, go to [dotnet website](https://dotnet.microsoft.com/download/dotnet/3.1) and get the installer for .NET Core 3.1 (*sdk-3.1.426-windows-x64-installer*)

> [!Note]
> Check [Riverbed APM supported platforms](https://help.aternity.com/bundle/release_news_apm_agent_console_apm/page/console/topics/apm_supported_platforms.html)

## Step 3. Create a new app

```powershell
New-Item -type directory -Path C:\app
Set-Location C:\app
dotnet new webapp -n YourApp
Set-Location C:\app\YourApp
dotnet run
```


You can now start instrumenting the app. For support please visit [Riverbed Support](https://support.riverbed.com/)

#### License

Copyright (c) 2022 - 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
