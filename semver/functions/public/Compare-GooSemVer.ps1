function Compare-GooSemVer {
    <#
    .SYNOPSIS
        Compare two SemVer strings.
    .DESCRIPTION
        Compare two SemVer strings and returns <, > or ==.
        Tests if the given Versions respect the Semantic Versioning guidelines, and throws an error if not.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER DifferenceVersion
        Specifies the Versions that are compared to the reference Version.
    .PARAMETER ReferenceVersion
        Specifies a Version used as a reference for comparison.
    .EXAMPLE
        --- Example 1 Error case ---
        PS C:\> Compare-GooSemVer -DifferenceVersion 'a.b.c.' -ReferenceVersion '1.2.3'
        The value a.b.c. is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid comparisons ---
        PS C:\> Compare-GooSemVer -DifferenceVersion '1.2.3' -ReferenceVersion '1.2.3'

        ==
        PS C:\> Compare-GooSemVer -DifferenceVersion '1.2.4' -ReferenceVersion '1.2.3'

        >
        PS C:\> @('1.0.0', '1.1.1-alpha', '2.0.0', '1.2.2', '1.2.3-alpha') | Compare-GooSemVer -ReferenceVersion '1.2.3'

        <
        <
        >
        <
        <
    .INPUTS
        System.String

        System.String
    .OUTPUTS
        System.String
    .NOTES
        For more information about Semantic Versioning 2.0.0, see this: https://semver.org/
        The precedence is implemented by following this: https://semver.org/#spec-item-11

        If it is hard to remember which Version is which, either Difference or Reference, you can look on the Compare-Object docs: 
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/compare-object?view=powershell-7.1.
        Naming inspiration was drawn from there.

        The ReferenceVersion can accept only one value, where DifferenceVersion can take values from the pipeline.
        `@($a, $b, $c) | Compare-GooSemVer d` can be read as comparing a, b and c to d. d is the reference.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]
        $DifferenceVersion,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $ReferenceVersion
    )

    begin {
        if (-not ($ReferenceVersion -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $ReferenceVersion
        }

        $referenceMatches = $Matches
    }

    process {
        if (-not ($DifferenceVersion -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $DifferenceVersion
        }

        $differenceMatches = $Matches

        # https://semver.org/#spec-item-11 #2
        foreach ($_ in @('major', 'minor', 'patch')) {
            if ($differenceMatches[$_] -lt $referenceMatches[$_]) { return '<' } 
            if ($differenceMatches[$_] -gt $referenceMatches[$_]) { return '>' }
        }

        # https://semver.org/#spec-item-11 #3
        if ($differenceMatches.ContainsKey('prerelease') -and -not ($referenceMatches.ContainsKey('prerelease'))) { return '<' }
        if (-not ($differenceMatches.ContainsKey('prerelease')) -and $referenceMatches.ContainsKey('prerelease')) { return '>' }

        # https://semver.org/#spec-item-11 #4
        if ($differenceMatches.ContainsKey('prerelease') -and $referenceMatches.ContainsKey('prerelease')) {
            $differencePrerelease = $differenceMatches['prerelease'].Split('.')
            $referencePrerelease = $referenceMatches['prerelease'].Split('.')
            $commonLength = ($differencePrerelease.Count, $referencePrerelease.Count | Measure-Object -Minimum).Minimum
            for ($i = 0; $i -lt $commonLength; $i++) {
                # https://semver.org/#spec-item-11 #4.3
                if (($differencePrerelease[$i] | isNumericIdentifier) -and -not ($referencePrerelease[$i] | isNumericIdentifier)) { return '<' }
                if (-not ($differencePrerelease[$i] | isNumericIdentifier) -and ($referencePrerelease[$i] | isNumericIdentifier)) { return '>' }

                # https://semver.org/#spec-item-11 #4.2
                if ($differencePrerelease[$i] -lt $referencePrerelease[$i]) { return '<' }
                if ($differencePrerelease[$i] -gt $referencePrerelease[$i]) { return '>' }
            }

            # https://semver.org/#spec-item-11 #4.4
            if ($differencePrerelease.Count -lt $referencePrerelease.Count) { return '<' }
            if ($differencePrerelease.Count -gt $referencePrerelease.Count) { return '>' }
        }

        return '==';
    }
}
