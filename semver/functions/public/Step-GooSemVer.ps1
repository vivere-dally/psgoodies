function Step-GooSemVer {
    <#
    .SYNOPSIS
        Increment a certain identifier from a SemVer string.
    .DESCRIPTION
        Increment a certain identifier from a SemVer string.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        If a Label that is not part of the Version is specified, the unaltered version is returned.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER Version
        Version that will get stepped
    .PARAMETER Identifier
        Which Identifier to step
        Valid choices: Major, Minor, Patch, Prerelease, Buildmetadata
    .EXAMPLE
        --- Example 1 Error case ---
        PS C:\> Step-GooSemVer -Version '0.1.1-alpha++build' -Identifier Major
        The value 0.1.1-alpha++build is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Major ---
        PS C:\> @('0.0.0', '0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build') | Step-GooSemVer -Identifier Major

        1.0.0
        1.0.0
        1.0.0
        2.0.0
        1.0.0
        1.0.0
        1.0.0
    .EXAMPLE
        --- Example 3 Minor ---
        PS C:\> Step-GooSemVer -Version '1.2.3-alpha' Minor

        1.3.0
    .EXAMPLE
        --- Example 4 Patch ---
        PS C:\> Step-GooSemVer -Version '1.2.3-alpha' Patch

        1.2.4
        PS C:\> '1.2.3' | Step-GooSemVer

        1.2.4
        # Patch is the default identifier
    .EXAMPLE
        --- Example 5 Prerelease ---
        PS C:\> Step-GooSemVer -Version '1.2.3-alpha' Prerelease

        1.2.3-alpha.1
        PS C:\> Step-GooSemVer -Version '1.2.3-alpha.1' Prerelease

        1.2.3-alpha.2
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

        [Parameter(Mandatory = $false, Position = 0)]
        [ValidateSet('Major', 'Minor', 'Patch', 'Prerelease', 'Buildmetadata')]
        [string]
        $Identifier = 'Patch'
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

        # https://semver.org/#spec-item-7 -> 10
        if ($Identifier -in @('Major', 'Minor', 'Patch')) {
            switch ($Identifier) {
                'Major' { $versionTable['Minor'] = 0; $versionTable['Patch'] = 0; break; }
                'Minor' { $versionTable['Patch'] = 0; break; }
            }

            $versionTable.Remove('prerelease')
            $versionTable.Remove('buildmetadata')
            [int] $value = $versionTable[$Identifier]
            $value++
            $versionTable[$Identifier] = $value
            return $versionTable | ConvertTo-GooSemVer
        }

        $value = $versionTable[$Identifier].Split('.')
        $lastIdentifier = $value | Select-Object -Last 1
        if ($lastIdentifier | isNumericIdentifier) {
            # 1.0.0-alpha.1 -> 1.0.0-alpha.2
            $lastIdentifier = ([int] $lastIdentifier) + 1
            $value[$value.Count - 1] = $lastIdentifier
        }
        else {
            # 1.0.0-alpha -> 1.0.0-alpha.1
            $value += 1
        }

        $versionTable[$Identifier] = $value -join '.'
        return $versionTable | ConvertTo-GooSemVer
    }
}
