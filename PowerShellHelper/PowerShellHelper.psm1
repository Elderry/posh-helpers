$RED = "`e[31m"
$RESET = "`e[0m"

<#
.SYNOPSIS
Initialize personal configuration for PowerShell Core.
#>
function Initialize-PowerShell {

    [CmdletBinding()]
    param()

    Confirm-Module posh-git
    Confirm-Module zLocation

    $ProfileDir = '~/Documents/PowerShell'
    if (!(Test-Path $ProfileDir)) { New-Item -ItemType 'Directory' $ProfileDir }

    $ProfileName = 'Microsoft.PowerShell_profile.ps1'
    Copy-Item "$PSScriptRoot/$ProfileName" "$ProfileDir/$ProfileName"
}
Export-ModuleMember -Function Initialize-PowerShell

function Confirm-Module {

    [CmdletBinding()]
    param([string] $Name)

    if (!(Get-Module -ListAvailable -Name $Name)) {
        Write-Host "Module [$RED$Name$RESET] is missing, installing..."
        Install-Module $Name -Force
        Write-Host "Module [$RED$Name$RESET] is installed."
    }
}
