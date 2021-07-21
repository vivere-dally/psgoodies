function Set-gLogDateFormat {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]
        $Format,

        [Parameter(Mandatory = $false, Position = 1)]
        [bool]
        $AsUTC = $false
    )

    $Script:Date = @{
        Format = $Format;
        AsUTC  = $AsUTC;
    }
}
