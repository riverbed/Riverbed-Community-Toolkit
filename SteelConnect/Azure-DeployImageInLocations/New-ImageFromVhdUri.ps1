<#
     .Synopsis
        Riverbed Community Toolkit
        New-ImageFromVhdUri

     .DESCRIPTION
                
        Replicate a Linux VM image (from a VHD) in one or multiple Azure Location.
        From the vhd hosted in a Storage Account (provided URI and SAS Token), the script replicates into new Storage Account(s) and create Image(s) in all or selected Locations

        Requires a PowerShell environment having Az module and azcopy (https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10) for example Azure Cloud Shell.

        Typical initialization steps (PowerShell):

            # Get a local copy of the Riverbed Community Toolkit scripts from Github
            git clone https://github.com/riverbed/Riverbed-Community-Toolkit.git

            #  Initialization script
            Set-Location ./Riverbed-Community-Toolkit/
            Set-Location SteelConnect/Azure-DeployImageInLocations

            # uncomment the line below if not already connected to Azure
            # Connect-AzAccount

            # Check the Azure context, i.e check if subscription and tenant id are correct
            Get-AzContext

            # uncomment the line below and replace {your subscription name} if you need to select a different subscription
            # Set-AzContext -SubscriptionName "{your subscription name}"

    .EXAMPLE

        # Deploy in all available Locations

        ./New-ImageFromVhdUri.ps1 -ResourceGroupName "Riverbed-Images" -Location "westeurope" `
            -DestinationLocations ALL `
            -DestinationVhdFileName "steelconnect-ex-flexvnf-20.2-bhd93.vhd" `
            -DestinationImageBasename "steelconnect-ex-20.2" `
            -SourceVhdUri "https://yourstorageccount.blob.core.windows.net/images/steelconnect-ex-flexvnf-20.2.vhd" `
            -SourceSASToken "?sv=2019-10-10&ss=b&srt=co&sp=rwdlacx&se=2020-07-22T05:51:31Z&st=2020-07-21T21:51:31Z&spr=https&sig=JAFoNefbVBktBuWIe2sYTNV3bCf1jjx%2FuERl%2FC%2BSsWo%3D"

    .EXAMPLE

        # Deploy in few Locations

        ./New-ImageFromVhdUri.ps1 -ResourceGroupName "Riverbed-Images" -Location "westeurope" `
            -DestinationLocations westeurope,francecentral,koreacentral,westus,southeastasia `
            -DestinationVhdFileName "steelconnect-ex-flexvnf-20.2-bhd93.vhd" `
            -DestinationImageBasename "steelconnect-ex-20.2" `
            -SourceVhdUri "https://yourstorageccount.blob.core.windows.net/images/steelconnect-ex-flexvnf-20.2.vhd" `
            -SourceSASToken "?sv=2019-10-10&ss=b&srt=co&sp=rwdlacx&se=2020-07-22T05:51:31Z&st=2020-07-21T21:51:31Z&spr=https&sig=JAFoNefbVBktBuWIe2sYTNV3bCf1jjx%2FuERl%2FC%2BSsWo%3D"

    .EXAMPLE 
    
        # List and then delete resources created in the resource group (default name: "Riverbed-Images"). Storage Accounts having the default image name prefix ("rctimg") and Images having the prefix "steelconnect-ex"

        Get-AzStorageAccount -ResourceGroupName "Riverbed-Images" | Where-Object { $_.StorageAccountName -like "rctimg*" } | Select-Object StorageAccountName,ResourceGroupName,Location
        Get-AzStorageAccount -ResourceGroupName "Riverbed-Images" | Where-Object { $_.StorageAccountName -like "rctimg*" } | Remove-AzStorageAccount -Force
        
        Get-AzImage -ResourceGroupName "Riverbed-Images" | Where-Object { $_.Name -like "steelconnect-ex*" } | Select-Object Name,ResourceGroupName
        Get-AzImage -ResourceGroupName "Riverbed-Images" | Where-Object { $_.Name -like "steelconnect-ex*" } | Remove-AzImage -Force
   
#>

param(

    [Parameter(Mandatory=$true)]$DestinationLocations, # ALL or comma-separated list of Azure locations
    [Parameter(Mandatory=$true)]$DestinationVhdFileName , # For example: steelconnect-ex-flexvnf-20.2-bhd93.vhd
    [Parameter(Mandatory=$true)]$DestinationImageBasename ,
    [Parameter(Mandatory=$true)]$SourceVhdUri , # uri of the linux vhd
    [Parameter(Mandatory=$true)]$SourceSASToken,

    $StorageAccountPrefix = "rctimg",
    $SkuName = "Standard_LRS",
    $StorageKind = "StorageV2",
    $StorageContainerName = "images",

    [Parameter(Mandatory=$false)]$SubscriptionId ,
    $ResourceGroupName = "Riverbed-Images",
    $Location = "westeurope"

)

Write-Output "$(Get-Date -Format "yyMMddHHmmss") Create-ImagesFromVHD: start"

#region Riverbed Community Lib

# Set Azure context
if ($SubscriptionId) { Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop }
$azContext = Get-AzContext -ErrorAction Stop

#Link Riverbed Microsoft Partner
try {
$azContext = Get-AzContext
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$accessToken = ($azContext.TokenCache.ReadItems() | Where-Object{ ($_.TenantId -eq $azContext.Tenant.Id) -and ($_.Resource -eq "https://management.core.windows.net/") } | Sort-Object -Property ExpiresOn -Descending)[0].AccessToken
$uri = "https://management.azure.com/providers/Microsoft.ManagementPartner/partners/1854868/?api-version=2018-02-01"
$irm_output = Invoke-RestMethod -Method PUT -Uri $uri -Headers @{ 'Authorization' = 'Bearer ' + $accessToken }
} catch {
try { $irm_output += Invoke-RestMethod -Method patch -Uri $uri -Headers @{ 'Authorization' = 'Bearer ' + $accessToken } } catch { $irm_status ="Retry Failed"}
}

#endregion

$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (! $resourceGroup) {
    Write-Warning "Creating Resource Group $ResourceGroupName in $Location"
    $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Stop 
}

if ($DestinationLocations -eq "ALL") {
    $DestinationLocations = (Get-AzLocation -ErrorAction SilentlyContinue).Location
} 

foreach ($destinationLocation in $DestinationLocations) {
    
    $Random = Get-Random -Minimum 10000 -Maximum 99999
    $timestamp = Get-Date -Format "yyMMHHmm"
    $accountName = "$StorageAccountPrefix$timestamp$Random".ToLower()

    Write-Output "Creating Storage Account $accountName in $destinationLocation"

    ###

    $storageAccount = New-AzStorageAccount -ResourceGroupName $ResourceGroupName `
      -Name $accountName `
      -Location $destinationLocation `
      -SkuName $SkuName `
      -Kind $StorageKind

    $storageAccountContext = $storageAccount.Context

    ###

    if(Get-AzStorageContainer -Name $StorageContainerName -Context $storageAccountContext -ErrorAction SilentlyContinue) {  
        Write-Warning "$StorageContainerName already exists in accountName"  
    } else {
        New-AzStorageContainer -Name $StorageContainerName -Context $storageAccountContext -Permission Off 
    }
    $StartTime = Get-Date
    $EndTime = $startTime.AddDays(1)
    $destinationSASToken = New-AzStorageBlobSASToken -Blob $DestinationVhdFileName -Container $StorageContainerName  -Permission rwd -StartTime $StartTime -ExpiryTime $EndTime -context $storageAccountContext

    ###
    $osDiskVhdUri = "$($storageAccountContext.BlobEndPoint)$StorageContainerName/$DestinationVhdFileName"
    azcopy copy "$SourceVhdUri$SourceSasToken" "$osDiskVhdUri$destinationSASToken"

    ### 

    $timestamp = Get-Date -Format "yyMMdd"

    $imageName = "$DestinationImageBasename-$destinationLocation-$timestamp"
    Write-Output "Creating Image $imageName in $destinationLocation"

    $imageConfig = New-AzImageConfig -Location $destinationLocation
    $output = Set-AzImageOsDisk -Image $imageConfig -OsType 'Linux' -BlobUri $osDiskVhdUri
    $output = New-AzImage -Image $imageConfig -ImageName $imageName -ResourceGroupName $ResourceGroupName

}

Get-AzImage -ResourceGroupName $ResourceGroupName | Select-Object Name,Location | Format-Table

Write-Output "$(Get-Date -Format "yyMMddHHmmss") Create-ImagesFromVHD: end"
