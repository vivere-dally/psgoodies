function Reset-gSemVer {
    <#
    .SYNOPSIS
        Reset identifiers in a SemVer string.
    .DESCRIPTION
        This Cmdlet resets a specified identifier of a SemVer string.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER Version
        Version that will get an identifier reseted
    .PARAMETER Identifier
        Which Identifier to reset
        Valid choices: Major, Minor, Patch, Prerelease, Buildmetadata
    .EXAMPLE
        --- Example 1 Error cases ---
        PS C:\> '1.2.-3' | Reset-gSemVer Major
        
        The value 1.2.-3 is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid resets ---
        PS C:\> '1.2.3' | Reset-gSemVer Major
        
        0.2.3
        PS C:\> '1.2.3' | Reset-gSemVer Minor

        1.0.3
        PS C:\> '1.2.3' | Reset-gSemVer Patch

        1.2.0
        PS C:\> '1.2.3-alpha' | Reset-gSemVer Prerelease

        1.2.3
        PS C:\> '1.2.3-alpha.beta' | Reset-gSemVer Prerelease

        1.2.3-alpha
        PS C:\> '1.2.3-alpha.beta.1' | Reset-gSemVer Prerelease

        1.2.3-alpha.beta
        PS C:\> '1.2.3-alpha.beta.1' | Reset-gSemVer Prerelease | Reset-gSemVer Prerelease | Reset-gSemVer Prerelease

        1.2.3
    .INPUTS
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

        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateSet('Major', 'Minor', 'Patch', 'Prerelease', 'Buildmetadata')]
        [string]
        $Identifier
    )

    process {
        if (-not ($Version -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $Version
        }

        if (-not ($Matches.ContainsKey($Identifier))) {
            return $Version
        }

        $versionTable = $Matches
        # Remove the full match
        $versionTable.Remove(0)

        if ($Identifier -in @('Major', 'Minor', 'Patch')) {
            $versionTable[$Identifier] = 0
            return $versionTable | ConvertTo-gSemVer
        }

        $value = $versionTable[$Identifier].Split('.')
        if (1 -eq $value.Count) {
            # 1.2.3-alpha -> 1.2.3
            $versionTable.Remove($Identifier)
        }
        elseif (1 -lt $value.Count) {
            # 1.2.3-alpha.1 -> 1.2.3-alpha
            $value = $value[0..($value.Count - 2)]
            $versionTable[$Identifier] = $value -join '.'
        }

        return $versionTable | ConvertTo-gSemVer
    }
}
