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
        $jointScriptBlock = @"
param(`$Promise)

`$Promise | Wait-Job | Out-Null

Invoke-Command -ScriptBlock { [csb] } | Out-Null

if (`$Promise.State -eq 'Completed' -and `$Promise.Error.Count -eq 0) {
    `$output = `$Promise.Output.ReadAll()
    return `$output
}

if (`$Promise.Error.Count -gt 0) {
    `$Promise.Error.ReadAll() | Write-Error
}

if (`$Promise.State -eq 'Failed') {
    if (`$Promise.JobStateInfo.Reason.WasThrownFromThrowStatement) {
        throw "Exception: `$(`$Promise.JobStateInfo.Reason.ErrorRecord.ToString())"
    }

    `$Promise.JobStateInfo.Reason.ErrorRecord | Write-Error
}
"@.Replace('[csb]', $ScriptBlock.ToString())

        $jointScriptBlock = [scriptblock]::Create($jointScriptBlock)
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise
    }
}
