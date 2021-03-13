function Step-GooSemVer {
    <#
    .SYNOPSIS
        Increment or decrement a certain label from a SemVer string.
    .DESCRIPTION
        Increment or decrement a certain label from a SemVer string.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        If a Label that is not part of the Version is specified, the unaltered version is returned.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER Version
        Version that will get stepped
    .PARAMETER Label
        Which label to step
        Valid choices: Major, Minor, Patch, Prerelease, Buildmetadata
    .PARAMETER Reverse
        Switch that specifies wether to increment or decrement
    .EXAMPLE
        --- Example 1 Error case ---
        PS C:\> Step-GooSemVer -Version '0.1.1-alpha++build' -Label Major
        The value 0.1.1-alpha++build is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Increment/Decrement Major ---
        PS C:\> @('0.0.0', '0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build') | Step-GooSemVer -Label Major

        1.0.0
        1.0.0
        1.0.0
        2.0.0
        1.0.0-alpha
        1.0.0+build
        1.0.0-alpha+build
        PS C:\> @('0.0.0', '0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build') | Step-GooSemVer -Label Major -Reverse

        1.0.0
        1.0.0
        1.0.0
        1.0.0
        1.0.0-alpha
        1.0.0+build
        1.0.0-alpha+build
        PS C:\> @('2.0.0', '2.2.2', '1.0.0-alpha', '3.0.0-alpha') | Step-GooSemVer -Label Major -Reverse

        1.0.0
        1.0.0
        1.0.0-alpha
        2.0.0-alpha
    .EXAMPLE
        --- Example 3 Increment/Decrement Minor ---
        PS C:\> Step-GooSemVer '1.2.3' Minor

        1.3.0
    .EXAMPLE
        --- Example 4 Increment/Decrement Patch ---
        PS C:\> Step-GooSemVer '1.2.3' Patch

        1.2.4
        PS C:\> Step-GooSemVer '1.2.3'

        1.2.4
        # Patch is the default label
    .EXAMPLE
        --- Example 5 Increment/Decrement Prerelease ---
        PS C:\> Step-GooSemVer '1.2.3-alpha' Prerelease

        1.2.3-alpha.1
        PS C:\> Step-GooSemVer '1.2.3-alpha' Prerelease

        1.2.3-alpha.1
        PS C:\> Step-GooSemVer '1.2.3-alpha.1' Prerelease -Reverse

        1.2.3-alpha
    .INPUTS
        System.String

        System.String

        System.Boolean
    .OUTPUTS
        System.String
    .NOTES
        For more information about Semantic Versioning 2.0.0, see this: https://semver.org/
        Have a look at the examples to see some interesting edge cases.

        Incrementing a prerelease or build metadata label without a version will result in a version being added:
            - 0.1.0-alpha -> 0.1.0-alpha.1
            - 0.1.0+build -> 0.1.0+build.1

        Decrementing is not clearly defined so there are a few caveat that you need to know:
            Decrementing any of 1.0.0, 0.1.0, 0.0.1 will result in the same output, they won't get to 0.0.0.

            - Major:
                - 2.1.1 -> 1.0.0. It will reset the Minor and Patch.

            - Minor:
                - 2.1.2 -> 2.0.0. It will reset Patch.
        
            - Prerelease:
                - 1.2.3-alpha.1 -> 1.2.3-alpha. The version and the dot will get stripped

            - Buildmetadata:
                - 1.2.3+build.1 -> 1.2.3+build. The version and the dot will get stripped
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

        [Parameter(Mandatory = $false, Position = 2)]
        [switch]
        $Reverse
    )

    process {
        if (-not ($Version -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $Version
        }

        if (-not ($Matches.ContainsKey($Label))) {
            return $Version
        }

        $versionTable = $Matches
        # Remove the full match
        $versionTable.Remove(0)

        [int] $step = if ($Reverse) { -1 } else { 1 }
        if ($Label -in @('Major', 'Minor', 'Patch')) {
            [int] $value = $versionTable[$Label]
            switch ($Label) {
                'Major' { $versionTable['Minor'] = 0; $versionTable['Patch'] = 0; }
                'Minor' { $versionTable['Patch'] = 0; }
            }

            $value += $step

            # https://semver.org/#spec-item-2
            if ($value -lt 0) { $value = 0 }
            $versionTable[$Label] = $value

            # 1.0.0, 0.1.0, 0.0.1 =/> 0.0.0
            if ($versionTable['Major'] -eq 0 -and $versionTable['Minor'] -eq 0 -and $versionTable['Patch'] -eq 0) { $versionTable[$Label] = 1 }
            return New-GooSemVer @versionTable
        }

        $value = $versionTable[$Label].Split('.')
        $lastPart = $value | Select-Object -Last 1
        if ($lastPart | isNumericIdentifier) {
            $lastPart = ([int] $lastPart) + $step
            if ($lastPart -le 0 -and $value.Length -ge 2) {
                # Remove the last element. E.g.: 1.0.0-alpha.1 -> 1.0.0-alpha
                $value = $value[0..($value.Length - 2)]
            }
        }
        elseif (-not $Reverse) {
            # Add a version. E.g.: 1.0.0-alpha -> 1.0.0-alpha.1
            $value += $step
        }

        $versionTable[$Label] = $value -join '.'
        return New-GooSemVer @versionTable
    }
}
