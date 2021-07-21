function Set-gSemVer {
    <#
    .SYNOPSIS
        Set identifiers in a SemVer string.
    .DESCRIPTION
        This Cmdlet sets the value for a specified identifier of a SemVer string.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        If the resulting Version is invalid, an error is thrown.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER Version
        Version that will get set
    .PARAMETER Identifier
        Which Identifier to step
        Valid choices: Major, Minor, Patch, Prerelease, Buildmetadata
    .PARAMETER Value
        Specifies the new value
    .EXAMPLE
        --- Example 1 Error cases ---
        PS C:\> Set-gSemVer -Version '1.-2.3' -Identifier Buildmetadata -Value 'build'
        
        The value 1.-2.3 is not following the SemVer guidelines.
        PS C:\> Set-gSemVer -Version '1.2.3' -Identifier Buildmetadata -Value '==ahasda'

        The resulted Version is in an invalid state 1.2.3+==ahasda. The value ==ahasda is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid sets ---
        PS C:\> Set-gSemVer -Version '1.2.3' -Identifier Buildmetadata -Value 'build'
        
        1.2.3+build
        PS C:\> Set-gSemVer -Version '1.2.3' -Identifier Major -Value '5'

        5.2.3

        PS C:\> @('1.2.3', '3.3.3-alpha', '1.0.0+build') | Set-gSemVer -Identifier Minor -Value '0'

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
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]
        $Version,

        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet('Major', 'Minor', 'Patch', 'Prerelease', 'Buildmetadata')]
        [string]
        $Identifier = 'Patch',

        [Parameter(Mandatory = $true, Position = 1)]
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

        $versionTable[$Identifier] = $Value
        $newVersion = $versionTable | ConvertTo-gSemVer
        if (-not ($newVersion -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidResultingVersionFormatMessage -f @($newVersion, $Value)
        }

        return $newVersion
    }
}
