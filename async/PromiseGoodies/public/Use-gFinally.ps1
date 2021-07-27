function Use-gFinally {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Position')]
        [PSGoodies.Async.Model.Promise]
        $Promise,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Position')]
        [scriptblock]
        $ScriptBlock
    )

    begin {
        # Load user defined commands
        $commandEntries = $ScriptBlock | Get-gCommandEntry

        # Load $using:* values
        $usings = $ScriptBlock | Get-gUsing
    }

    process {
        $parentScriptBlock = {
            param($Promise)

            $Promise | Wait-Job | Out-Null

            return $Promise
        }

        $jointScriptBlock = Join-gFinallyScriptBlock $parentScriptBlock $ScriptBlock
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise
    }
}