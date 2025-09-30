# 200-instrument-dotnet-app-on-windows

This cookbook sets up a simple environment with [Riverbed APM](https://www.riverbed.com/products/application-performance-monitoring/) instrumenting a dotnet web application on a Windows Server. 

## Prerequisites

1. a valid **Riverbed APM account**
2. a **Windows Server** virtual machine ready to use, for example a Windows Server 2019 instance in the Cloud (AWS, Azure,...)

## Step 1. Install Riverbed APM

Navigate to the APM web console and from the menu go to AGENTS > Install Agents. Copy the **Unattended Agent Installation** script for Windows.

Then on the Windows Server, open a Terminal with PowerShell. Paste the script and run it to start the installation. 

1. Log in to the **Riverbed APM** web console

2. Navigate to **AGENTS > Install Agents** and click on **Windows tab**

3. Copy the **Unattended Agent Installation script** for Windows

4. On your Windows Server, open **PowerShell**

5. Paste and run the script to begin installation

> Installation typically completes within seconds.

## Step 2. Install a dotnet SDK

1. Visit the [.NET download page](https://dotnet.microsoft.com/download/dotnet) 

2. Download and install the appropriate .NET SDK. For example:

* **.NET 7.0** version [sdk-7.0.410-windows-x64-installer](https://dotnet.microsoft.com/en-us/download/dotnet/7.0)
* **.NET Core 3.1** version [sdk-3.1.426-windows-x64-installer](https://dotnet.microsoft.com/en-us/download/dotnet/3.1)


> [!Note]
> Ensure your selected SDK version is supported. Check [Riverbed APM supported platforms](https://help.aternity.com/bundle/release_news_apm_agent_console_apm/page/console/topics/apm_supported_platforms.html)

## Step 3. Create a Wep Application

On your Windows Server, run the following commands in PowerShell:

```powershell
New-Item -type directory -Path C:\app
Set-Location C:\app
dotnet new web -n YourApp
Set-Location C:\app\YourApp
dotnet run
```

## Step 4. Navigate the app

Browse the application, for example open your browser and navigate to:

```shell
http://localhost:5000
```

## Step 5. Instrument the app with Riverbed APM

1. In the APM web console, go to AGENTS > Agent List

2. Select the agent corresponding to your server

3. Choose your application (e.g. YourApp)

4. Configure and enable both **Instrument** and **Harvest**

5. Restart the application

> After restarting the application, Riverbed APM will being collecting all transactions.

For support please visit [Riverbed Support](https://support.riverbed.com/)

#### License

Copyright (c) 2022 - 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
