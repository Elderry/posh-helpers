#Requires -RunAsAdministrator

<#
.SYNOPSIS
Clean unnecessary configurations of QQ Music.
#>
function Clean-QQMusic {

    [CmdletBinding()]
    param()

    # Right click -> Play as
    Remove-Registry 'HKCR:\Directory\shell\QQMusic.1.Play'
    Remove-Registry 'HKCR:\Directory\shell\QQMusic.2.Add'

    # Options of open with
    Remove-Registry 'HKCR:\QQMusic.*'
}
Export-ModuleMember -Function Clean-QQMusic
