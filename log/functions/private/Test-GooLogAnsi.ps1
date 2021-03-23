function Test-GooLogAnsi {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [bool]
        $Value
    )

    if ('Set' -eq $Global:GooLogAnsiPreference) {
        return $true
    }

    return $Value
}
