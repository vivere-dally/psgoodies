function Test-gLogAnsi {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [bool]
        $Value
    )

    process {
        if ($Global:gLogAnsiPreference -eq 'Set') {
            return $true
        }

        return $Value
    }
}
