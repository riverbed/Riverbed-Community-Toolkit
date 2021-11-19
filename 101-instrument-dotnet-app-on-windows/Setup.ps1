#requires -RunAsAdministrator
<#
    101-instrument-dotnet-app-on-windows

    Step by step setup
    - Tested on Windows Server 2019.
    - Must run with Administrator privilege
    - Need customization and replace {{my-CustomerId}}, {{my-SaaSAnalysisServerHost}} and optionaly {{my-S3-BUCKET}}

#>

# Step 1. Prepare the node

New-Item -type directory -Path C:\Packages
New-Item -type directory -Path C:\Logs


# Step 2. Prereqs Dotnet SDK 3.1 (https://dotnet.microsoft.com/download/dotnet/thank-you/sdk-3.1.415-windows-x64-installer)

## Copy installer into  C:\Packages\dotnet_sdk.exe
$DOTNET_SDK_URL="https://{{my-S3-BUCKET}}/dotnet-sdk-3.1.415-win-x64.exe" # e.g.  "mydemobucket.s3.eu-central-1.amazonaws.com/dotnet-sdk-3.1.415-win-x64.exe"
Start-BitsTransfer "$DOTNET_SDK_URL" -Destination C:\Packages\dotnet_sdk.exe

## Run the installer silently
C:\Packages\dotnet_sdk.exe /install /quiet /log C:\Logs\dotnet_sdk.log


# Step 3. App

dotnet new webapp -n YourApp
Set-Location C:\YourApp
dotnet run

# at that point the application should be running on https://localhost:5001/ and you can connect to it from the local browser


## Step 4. Aternity AppInternals Agent - DEM

# Customize
$O_SI_CUSTOMER_ID="{{my-CustomerId}}"  # e.g. 12341234-12341234-13241234
$O_SI_SAAS_ANALYSIS_SERVER_HOST="{{my-SaaSAnalysisServerHost}}"  # e.g.  agents.apm.myaccount.aternity.com

# Copy installer into  C:\Packages\Aternity-AppInternals_Agent.exe
$ATERNITY_AGENT_URL = "https://{{my-S3-BUCKET}}/AppInternals_Agent_12.1.0.597_Win.exe"  # e.g.  "mydemobucket.s3.eu-central-1.amazonaws.com/AppInternals_Agent_12.1.0.597_Win.exe"
Start-BitsTransfer $ATERNITY_AGENT_URL -Destination C:\Packages\Aternity-AppInternals_Agent.exe
C:\Packages\Aternity-AppInternals_Agent.exe /s /v"O_SI_CUSTOMER_ID=$O_SI_CUSTOMER_ID O_SI_SAAS_ANALYSIS_SERVER_HOST=$O_SI_SAAS_ANALYSIS_SERVER_HOST O_SI_SAAS_ANALYSIS_SERVER_ENABLED=true O_SI_AUTO_INSTRUMENT=true /L*v c:\Logs\Aternity-Agent-InstallLog.log /qn"

# at that point the Aternity APM agent should be running and can be tested with the following:
if (! (Get-Service AgentController).Status -eq 'Running') { Throw "Aternity Agent not running" }
