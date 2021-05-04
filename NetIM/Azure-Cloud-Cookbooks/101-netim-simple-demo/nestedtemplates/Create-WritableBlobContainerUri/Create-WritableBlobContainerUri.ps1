param(
    [string] $StorageAccountName,
    [string] $BlobContainerName,
    [int] $SasTokenDuration = 4
)

##### Parameters

$StorageAccountName
$BlobContainerName
$SasTokenDuration
$ResourceGroupName = ${Env:ResourceGroupName}

##### Variables

$StartTime = Get-Date
$EndTime = $startTime.AddHours($SasTokenDuration)

##### Storage account

$StorageAccount = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
$uriWritableStorageAccountBlobContainerSasToken = New-AzStorageContainerSASToken -FullUri -Name $BlobContainerName -context $StorageAccount.Context  -Permission rawcl  -StartTime $StartTime -ExpiryTime $EndTime

##### Output
$DeploymentScriptOutputs = @{}
$DeploymentScriptOutputs['uriWritableStorageAccountBlobContainerSasToken'] = $uriWritableStorageAccountBlobContainerSasToken