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

## Step 2. Install the .NET SDK

1. Visit the [.NET download page](https://dotnet.microsoft.com/download/dotnet) 

2. Download and install the appropriate .NET SDK and runtimes.

For example:

* **.NET 8.0** version [sdk-8.0.414-windows-x64-installer](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
* **.NET 7.0** version [sdk-7.0.410-windows-x64-installer](https://dotnet.microsoft.com/en-us/download/dotnet/7.0)
* **.NET Core 3.1** version [sdk-3.1.426-windows-x64-installer](https://dotnet.microsoft.com/en-us/download/dotnet/3.1)

> [!Note]
> Ensure the runtime version for the application is supported, check [Riverbed APM supported platforms](https://help.aternity.com/bundle/release_news_apm_agent_console_apm/page/console/topics/apm_supported_platforms.html)



## Step 3. Create a Web Application

On your Windows Server, follow the instructions for one of the app example below.

<details>
  <summary>Simple YourApp Example</summary>

Run the following commands in PowerShell:

```powershell
New-Item -type directory -Path C:\src
Set-Location C:\src
dotnet new web --name YourApp

Set-Location C:\src\YourApp
dotnet run
```

</details>

<details>
  <summary>YourApp Example with specific .NET version</summary>

```powershell
New-Item -type directory -Path C:\src
Set-Location C:\src
dotnet new web --name YourApp8 --framework net8.0

Set-Location C:\src\YourApp8
dotnet run
```

</details>


<details>
  <summary>YourApp Example with specific .NET version and IIS hosting (in-process)</summary>

Run the following commands in PowerShell to generate the application:

```powershell
New-Item -type directory -Path C:\src
Set-Location C:\src
dotnet new web --name YourApp8IIS --framework net8.0
Set-Location C:\src\YourApp8IIS
```

In this folder, edit the project file `C:\src\YourApp8IIS\YourApp8IIS.csproj` and add the following inside the `PropertyGroup` XML element.

```xml
<AspNetCoreHostingModel>InProcess</AspNetCoreHostingModel>
```

Run the following command to build and publish the application inside the folder `c:\app`:

```PowerShell
dotnet publish --configuration Release --output c:\app\YourApp8IIS
```

In IIS, you can then add a new Site and configure. For example:

* Name: `YourApp8IIS`
* Folder: `c:\app\YourApp8IIS`
* Port: 5000

> [!Tip]
> The .NET Hosting Bundle is required for IIS hosting. If it is not already installed refer to the [.NET page](https://dotnet.microsoft.com/download/dotnet)

</details>


## Step 4. Access the application

Check the port of the application and open the URL. For example open a web-browser and navigate to:

```shell
http://localhost:5000
```

## Step 5. Instrument the app with Riverbed APM

1. In the APM web console, go to AGENTS > Agent List

2. Select the agent corresponding to your server

3. Choose your application (e.g. YourApp)

4. Configure and enable both **Instrument** and **Harvest**

5. Restart the application

> After restarting the application, Riverbed APM will be collecting all transactions.

For support please visit [Riverbed Support](https://support.riverbed.com/)

#### License

Copyright (c) 2022 - 2025 Riverbed Technology, Inc.

The contents provided here are licensed under the terms and conditions of the MIT License accompanying the software ("License"). The scripts are distributed "AS IS" as set forth in the License. The script also include certain third party code. All such third party code is also distributed "AS IS" and is licensed by the respective copyright holders under the applicable terms and conditions (including, without limitation, warranty and liability disclaimers) identified in the license notices accompanying the software.
