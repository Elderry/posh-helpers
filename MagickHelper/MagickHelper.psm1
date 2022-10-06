$RED = "`e[31m"
$GREEN = "`e[32m"
$BLUE = "`e[34m"
$RESET = "`e[0m"

<#
.SYNOPSIS
Compress jpeg image files with metadata stripped and quality drop to 85%.
#>
function Compress-Image {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    param (
        # Whether to operate recursively.
        [switch] $Recurse,
        # Whether to bypass prompt, default is $false, override to $true if $Recurse is set.
        [alias('f')]
        [switch] $Force,
        # Whether to limit image size to 4K scale.
        [switch] $LimitSize
    )
    if (!(Test-Magick)) { return }
    if ($Force) { $ConfirmPreference = 'None' }

    if ($Recurse) {
        (Get-ChildItem -Directory).ForEach({
            Set-Location -LiteralPath $_.Name
            Compress-Image -Recurse -Force:$Force -LimitSize:$LimitSize
            Set-Location ..
        })
    }

    (Get-ChildItem -Filter *.jpeg).ForEach({ Rename-Item $_.Name ($_.Name -replace '.jpeg', '.jpg') })
    $Targets = Get-ChildItem -Filter *.jpg
    if (!$Targets) { return }
    $Targets.ForEach({ $_.IsReadOnly = $false })

    $SizeBefore = ($Targets | Measure-Object -Property Length -Sum).Sum
    $SizeBeforeString = Format-ByteSize $SizeBefore
    $CurrentDirectory = (Get-Item -LiteralPath (Get-Location).Path).Name
    Write-Host (
        "Going to compress [$GREEN$($Targets.Count)$RESET] images in folder [$BLUE$CurrentDirectory$RESET]," +
        " with the total size of [$GREEN$SizeBeforeString$RESET].")
    if (!$PSCmdlet.ShouldProcess($CurrentDirectory)) { return }

    $Options = '-monitor -strip -quality 85%'
    if (!$LimitSize) {
        $SamplePath = $Targets[0].FullName
        $SampleWidth = (magick identify -format '%w' $SamplePath) -as [int]
        $SampleHeight = (magick identify -format '%h' $SamplePath) -as [int]
        if (($SampleWidth -ge 4000) -or ($SampleHeight -ge 4000)) {
            $ConfirmMessage = "Sample dimension is [$RED${SampleWidth}x${SampleHeight}$RESET], it is suggested to limit compression size."
            if ($PSCmdlet.ShouldProcess('Compress-Image -LimitSize', $ConfirmMessage, $CurrentDirectory))
                { $LimitSize = $true }
        }
    }
    if ($LimitSize) { $Options += ' -resize 3840x3840' }

    Invoke-Expression "magick mogrify $Options *.jpg"

    $Targets = Get-ChildItem -Filter *.jpg
    $SizeAfter = ($Targets | Measure-Object -Property Length -Sum).Sum
    $SizeAfterString = Format-ByteSize $SizeAfter
    $Ratio = "{0:P}" -f ($SizeAfter / $SizeBefore)
    Write-Host (
        "`nCompression of [$GREEN$($Targets.Count)$RESET] images in folder [$BLUE$CurrentDirectory$RESET] finished`n" +
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
    if (!(Test-Magick)) { return }

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

function Select-ImageDirectoriesWithTopSize {

    [CmdletBinding()]
    param ([int] $Top = 10)

    Get-ChildItem -Directory |
        ForEach-Object {
            $AllFiles = Get-ChildItem $_.Name -File -Recurse
            $TotalSize = ($AllFiles | Measure-Object -Property Length -Sum).Sum
            $AverageSize = $TotalSize / $AllFiles.Length
            $SamplePath = $AllFiles[0].FullName
            return [PSCustomObject] @{
                Name = $_.Name
                TotalSize = $TotalSize
                AverageSize = $AverageSize
                SamplePath = $SamplePath
            }
        } |
        Sort-Object -Descending -Property TotalSize -Top $Top |
        ForEach-Object {
            return [PSCustomObject] @{
                Name = $_.Name
                TotalSize = Format-ByteSize $_.TotalSize
                AverageSize = Format-ByteSize $_.AverageSize
                SampleDimension = magick identify -format '%wx%h' $_.SamplePath
            }
        }
}
Export-ModuleMember -Function Select-ImageDirectoriesWithTopSize

function Test-Magick {
    if (Get-Command magick -ErrorAction SilentlyContinue) { return $true }
    Write-Error (
        'ImageMagick is not installed, please install it first.' +
        ' Link at https://imagemagick.org/script/download.php')
}
