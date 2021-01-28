<#
.SYNOPSIS
Archive update using WinRAR.
WinRAR reference as here: https://documentation.help/WinRAR/
#>
function Archive-Update {

    [CmdletBinding()]
    param ()
    Detect-WinRAR

    $Archive = (Split-Path -Leaf $PWD) + '.rar'
    $PasswordFile = '~/OneDrive/Collections/AppBackup/WinRAR/An1.txt'
    Get-Content $PasswordFile | rar m -hp -s -v1g $Archive './'
}
Export-ModuleMember -Function Archive-Update

function Detect-WinRAR {
    if (Get-Command 'rar' -ErrorAction SilentlyContinue) { Return }
    Write-Error 'WinRAR is not installed, please install it first.' `
        + 'Link at https://www.win-rar.com/download.html'
    Exit
}
