
function ConvertTo-gHashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [psobject]
        $InputObject,

        [Parameter(Mandatory = $false)]
        [uint]
        $Depth = 2
    )

    process {
        return $InputObject | ConvertTo-Json -Depth $Depth | ConvertFrom-Json -AsHashtable
    }
}
