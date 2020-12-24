<#
.SYNOPSIS
Flatten all files under directories recursively into current directory.
#>
function Flatten-File {

    [CmdletBinding()]
    param (
        # Whether to operate recursively.
        [switch] $WithPrefix,
        # Whether to overwrite on existing file.
        [switch] $Force
    )

    Get-ChildItem -Recurse -File | ForEach-Object {

        if ($_.Directory.FullName -eq $PWD) { Return }

        $dest = if ($WithPrefix) {
            ($_.Directory.FullName -replace "$PWD\", '' | ForEach-Object { $_ -replace '\\', '_' }) + "_$($_.Name)"
        } else {
            "$PWD/$($_.Name)"
        }

        if (Test-Path -LiteralPath $dest) {
            if ($Force) { Remove-Item $dest }
            else {
                Write-Warning "File [$dest] already exists, skipping..."
                Return
            }
        }

        Move-Item -LiteralPath $_.FullName $dest
    }

    Get-ChildItem -Directory | ForEach-Object { Trim-Directory $_ }
}
Export-ModuleMember -Function Flatten-File

function Trim-Directory($directory) {
    Get-ChildItem -LiteralPath $directory -Directory | ForEach-Object { Trim-Directory $_ }
    if ((Get-ChildItem -LiteralPath $directory).Length -eq 0) { Remove-Item -LiteralPath $directory }
}

<#
.SYNOPSIS
Remove common prefix for jpg files.
#>
function Remove-Prefix {

    [CmdletBinding()]
    param ()

    $names = Get-ChildItem -Filter *.jpg | ForEach-Object { $_.Name }
    if ($names.Length -lt 2) { Return }
    $bases = $names | ForEach-Object { Split-Path -LeafBase $_ }

    $prefix = $bases[0]
    ForEach ($name in $bases[1..$bases.Length]) {
        $range = [Math]::Min($prefix.Length, $name.Length) - 1
        ForEach ($i in (0..$range)) {
            if ($prefix[$i] -ne $name[$i]) {
                $prefix = $prefix.Substring(0, $i)
                break
            }
        }
        if (!$prefix) { Return }
    }
    $prefix = [Regex]::Escape($prefix)

    $names | Rename-Item -NewName { $_ -replace "${prefix}0*", '' }
}
Export-ModuleMember -Function Remove-Prefix

<#
.SYNOPSIS
Normalize update folder, by removing trinkets and image prefix.
#>
function Normalize-Update {

    [CmdletBinding()]
    param ()

    Flatten-File
    Remove-Item * -Exclude '*.jpg' -Force
    Remove-Prefix
}
Export-ModuleMember -Function Normalize-Update

<#
.SYNOPSIS
Numerize image names in lexicographic order, instead the natural order that Explorer uses, so be careful.
#>
function Numerize-ImageName {

    [CmdletBinding()]
    param ()

    $names = Get-ChildItem -Filter '*.jpg' | ForEach-Object { $_.Name }
    if ($names.Length -eq 0) {
        Return
    }

    for ($i = 0; $i -lt $names.Length; $i++) {
        Rename-Item $names[$i] "$($i + 1).jpg"
    }
}
Export-ModuleMember -Function Numerize-ImageName
