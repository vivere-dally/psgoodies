function ConvertFrom-GooSemVer {
    <#
    .SYNOPSIS
        Convert a SemVer string to identifiers.
    .DESCRIPTION
        Convert a SemVer string to identifiers.
        Tests if the given Versions respect the Semantic Versioning guidelines, and throws an error if not.
        This Cmdlet accepts values from the pipeline.
    .EXAMPLE
        --- Example 1 Error case ---
        PS C:\> '1.2.abc' | ConvertFrom-GooSemVer

        The value 1.2.abc is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid input ---
        PS C:\> ConvertFrom-GooSemVer '1.2.3-alpha+beta'

        prerelease    : alpha
        buildmetadata : beta
        minor         : 2
        major         : 1
        patch         : 3
        PS C:\> ConvertFrom-GooSemVer '1.2.3-alpha+beta' -AsHashtable

        Name                           Value
        ----                           -----
        prerelease                     alpha
        buildmetadata                  beta
        minor                          2
        major                          1
        patch                          3
    .EXAMPLE
        --- Example 3 Valid input by pipeline ---
        PS C:\> '1.2.3-alpha+beta' | ConvertFrom-GooSemVer

        prerelease    : alpha
        buildmetadata : beta
        minor         : 2
        major         : 1
        patch         : 3
        PS C:\> '1.2.3-alpha+beta' | ConvertFrom-GooSemVer -AsHashtable

        Name                           Value
        ----                           -----
        prerelease                     alpha
        buildmetadata                  beta
        minor                          2
        major                          1
        patch                          3
    .INPUTS
        System.String

        System.Boolean
    .OUTPUTS
        System.Management.Automation.PSCustomObject
        
        System.Collections.Hashtable
    .NOTES
        For more information about Semantic Versioning 2.0.0, see this: https://semver.org/
    #>
    [CmdletBinding(DefaultParameterSetName = 'AsPSCustomObject')]
    [OutputType([PSCustomObject], ParameterSetName = 'AsPSCustomObject')]
    [OutputType([hashtable], ParameterSetName = 'AsHashtable')]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'AsPSCustomObject')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0, ParameterSetName = 'AsHashtable')]
        [string]
        $Version,

        [Parameter(Mandatory = $false, ParameterSetName = 'AsPSCustomObject')]
        [Parameter(Mandatory = $true, ParameterSetName = 'AsHashtable')]
        [switch]
        $AsHashtable
    )

    process {
        if (-not ($Version -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $Version
        }

        $versionTable = $Matches
        # Remove the full match
        $versionTable.Remove(0)
        if ($AsHashtable) {
            return $versionTable
        }

        return [PSCustomObject] $versionTable
    }
}
