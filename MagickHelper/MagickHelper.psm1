<#
.SYNOPSIS
Convert all images into jpg format, then compress them with metadata stripped and quality drop to 85%.
#>
function Compress-Image {

    [CmdletBinding()]
    param (
        # Whether to operate recursively.
        [switch] $Recurse
    )
    Detect-Magick

    if ($Recurse) {
        Get-ChildItem -Directory | ForEach-Object {
            Set-Location -LiteralPath $_.Name
            Compress-Image -Recurse
            Set-Location ..
        }
    }

    Get-ChildItem -Filter *.jpeg | Rename-Item -NewName { $_.Name -replace '.jpeg','.jpg' }
    $targets = Get-ChildItem -Filter *.jpg
    if (-not $targets) { return }
    $targets | ForEach-Object { $_.IsReadOnly = $false }

    magick mogrify -monitor -strip -quality 85% *.jpg
    Convert-Image
}
Export-ModuleMember -Function Compress-Image

<#
.SYNOPSIS
Convert all images into jpg format.
#>
function Convert-Image {

    [CmdletBinding()]
    param (
        # Whether to operate recursively.
        [switch] $Recurse
    )
    Detect-Magick

    if ($Recurse) {
        Get-ChildItem -Directory | ForEach-Object {
            Set-Location -LiteralPath $_.Name
            Convert-Image -Recurse
            Set-Location ..
        }
    }

    $targets = Get-ChildItem .\* -Include *.png
    if (-not $targets) { return }
    $targets | ForEach-Object { $_.IsReadOnly = $false }

    if (Get-ChildItem -Filter *.png) {
        magick mogrify -monitor -format jpg *.png
    }
    Remove-Item *.png
}
Export-ModuleMember -Function Convert-Image

function Detect-Magick {
    if (Get-Command magick -ErrorAction SilentlyContinue) { Return }
    Write-Error 'ImageMagick is not installed, please install it first.' `
        + 'Link at https://imagemagick.org/script/download.php'
    Exit
}
