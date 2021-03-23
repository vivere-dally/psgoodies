function Add-GooLogPath {
    <#
    .SYNOPSIS
        Add a new log path
    .DESCRIPTION
        This cmdlet adds a new logging path to a file.
        When using the Write-GooLog cmdlet, the text will be appended to the specified file.
        If the level already exist, the duplicate will not be added.
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
        $Path,

        [Parameter()]
        [switch]
        $Force
    )

    process {
        if (-not (Test-Path $Path -PathType Leaf)) {
            throw 'The Path does not exist or it is not a file.'
        }

        $newItemParams = @{
            Path     = $Path;
            ItemType = 'File';
            Force    = $Force;
        }

        New-Item @newItemParams | Out-Null
        $Script:GooLog.Path += $Path
    }
}
