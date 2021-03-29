<#
.SYNOPSIS
Install posh-helpers into current machine.
#>

$PS_MODULE_PATH = 'PSModulePath'
$USER = 'User'

$ModulePath = [Environment]::GetEnvironmentVariable($PS_MODULE_PATH, $USER)
if (${ModulePath}?.Contains($PSScriptRoot)) { return }

$ModulePath = "$ModulePath;$PSScriptRoot"
if ($ModulePath.StartsWith(';')) { $ModulePath = $ModulePath.Remove(0, 1); }

[Environment]::SetEnvironmentVariable($PS_MODULE_PATH, $ModulePath, $USER)
