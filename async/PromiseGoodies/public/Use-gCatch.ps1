function Use-gCatch {
    <#
    .SYNOPSIS
        Extend an unsuccessful Promise.
    .DESCRIPTION
        The Use-gCatch cmdlet starts a PowerShell background job on the local computer.
        It executes the ScriptBlock only if the specified Promise finished unsuccessfully.
    .EXAMPLE
        PS C:\> Start-gPromise { Write-Host 'hello' } | Use-gCatch { Write-Host 'world' }

        hello
        PS C:\> Start-gPromise { Write-Host 'hello'; throw } | Use-gCatch { Write-Host 'world' }

        hello
        world
    .EXAMPLE
        PS C:\> Start-gPromise { throw 'err' } | Use-gCatch { param($err) Write-Host $err }

        err
    .INPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .OUTPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .NOTES
        https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/catch
    #>
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    [Alias('Use-Catch', 'Catch', 'gCatch')]
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
            if ($Promise.State -eq 'Completed' -and $Promise.Error.Count -eq 0) {
                $ShouldSkip.Value = $true
                $output = $Promise.Output.ReadAll()
                return $output
            }

            $errors = $Promise.Error.ReadAll()
            if ($Promise.State -eq 'Failed') {
                $errors.Add($Promise.JobStateInfo.Reason.ErrorRecord)
            }

            return $errors
        }

        $jointScriptBlock = Join-gScriptBlock $parentScriptBlock $ScriptBlock
        $jointScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $Promise -ChildPromise $Promise
    }
}