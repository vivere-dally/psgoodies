function Use-gThen {
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    [Alias('Use-Then', 'Then', 'gThen')]
    [OutputType([PSGoodies.Async.Model.Promise])]
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
            if ($Promise.State -ne 'Completed') {
                return $Promise
            }

            $output = $Promise.Output.ReadAll()
            if ($Promise.HasMoreData) {
                $Promise | Receive-Job | Out-Null
            }

            return $output
        }

        $jointScriptBlock = Join-gScriptBlock $parentScriptBlock $ScriptBlock
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise
    }
}
