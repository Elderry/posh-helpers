<#
.SYNOPSIS
Start GnuPG agent, if it is not started yet. Reference:
https://www.gnupg.org/documentation/manuals/gnupg/Invoking-GPG_002dAGENT.html
#>
function Start-GnuPGAgent {

    [CmdletBinding()]
    param ()
    Detect-GnuPG

    $GPGStatus = gpg-agent 2>&1
    # If output is redirected from error output channel, it will be a collection of ErrorRecord, convert them to String
    # specifically.
    if ($GPGStatus.GetType().Name -eq 'ErrorRecord') {
        $GPGStatus = $GPGStatus.Exception.Message
    }

    if ($GPGStatus.Contains('no gpg-agent running in this session')) {
        gpg-connect-agent /bye
    } else {
        Write-Host $GPGStatus
    }
}
Export-ModuleMember -Function Start-GnuPGAgent

function Detect-GnuPG {
    if (Get-Command gpg -ErrorAction SilentlyContinue) { Return }
    Write-Error 'GnuPG is not installed, please install it first.' `
        + 'Link at https://www.gnupg.org/download/index.html'
    Exit
}
