#requires -RunAsAdministrator
<#
    101-instrument-dotnet-app-on-windows

   Step by step setup
    - Following variables must be configured: $ATERNITY_APM_CUSTOMER_ID, $ATERNITY_APM_SAAS_ANALYSIS_SERVER_HOST, $DOTNET_SDK_URL and $ATERNITY_APM_AGENT_URL
    - Requires Administrator privileges
   
   Note: Tested on Windows Server 2019 instance in AWS

#>

# Step 1. Prepare the node environment

New-Item -type directory -Path C:\Packages
New-Item -type directory -Path C:\Logs

# Step 2. Install dotnet SDK 3.1 prereqs for the app (https://dotnet.microsoft.com/download/dotnet/3.1)

## Customize variable
$DOTNET_SDK_URL="https://{{my-S3-BUCKET}}/dotnet-sdk-3.1.415-win-x64.exe" # e.g. "https://mydemobucket.s3.eu-central-1.amazonaws.com/dotnet-sdk-3.1.415-win-x64.exe"

## Copy installer into  C:\Packages\dotnet_sdk.exe
Start-BitsTransfer "$DOTNET_SDK_URL" -Destination C:\Packages\dotnet_sdk.exe
Start-Process -Wait -FilePath C:\Packages\dotnet_sdk.exe -ArgumentList "/install /quiet /log C:\Logs\dotnet_sdk.log"

# Step 3. Install the dotnet App

New-Item -type directory -Path C:\src
Set-Location C:\src
dotnet new webapp -n YourApp
Set-Location C:\src\YourApp
dotnet run

## at that point the application should be running on https://localhost:5001/ and you can connect to it from the local browser

# Step 4. Install the Aternity APM agent

## Customize Aternity APM variables
$ATERNITY_APM_CUSTOMER_ID="{{my-CustomerId}}"  # e.g. "12341234-12341234-13241234"
$ATERNITY_APM_SAAS_ANALYSIS_SERVER_HOST="{{my-SaaSAnalysisServerHost}}"  # e.g. "agents.apm.myaccount.aternity.com"
$ATERNITY_APM_AGENT_URL = "https://{{my-S3-BUCKET}}/AppInternals_Agent_12.1.0.597_Win.exe"  # e.g. "https://mydemobucket.s3.eu-central-1.amazonaws.com/AppInternals_Agent_12.1.0.597_Win.exe"

## Copy installer into  C:\Packages\Aternity-AppInternals_Agent.exe
Start-BitsTransfer $ATERNITY_APM_AGENT_URL -Destination C:\Packages\Aternity-AppInternals_Agent.exe
Start-Process -Wait -FilePath C:\Packages\Aternity-AppInternals_Agent.exe "/s /v`"O_SI_CUSTOMER_ID=$ATERNITY_APM_CUSTOMER_ID O_SI_SAAS_ANALYSIS_SERVER_HOST=$ATERNITY_APM_SAAS_ANALYSIS_SERVER_HOST O_SI_SAAS_ANALYSIS_SERVER_ENABLED=true O_SI_AUTO_INSTRUMENT=true /L*v c:\Logs\Aternity-APM-InstallLog.log /qn`"

## at that point the Aternity APM agent should be running
