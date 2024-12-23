<#
.SYNOPSIS
Flatten all files under directories recursively into current directory.
#>
function Flatten-File {

    [CmdletBinding()]
    param (
        # Whether to write original path as prefix to files.
        [switch] $WithPrefix,
        # Whether to overwrite on existing file.
        [switch] $Force
    )

    Get-ChildItem -Recurse -File -Force | Where-Object { $_.Directory.FullName -ne $PWD } | ForEach-Object {

        $dest = if ($WithPrefix) {
            ($_.Directory.FullName -replace [Regex]::Escape("$PWD\"), '' | ForEach-Object { $_ -replace '\\', '_' }) + "_$($_.Name)"
        } else {
            "$PWD/$($_.Name)"
        }

        if (Test-Path -LiteralPath $dest) {
            if ($Force) { Remove-Item $dest }
            else {
                Write-Warning "File [$dest] already exists, skipping..."
                return
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
Simplify jpeg file names by removing prefix or overwrite order directly.
#>
function Simplify-JpegName {

    [CmdletBinding()]
    param (
        # Whether to overwrite original ordering, or just remove prefix.
        [switch] $OverWrite,
        # Whether to operate recursively.
        [switch] $Recurse
    )

    if ($Recurse) {
        (Get-ChildItem -Directory).ForEach({
            Set-Location -LiteralPath $_.Name

            $RecurseCommand = 'Simplify-JpegName -Recurse'
            if ($OverWrite) { $RecurseCommand = $RecurseCommand + ' -OverWrite'}
            Invoke-Expression $RecurseCommand

            Set-Location ..
        })
    }

    $names = Get-ChildItem ./* -Include ('*.jpg', '*.jpeg') | Select-Object -ExpandProperty 'Name'
    if ($names.Count -lt 2) { return }
    $names = [NaturalSort]::Sort($names)

    if ($OverWrite) {
        # Here we can only use ',' as the array construction operator because '@()' will flatten the result.
        # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_operators?#comma-operator-
        $ToRenames = (0..($names.Length - 1)).ForEach({ ,($names[$_], "$($_ + 1).jpg") }).Where({ $_[0] -ne $_[1] })
        while ($ToRenames.Length -gt 0) {
            $Conflicts = $ToRenames.Where({ Test-Path $_[1] })
            $ToRenames.Where({ !(Test-Path $_[1]) }).ForEach({ Rename-Item $_[0] $_[1] })
            $ToRenames = $Conflicts
        }
        return
    }

    $bases = $names | ForEach-Object { Split-Path -LeafBase $_ }

    $prefix = $bases[0]
    $suffix = $bases[0]
    ForEach ($name in $bases[1..($bases.Length - 1)]) {
        $range = [Math]::Min($prefix.Length, $name.Length) - 1
        ForEach ($i in (0..$range)) {
            if ($prefix[$i] -ne $name[$i]) {
                $prefix = $prefix.Substring(0, $i)
                break
            }
        }
        ForEach ($i in (0..$range)) {
            if ($suffix[$suffix.Length - $i - 1] -ne $name[$name.Length - $i - 1]) {
                $suffix = $suffix.Substring($suffix.Length - $i, $i)
                break
            }
        }
        if (!$prefix -and !$suffix) { break }
    }
    $prefix = [Regex]::Escape($prefix)
    $suffix = [Regex]::Escape($suffix)

    $names.ForEach({
        $NewName = $_ -replace "^${prefix}0*(.*)${suffix}\.jpe?g$", '$1.jpg'
        if ($NewName -ne $_) { Rename-Item $_ $NewName }
    })
}
Export-ModuleMember -Function Simplify-JpegName

<#
.SYNOPSIS
Normalize update folder, by removing trinkets and image prefix.
#>
function Normalize-Update {

    [CmdletBinding()]
    param ()

    Flatten-File
    Remove-Item * -Exclude '*.jpg', '*.jpeg', '*.png' -Force
    Simplify-JpegName
}
Export-ModuleMember -Function Normalize-Update

<#
.SYNOPSIS
Format byte size for human readable.
#>
function Format-ByteSize {

    [CmdletBinding()]
    param ([double] $Size)

    $Suffix = ('B', 'KB', 'MB', 'GB', 'TB')
    $Index = 0;
    while ($Size -gt 1kb)
    {
        $Size = $Size / 1kb
        $Index++
    } 

    "{0:0.##}{1}" -f $Size, $Suffix[$Index]
}
Export-ModuleMember -Function Format-ByteSize

Add-Type -TypeDefinition @"
using System.Runtime.InteropServices;
public static class NaturalSort
{
    [DllImport("Shlwapi.dll", CharSet = CharSet.Unicode)]
    private static extern int StrCmpLogicalW(string psz1, string psz2);
    public static string[] Sort(string[] array)
    {
        System.Array.Sort(array, (psz1, psz2) => StrCmpLogicalW(psz1, psz2));
        return array;
    }
}
"@
