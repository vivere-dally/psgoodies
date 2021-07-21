function Start-gPromise {
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    [Alias('Start-Promise', 'Promise', 'gPromise')]
    [OutputType([PSGoodies.Async.Model.Promise])]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Position')]
        [AllowEmptyCollection()]
        [psobject[]]
        $ArgumentList = @(),

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
        $ScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $ArgumentList
    }
}
