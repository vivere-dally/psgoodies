function Set-GooSemVer {
    <#
    .SYNOPSIS
        Set labels in a SemVer string.
    .DESCRIPTION
        This Cmdlet sets the value for a specified part of a SemVer string.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        If the resulting Version is invalid, an error is thrown.
        This Cmdlet accepts values from the pipeline.
    .EXAMPLE
        --- Example 1 Error cases ---
        PS C:\> Set-GooSemVer -Version '1.-2.3' -Label Buildmetadata -Value 'build'
        
        The value 1.-2.3 is not following the SemVer guidelines.
        PS C:\> Set-GooSemVer -Version '1.2.3' -Label Buildmetadata -Value '==ahasda'

        The resulted Version is in an invalid state 1.2.3+==ahasda. The value ==ahasda is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid sets ---
        PS C:\> Set-GooSemVer -Version '1.2.3' -Label Buildmetadata -Value 'build'
        
        1.2.3+build
        PS C:\> Set-GooSemVer -Version '1.2.3' -Label Major -Value '5'

        5.2.3

        PS C:\> @('1.2.3', '3.3.3-alpha', '1.0.0+build') | Set-GooSemVer -Label Minor -Value '0'

        1.0.3
        3.0.3-alpha
        1.0.0+build
    .INPUTS
        System.String

        System.String

        System.String
    .OUTPUTS
        System.String
    .NOTES
        For more information about Semantic Versioning 2.0.0, see this: https://semver.org/
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]
        $Version,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateSet('Major', 'Minor', 'Patch', 'Prerelease', 'Buildmetadata')]
        [string]
        $Label = 'Patch',

        [Parameter(Mandatory = $true, Position = 2)]
        [string]
        $Value
    )

    process {
        if (-not ($Version -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $Version
        }

        $versionTable = $Matches
        # Remove the full match
        $versionTable.Remove(0)

        $versionTable[$Label] = $Value
        $newVersion = New-GooSemVer @versionTable
        if (-not ($newVersion -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidResultingVersionFormatMessage -f @($newVersion, $Value)
        }

        return $newVersion
    }
}
