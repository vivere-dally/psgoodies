function Add-GooLogLevel {
    <#
    .SYNOPSIS
        Add a new log Level
    .DESCRIPTION
        This cmdlet adds a new logging level that can be used by the Write-GooLog cmdlet.
        If the level already exist, the duplicate will not be added.
    .PARAMETER Level
        The name of the level that will be added
    .EXAMPLE
        -- Example 1 Add using named parameter ---
        PS C:\> Add-GooLogLevel -Level 'MyLevel1'
    .EXAMPLE
        -- Example 2 Add using positional parameter ---
        PS C:\> Add-GooLogLevel 'MyLevel2'
    .EXAMPLE
        -- Example 3 Add using pipeline input parameter ---
        PS C:\> 'MyLevel3' | Add-GooLogLevel
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
        $Level
    )

    process {
        if ($Level -notin $Script:GooLog.Levels) {
            $Script:GooLog.Levels += $Level
        }
    }
}
