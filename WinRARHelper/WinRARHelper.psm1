<#
.SYNOPSIS
Archive update using WinRAR.
WinRAR reference as here: https://documentation.help/WinRAR/
#>
function Archive-Update {

    [CmdletBinding()]
    param (
        # Whether to put each file to separate archive.
        [switch] $Separate
    )
    Detect-WinRAR

    $Password = Get-Content '~/OneDrive/Collections/AppBackup/WinRAR/An1.txt'

    if ($Separate) {
        Get-ChildItem -File | ForEach-Object {
            $Archive = (Split-Path -LeafBase $_.Name) + '.rar'
            rar m "-hp$Password" -s -v1g $Archive $_.Name
        }
    } else {
        $Archive = (Split-Path -Leaf $PWD) + '.rar'
        rar m "-hp$Password" -s -v1g $Archive './'
    }
}
Export-ModuleMember -Function Archive-Update

function Detect-WinRAR {
    if (Get-Command 'rar' -ErrorAction SilentlyContinue) { Return }
    Write-Error 'WinRAR is not installed, please install it first.' `
        + 'Link at https://www.win-rar.com/download.html'
    Exit
}
