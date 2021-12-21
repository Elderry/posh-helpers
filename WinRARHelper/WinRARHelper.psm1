<#
.SYNOPSIS
Archive update using WinRAR.
WinRAR reference as here: https://documentation.help/WinRAR/
#>
function Archive-Update {

    [CmdletBinding()]
    param (
        # Whether to put each file and directory to separate archive.
        [switch] $Separate,
        # Whether to create archive under each directory.
        [switch] $SeparateFolder
    )
    Test-WinRAR

    $Password = Get-Content '~/OneDrive/Collections/AppBackup/WinRAR/An1.txt'

    if ($Separate) {
        Get-ChildItem -File | ForEach-Object {
            $Archive = (Split-Path -LeafBase $_.Name) + '.rar'
            rar m "-hp$Password" -s -v1g $Archive $_.Name
        }
        Get-ChildItem -Directory | ForEach-Object {
            $Archive = $_.Name + '.rar'
            rar m "-hp$Password" -s -v1g $Archive $_.Name
        }
        return
    }

    if ($SeparateFolder) {
        Get-ChildItem -Directory | ForEach-Object {
            Set-Location -LiteralPath $_.Name
            Archive-Update
            Set-Location ..
        }
        return
    }

    $Archive = (Split-Path -Leaf $PWD) + '.rar'
    rar m "-hp$Password" -r -s -v1g $Archive './'
}
Export-ModuleMember -Function Archive-Update

function Test-WinRAR {
    if (Get-Command 'rar' -ErrorAction SilentlyContinue) { Return }
    Write-Error 'WinRAR is not installed, please install it first.' `
        + 'Link at https://www.win-rar.com/download.html'
    Exit
}
