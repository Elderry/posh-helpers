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
        [switch] $Recurse,
        # Whether to bypass prompt, default is $false, override to $true if $Recurse is set.
        [alias('y')]
        [switch] $BypassPrompt
    )
    Test-Magick

    if ($Recurse) {
        (Get-ChildItem -Directory).ForEach({
            Set-Location -LiteralPath $_.Name
            Compress-Image -Recurse -BypassPrompt
            Set-Location ..
        })
    }

    (Get-ChildItem -Filter *.jpeg).ForEach({ Rename-Item $_.Name ($_.Name -replace '.jpeg', '.jpg') })
    $Targets = Get-ChildItem -Filter *.jpg
    if (!$Targets) { return }
    $Targets.ForEach({ $_.IsReadOnly = $false })

    $SizeBefore = ($Targets | Measure-Object -Property Length -Sum).Sum
    $SizeBeforeString = Format-ByteSize $SizeBefore
    Write-Host (
        "Going to compress [$GREEN$($Targets.Count)$RESET] images," +
        " with the total size of [$GREEN$SizeBeforeString$RESET].")

    $BypassPrompt = $BypassPrompt -or $Recurse
    if (!$BypassPrompt) {
        $Question = 'Are you sure you want to proceed?'
        $Choices = '&Yes', '&No'
        $Decision = $Host.UI.PromptForChoice('', $Question, $Choices, 1)
        if ($Decision -ne 0) {
            return
        }
    }

    magick mogrify -monitor -strip -quality 85% *.jpg

    $Targets = Get-ChildItem -Filter *.jpg
    $SizeAfter = ($Targets | Measure-Object -Property Length -Sum).Sum
    $SizeAfterString = Format-ByteSize $SizeAfter
    $Ratio = "{0:P}" -f ($SizeAfter / $SizeBefore)
    Write-Host (
        "`nCompression of [$GREEN$($Targets.Count)$RESET] images finished`n" +
        "Total size before: [$GREEN$SizeBeforeString$RESET]`n" +
        "Total size after: [$GREEN$SizeAfterString$RESET]`n" +
        "Compression ratio: [$GREEN$Ratio$RESET]")
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
    Test-Magick

    if ($Recurse) {
        (Get-ChildItem -Directory).ForEach({
            Set-Location -LiteralPath $_.Name
            Convert-Image -Recurse
            Set-Location ..
        })
    }

    Get-ChildItem -Filter *.jpeg | Rename-Item -NewName { $_.Name -replace '.jpeg', '.jpg' }

    $targets = Get-ChildItem -Filter *.png
    if (!$targets) { return }
    $targets | ForEach-Object { $_.IsReadOnly = $false }

    if (Get-ChildItem -Filter *.png) {
        magick mogrify -monitor -format jpg *.png
    }
    Remove-Item *.png
}
Export-ModuleMember -Function Convert-Image

function Test-Magick {
    if (Get-Command magick -ErrorAction SilentlyContinue) { return }
    Write-Error (
        'ImageMagick is not installed, please install it first.' +
        ' Link at https://imagemagick.org/script/download.php')
    exit
}
