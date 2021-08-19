function Complete-gPromise {
    <#
    .SYNOPSIS
        Collect the results of a Promise.
    .DESCRIPTION
        The Complete-gPromise cmdlet waits a PowerShell background job starteed on the local computer.
        It collects the results similar to the Receive-Job cmdlet.
    .PARAMETER NoPromiseRemoval
        By default, Complete-gPromise removes the specified and chained Promises.
        Similar to Receive-Job -Wait -AutoRemoveJob.

        Use this switch to alter the default behaviour.
    .EXAMPLE
        PS C:\>$p = Start-gPromise { return 3 }
        PS C:\>$r = $p | Complete-gPromise

        3
    .INPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    [Alias('Complete-Promise', 'Complete', 'gComplete', 'Await')]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [PSGoodies.PromiseGoodies.Model.Promise]
        $Promise,

        [Parameter()]
        [switch]
        $NoPromiseRemoval
    )

    process {
        $Promise | Wait-Job | Out-Null
        try {
            if ($Promise.Output.Count -gt 0) {
                $promise.Output.ReadAll() | Write-Output
            }

            if ($Promise.Error.Count -gt 0) {
                $Promise.Error.ReadAll() | Write-Error
            }

            if ($promise.State -eq 'Failed') {
                if ($Promise.JobStateInfo.Reason.WasThrownFromThrowStatement) {
                    throw "Exception: $($Promise.JobStateInfo.Reason.ErrorRecord.ToString())"
                }

                $Promise.JobStateInfo.Reason.ErrorRecord | Write-Error
            }
        }
        finally {
            if (-not $NoPromiseRemoval) {
                $p = $Promise
                while ($p) {
                    $p | Remove-Job | Out-Null
                    $p = $p.ChildPromise
                }
            }
        }
    }
}
