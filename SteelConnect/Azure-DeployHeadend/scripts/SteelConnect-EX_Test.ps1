

$timestamp = Get-Date -Format "HHmm"
$resourceGroupName = "SCHE$timestamp"
..\..\Azure-DeployHeadend\scripts\SteelConnect-EX_Stage-DefaultHeadhendStandalone.ps1 -resourceGroupName $resourceGroupName 
..\..\Azure-DeployHeadend\scripts\SteelConnect-EX_Deploy-Terraform.ps1 -resourceGroupName $resourceGroupName 