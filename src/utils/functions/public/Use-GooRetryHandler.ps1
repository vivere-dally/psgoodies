function Use-GooRetryHandler {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $false)]
        [PSCustomObject[]]
        $ArgumentList,

        [Parameter(Mandatory = $false)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]
        $Retries = 5,

        [Parameter(Mandatory = $false)]
        [ValidateRange(0, [double]::MaxValue)]
        [double]
        $TimeoutSec = 0
    )

    process {
        for ($attempt = 1; $attempt -le $Retries; $attempt++) {
            try {
                Write-Verbose "Attempt $attempt/$Retries"
                return $ScriptBlock.Invoke($ArgumentList)
            }
            catch {
                Write-Verbose "Error message: $($_.Exception.InnerException.Message)"
                if (0 -lt $TimeoutSec) { Write-Verbose "Timing out for $TimeoutSec seconds..." } 
                Start-Sleep -Seconds $TimeoutSec
            }
        }

        throw "ScriptBlock failed $Retries times!"
    }
}
