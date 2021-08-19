function Use-gFinally {
    <#
    .SYNOPSIS
        Extend a Promise.
    .DESCRIPTION
        The Use-gFinally cmdlet starts a PowerShell background job on the local computer.
        It executes the ScriptBlock regardless of the state of the specified Promise.

        Moreover, Use-gFinally cannot receive the parameters returned by the previous Promise. Also, it cannot return any values.
    .EXAMPLE
        PS C:\> Start-gPromise { Write-Host 'hello' } | Use-gFinally { Write-Host 'world' }

        hello
        world
    .INPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .OUTPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .NOTES
        https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally
    #>
    [CmdletBinding()]
    [Alias('Use-Finally', 'Finally', 'gFinally')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Position')]
        [PSGoodies.PromiseGoodies.Model.Promise]
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
        $usings = $ScriptBlock | Get-gUsing -ParentPSCmdlet $PSCmdlet
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
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise -ChildPromise $Promise
    }
}
