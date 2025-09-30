#requires -RunAsAdministrator
<#
   200-instrument-dotnet-app-on-windows

   Step by step setup
    - Requires Administrator privileges
   
   Note: Tested on Windows Server 2019 instance in AWS

#>

#TODO: Customize variable
$DOTNET_SDK_URL="https://{{my-S3-BUCKET}}/dotnet-sdk-3.1.415-win-x64.exe" # e.g. "https://mydemobucket.s3.eu-central-1.amazonaws.com/dotnet-sdk-3.1.415-win-x64.exe"



# Step 1. Prepare the node environment
New-Item -type directory -Path C:\Packages
New-Item -type directory -Path C:\Logs

# Step 2. Install dotnet SDK 3.1 prereqs for the app (https://dotnet.microsoft.com/download/dotnet/3.1)

## Copy installer into  C:\Packages\dotnet_sdk.exe
Start-BitsTransfer "$DOTNET_SDK_URL" -Destination C:\Packages\dotnet_sdk.exe
Start-Process -Wait -FilePath C:\Packages\dotnet_sdk.exe -ArgumentList "/install /quiet /log C:\Logs\dotnet_sdk.log"

# Step 3. Install the dotnet App

New-Item -type directory -Path C:\app
Set-Location C:\app
dotnet new webapp -n YourApp
Set-Location C:\app\YourApp
dotnet run

# at that point the application should be running and you can connect to it from the local browser:
# * http://localhost:5000/ 
# * https://localhost:5001/ 
