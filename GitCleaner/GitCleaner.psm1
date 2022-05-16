#Requires -RunAsAdministrator

<#
.SYNOPSIS
Clean unnecessary configurations of Git.
#>
function Clean-Git {

    [CmdletBinding()]
    param()

    # Git GUI & Git Bash
    Remove-Registry 'HKCR:\Directory\Background\shell\git_gui'
    Remove-Registry 'HKCR:\Directory\Background\shell\git_shell'
    Remove-Registry 'HKCR:\Directory\shell\git_gui'
    Remove-Registry 'HKCR:\Directory\shell\git_shell'
    Remove-Registry 'HKCU:\Console\Git Bash'
    Remove-Registry 'HKCU:\Console\Git CMD'
    Remove-Registry 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\git_gui'
    Remove-Registry 'HKLM:\SOFTWARE\Classes\Directory\Background\shell\git_shell'
    Remove-Registry 'HKLM:\SOFTWARE\Classes\Directory\shell\git_gui'
    Remove-Registry 'HKLM:\SOFTWARE\Classes\Directory\shell\git_shell'
}
Export-ModuleMember -Function Clean-Git
