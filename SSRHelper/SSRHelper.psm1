#Requires -RunAsAdministrator

$RED = "`e[31m"
$RESET = "`e[0m"

$ClientList = (
    "Microsoft.GamingApp", # Xbox
    "Microsoft.Todos",
    "Microsoft.WindowsStore",
    "MSNChina.Win10" # Microsoft Bing Dictionary
)

<#
.SYNOPSIS
Enable selected UWP for client outbound connections.
#>
function Set-NetIsolation {

    [CmdletBinding()]
    param ()

    Write-Host 'Clear the list of loopback exempted AppContainers and Package Families.'
    CheckNetIsolation LoopbackExempt -c | Out-Null

    Get-AppxPackage | ForEach-Object {
        if ($ClientList -contains $_.Name) {
            CheckNetIsolation LoopbackExempt -a -n="$($_.PackageFamilyName)" | Out-Null
            Write-Host "Added package [$RED$($_.Name)$RESET] to the loopback exempted list."
        }
    }

    Write-Host "Finished adding packages to the loopback exempted list, you can use this command to look for other candidates:"
    Write-Host "Get-AppxPackage | Format-Wide -AutoSize -Property 'Name'"
}
Export-ModuleMember -Function Set-NetIsolation
