#Requires -RunAsAdministrator

$RED = "`e[31m"
$RESET = "`e[0m"

<#
.SYNOPSIS
Remove all registry content under given path.
#>
function Remove-Registry {

    [CmdletBinding()]
    param (
        # The target registry path to delete.
        [string] $Path
    )

    # In Windows Registry, only HKCU and HKLM are build-in PSDrives.
    # Can be confirmed with: `Get-PSDrive -PSProvider Registry`.
    if ($Path.StartsWith('HKCR:')) {
        $Path = $Path -replace 'HKCR:', 'Registry::HKCR'
    }

    if (-not(Test-Path -LiteralPath $Path)) {
        Write-Verbose "Given path [$RED$Path$RESET] doesn't exist, skipping..."
        return
    }

    Write-Host "Path [$RED$Path$RESET] detected, going to remove..."
    Remove-Item -LiteralPath $Path -Recurse
    Write-Host "Path [$RED$Path$RESET] removed."
}
Export-ModuleMember -Function Remove-Registry
