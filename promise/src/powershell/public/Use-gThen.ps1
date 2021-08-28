function Use-gThen {
    <#
    .SYNOPSIS
        Extend a successful Promise.
    .DESCRIPTION
        The Use-gThen cmdlet starts a PowerShell background job on the local computer.
        It executes the ScriptBlock only if the specified Promise finished sucessfully.
    .EXAMPLE
        PS C:\> Start-gPromise { Write-Host 'hello' } | Use-gThen { Write-Host 'world' }

        hello
        world
        PS C:\> Start-gPromise { Write-Host 'hello'; throw } | Use-gThen { Write-Host 'world' }

        hello
    .EXAMPLE
        PS C:\> Start-gPromise { return 1, 2, 3 } | Use-gThen { param($a, $b, $c) Write-Host "$a;$b;$c" }

        1;2;3
    .INPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .OUTPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .NOTES
        https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/then
    #>
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    [Alias('Use-Then', 'Then', 'gThen')]
    [OutputType([PSGoodies.PromiseGoodies.Model.Promise])]
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
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise -ChildPromise $Promise
    }
}
