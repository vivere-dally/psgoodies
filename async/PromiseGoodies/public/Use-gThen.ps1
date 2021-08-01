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
            param($Promise, [ref] $ShouldSkip)

            $Promise | Wait-Job | Out-Null
            if ($Promise.Error.Count -gt 0) {
                $ShouldSkip.Value =  $true
                $Promise.Error.ReadAll() | Write-Error
            }

            if ($Promise.State -eq 'Failed') {
                $ShouldSkip.Value =  $true
                if ($Promise.JobStateInfo.Reason.WasThrownFromThrowStatement) {
                    throw "Exception: $($Promise.JobStateInfo.Reason.ErrorRecord.ToString())"
                }

                $Promise.JobStateInfo.Reason.ErrorRecord | Write-Error
            }

            if ($ShouldSkip.Value) {
                return
            }

            $output = $Promise.Output.ReadAll()
            return $output
        }

        $jointScriptBlock = Join-gScriptBlock $parentScriptBlock $ScriptBlock
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise
    }
}
