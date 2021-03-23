function Set-GooLogDateFormat {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Format')]
        [string]
        $Format,


        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'UFormat')]
        [string]
        $UFormat,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'Format')]
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'UFormat')]
        [bool]
        $AsUTC
    )

    if ('Format' -eq $PSCmdlet.ParameterSetName) {
        $Script:GooLog.Date = @{
            Format = $Format;
            AsUTC  = $AsUTC;
        }

        return
    }

    $Script:GooLog.Date = @{
        UFormat = $UFormat;
        AsUTC   = $AsUTC;
    }
}
