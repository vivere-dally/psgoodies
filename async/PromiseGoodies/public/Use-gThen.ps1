function Use-gThen {
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    [Alias('Use-Then', 'Then', 'gThen')]
    [OutputType([PSGoodies.Async.Model.Promise])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Position')]
        [PSGoodies.Async.Model.Promise]
        $Promise,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Position')]
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
        {
            param($Promise, $ScriptBlock)

            $Promise | Wait-Job | Out-Null
            if ($Promise.State -ne 'Completed') {
                return $Promise
            }

            $scriptBlockArgs = [System.Management.Automation.PSDataCollection[System.Management.Automation.PSObject]] $Promise.Output
            return $ScriptBlock.Invoke($scriptBlockArgs)
        } | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList @($Promise, $ScriptBlock)
    }
}
