$GREEN = "`e[32m"
$RESET = "`e[0m"

<#
.SYNOPSIS
Compress jpeg image files with metadata stripped and quality drop to 85%.
#>
function Compress-Image {

    [CmdletBinding()]
    param (
        # Whether to operate recursively.
        [switch] $Recurse
    )
    Detect-Magick

    if ($Recurse) {
        (Get-ChildItem -Directory).ForEach({
            Set-Location -LiteralPath $_.Name
            Compress-Image -Recurse
            Set-Location ..
        })
    }

    (Get-ChildItem -Filter *.jpeg).ForEach({ Rename-Item $_.Name ($_.Name -replace '.jpeg', '.jpg') })
    $Targets = Get-ChildItem -Filter *.jpg
    if (-not $Targets) { return }
    $Targets.ForEach({ $_.IsReadOnly = $false })

    $TotalSizeBefore = ($Targets | Measure-Object -Property Length -Sum).Sum
    $TotalSizeString = Format-ByteSize $TotalSizeBefore
    Write-Host (
        "Going to compress [$GREEN$($Targets.Count)$RESET] images," +
        " with the total size of [$GREEN$TotalSizeString$RESET].")

    magick mogrify -monitor -strip -quality 85% *.jpg

    $Targets = Get-ChildItem -Filter *.jpg
    $TotalSizeAfter = ($Targets | Measure-Object -Property Length -Sum).Sum
    $TotalSizeString = Format-ByteSize $TotalSizeAfter
    $Ratio = "{0:P}" -f ($TotalSizeAfter / $TotalSizeBefore)
    Write-Host (
        "Compression of [$GREEN$($Targets.Count)$RESET] images finished," +
        " with the total size of [$GREEN$TotalSizeString$RESET] at compression ratio of [$GREEN$Ratio$RESET].")
}
Export-ModuleMember -Function Compress-Image

<#
.SYNOPSIS
Convert all images into jpg format, currently support format:
    - jpeg (rename only)
    - png
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

    Get-ChildItem -Filter *.jpeg | Rename-Item -NewName { $_.Name -replace '.jpeg', '.jpg' }

    $targets = Get-ChildItem -Filter *.png
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
    Write-Error (
        'ImageMagick is not installed, please install it first.' +
        ' Link at https://imagemagick.org/script/download.php')
    Exit
}
