#Requires -RunAsAdministrator

$RED = "`e[31m"
$RESET = "`e[0m"

<#
.SYNOPSIS
Clean unnecessary configurations of Baidu Yun.
#>
function Clean-BaiduYun {

    [CmdletBinding()]
    param()

    # Right click -> Play as
    Remove-Registry 'HKCR:\*\shellex\ContextMenuHandlers\YunShellExt'
    Remove-Registry 'HKCR:\Directory\shellex\ContextMenuHandlers\YunShellExt'

    @(
        (Join-Path $Env:APPDATA 'baidu/BaiduNetdisk/YunOfficeAddin.dll'),
        (Join-Path $Env:APPDATA 'baidu/BaiduNetdisk/YunOfficeAddin64.dll')
    ) |
    Where-Object { Test-Path $_ } |
    ForEach-Object {
        Write-Host "Path [$RED$_$RESET] detected, going to remove..."
        Remove-Item -LiteralPath $_ -Recurse
        Write-Host "Path [$RED$_$RESET] removed."
    }
}
Export-ModuleMember -Function Clean-BaiduYun
