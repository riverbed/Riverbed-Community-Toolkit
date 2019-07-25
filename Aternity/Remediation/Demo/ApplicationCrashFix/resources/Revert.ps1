#requires -runasadministrator
$installDir = "C:\Program Files\FinApp2"
$tempDir = "$installDir\temp"
$glPath = "$installDir\temp\GeneralLedger.csv" 

$acl = Get-Acl $tempDir
$rules = $acl.Access 
$rule = $rules | Where-Object { ($_.IdentityReference -eq "BUILTIN\Users") -and ($_.FileSystemRights -eq "FullControl") }
$acl.RemoveAccessRule($rule)
$acl | Set-Acl -Path $tempDir