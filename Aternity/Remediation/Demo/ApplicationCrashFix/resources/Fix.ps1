#requires -runasadministrator
$installDir = "C:\Program Files\FinApp2"
$tempDir = "$installDir\temp"
$glPath = "$installDir\temp\GeneralLedger.csv" 

$acl = Get-Acl $tempDir
$permissions = "BUILTIN\Users", "FullControl", "Containerinherit, ObjectInherit", "None", "Allow"
$rule = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $permissions
$acl.SetAccessRule($rule)
$acl | Set-Acl -Path $tempDir