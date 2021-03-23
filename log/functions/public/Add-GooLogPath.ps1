function Add-GooLogPath {
    <#
    .SYNOPSIS
        Add a new log path
    .DESCRIPTION
        This cmdlet adds a new logging path to a file.
        When using the Write-GooLog cmdlet, the text will be appended to the specified file.
        If the path already exists, the duplicate will not be added.
    .PARAMETER Path
        The Path where logs will be redirected to.
        If the file does not exist, it will be created.
        If the file exists, the Force parameter must be specified otherwise an error will be thrown.
    .PARAMETER Force
        The Force parameter will be passed to the New-Item cmdlet.
        If the file specified by the Path parameter exists, it will get overwritten.
    .EXAMPLE
        -- Example 1 Add using named parameter ---
        PS C:\> Add-GooLogLevel -Path 'myfile.log'
    .EXAMPLE
        -- Example 2 Add using positional parameter ---
        PS C:\> Add-GooLogLevel 'myfile.log'
    .EXAMPLE
        -- Example 3 Add using pipeline input parameter ---
        PS C:\> 'myfile.log' | Add-GooLogLevel
    .EXAMPLE
        -- Example 4 If the file exists ---
        PS C:\> 'myfile.log' | Add-GooLogLevel

        The file 'myfile.log' already exists.
        PS C:\> 'myfile.log' | Add-GooLogLevel -Force
    .INPUTS
        System.String

        System.Boolean
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
        $newItemParams = @{
            Path     = $Path;
            ItemType = 'File';
            Force    = $Force;
        }

        New-Item @newItemParams | Out-Null
        if ($Path -notin $Script:GooLog.Path) {
            $Script:GooLog.Path += $Path
        }
    }
}
