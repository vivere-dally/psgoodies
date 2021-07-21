function Select-gSemVer {
    <#
    .SYNOPSIS
        Selects SemVer strings.
    .DESCRIPTION
        This cmdlet filters the SemVer strings by specifying a value for a certain label.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER Version
        Version that will get filtered
    .PARAMETER Identifier
        Which Identifier to filter by
        Valid choices: Major, Minor, Patch, Prerelease, Buildmetadata
    .PARAMETER Value
        Specifies the value to filter by
    .PARAMETER Stable
        Filters out the unstable versions. https://semver.org/#spec-item-9
    .EXAMPLE
        --- Example 1 Error cases ---
        PS C:\> Select-gSemVer -Version '1.-2.3' -Identifier Buildmetadata -Value 'build'
        
        The value 1.-2.3 is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid select operations ---
        PS C:\> @('0.0.0', '0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build') | Select-gSemVer -Identifier Patch -Value 1
        
        0.0.1      
        0.1.1-alpha
        0.1.1+build
        0.1.1-alpha+build
        PS C:\> @('0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build', '1.2.3-beta') | Select-gSemVer -Identifier Prerelease -Value alpha

        0.1.1-alpha
        0.1.1-alpha+build
        PS C:\> @('0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build', '1.2.3-beta') | Select-gSemVer -Stable

        0.0.1
        0.1.0
        1.0.0
        0.1.1+build
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
    [OutputType([string], ParameterSetName = ('ByIdentifier', 'Stable'))]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'ByIdentifier')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Stable')]
        [string]
        $Version,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ByIdentifier')]
        [ValidateSet('Major', 'Minor', 'Patch', 'Prerelease', 'Buildmetadata')]
        [string]
        $Identifier,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'ByIdentifier')]
        [string]
        $Value,

        [Parameter(Mandatory = $true, ParameterSetName = 'Stable')]
        [switch]
        $Stable
    )

    process {
        if (-not ($Version -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $Version
        }

        if ($Stable) {
            if (-not $Matches.Contains('prerelease')) {
                return $Version
            }
        }
        else {
            if ($Matches.ContainsKey($Identifier) -and $Matches[$Identifier] -eq $Value) {
                return $Version
            }
        }
    }
}
