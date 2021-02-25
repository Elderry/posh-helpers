
<#
.SYNOPSIS
Restore working directory to git HEAD.
#>
function git_drop {

    [CmdletBinding()]
    param()

    # Revert unstaged changes.
    git reset --hard
    # Remove untracked files and directories.
    git clean -fd
}
Export-ModuleMember -Function git_drop

<#
.SYNOPSIS
Prune all local branches other than main, master and current one.
#>
function git_prune {

    [CmdletBinding()]
    param()

    $Branches = (git branch -l).
        ForEach({ $_.Trim() }).
        Where({ (-not $_.StartsWith('*')) -and (-not ($_ -in ('master', 'main'))) })

    if ($Branches.Count -eq 0) {
        Write-Host 'No branch is going to be deleted.'
        return
    }

    $Red = "`e[91m"
    $Reset = "`e[0m"
    Write-Host "Going to ${Red}delete$Reset these branches:"
    Write-Host $Branches

    $Question = 'Are you sure you want to proceed?'
    $Choices = '&Yes', '&No'
    $Decision = $Host.UI.PromptForChoice('', $Question, $Choices, 1)
    if ($Decision -eq 0) {
        $Branches.ForEach({ git branch -D $_ })
    }
}
Export-ModuleMember -Function git_prune

<#
.SYNOPSIS
Open the web page of the git repository.
#>
function git_open {

    [CmdletBinding()]
    param()

    $Origin = git remote get-url origin
    $Branch = git branch --show-current
    switch -Regex ($Origin) {

        # github.com
        '^git@github\.com:(.+)\.git$' { Start-Process "https://github.com/$($Matches[1])/tree/$Branch" }

        # dev.azure.com
        '^git@ssh\.dev\.azure\.com:v3/([^/]+)/([^/]+)/([^/]+)$' {
            Start-Process "https://dev.azure.com/$($Matches[1])/$($Matches[2])/_git/$($Matches[3])?version=GB$Branch"
        }
        default { Write-Error "Unknown repository provider [$Origin]." }
    }
}
Export-ModuleMember -Function git_open

<#
.SYNOPSIS
Push current branch even if it has no upstream one.
#>
function git_push {

    [CmdletBinding()]
    param()

    $FirstTry = Invoke-Expression 'git push 2>&1'

    # If output is redirected from error output channel, it will be a collection of ErrorRecord, convert them to String
    # specifically.
    if ($FirstTry[0].GetType().Name -eq 'ErrorRecord') {
        $FirstTry = $FirstTry.ForEach({ $_.Exception.Message })
    }

    Write-Host $FirstTry -Separator "`n"

    if ($FirstTry[3] -Match '^\s*(git push --set-upstream origin \S+)$') {
        Write-Host "`nThe push is recoverable, going to retry...`n"
        Invoke-Expression $Matches[1]
    }
}
Export-ModuleMember -Function git_push
