function Add-gLogLevel {
    <#
    .SYNOPSIS
        Add a new log level
    .DESCRIPTION
        This cmdlet adds a new logging level that can be used by the Write-gLog cmdlet.
        If the level already exist, the duplicate will not be added.
    .PARAMETER Level
        The name of the level that will be added
    .EXAMPLE
        PS C:\> Add-gLogLevel -Level 'MyLevel'
        PS C:\> Add-gLogLevel -Level 'MyLevel2' -DefaultForegroundColor Magenta
    .INPUTS
        System.String
    .NOTES
        The default levels are: INFO, WARNING, ERROR
    #>
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [string]
        $Level,

        [Parameter(Mandatory = $false)]
        [System.ConsoleColor]
        $DefaultForegroundColor = $null
    )

    process {
        if ($Level -notin $Script:Levels.Keys) {
            $Script:Levels.$Level = $DefaultForegroundColor
        }
    }
}
