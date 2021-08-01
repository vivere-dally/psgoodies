function Complete-gPromise {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [PSGoodies.Async.Model.Promise]
        $Promise
    )

    process {
        $Promise | Wait-Job | Out-Null
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
}
