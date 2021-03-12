function Compare-GooSemVer {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        https://semver.org/#spec-item-11
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [string]
        $LeftVersion,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]
        $RightVersion
    )

    begin {
        if (-not ($RightVersion -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $RightVersion
        }

        $rightMatches = $Matches
    }

    process {
        if (-not ($LeftVersion -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $LeftVersion
        }

        $leftMatches = $Matches

        # https://semver.org/#spec-item-11 #2
        foreach ($_ in @('major', 'minor', 'patch')) {
            if ($leftMatches[$_] -lt $rightMatches[$_]) { return '<' } 
            if ($leftMatches[$_] -gt $rightMatches[$_]) { return '>' }
        }

        # https://semver.org/#spec-item-11 #3
        if ($leftMatches.ContainsKey('prerelease') -and -not ($rightMatches.ContainsKey('prerelease'))) { return '<' }
        if (-not ($leftMatches.ContainsKey('prerelease')) -and $rightMatches.ContainsKey('prerelease')) { return '>' }

        # https://semver.org/#spec-item-11 #4
        if ($leftMatches.ContainsKey('prerelease') -and $rightMatches.ContainsKey('prerelease')) {
            $leftPrerelease = $leftMatches['prerelease'].Split('.')
            $rightPrerelease = $rightMatches['prerelease'].Split('.')
            $commonLength = ($leftPrerelease.Count, $rightPrerelease.Count | Measure-Object -Minimum).Minimum
            for ($i = 0; $i -lt $commonLength; $i++) {
                # https://semver.org/#spec-item-11 #4.3
                if (($leftPrerelease[$i] | isNumericIdentifier) -and -not ($rightPrerelease[$i] | isNumericIdentifier)) { return '<' }
                if (-not ($leftPrerelease[$i] | isNumericIdentifier) -and ($rightPrerelease[$i] | isNumericIdentifier)) { return '>' }

                # https://semver.org/#spec-item-11 #4.2
                if ($leftPrerelease[$i] -lt $rightPrerelease[$i]) { return '<' }
                if ($leftPrerelease[$i] -gt $rightPrerelease[$i]) { return '>' }
            }

            # https://semver.org/#spec-item-11 #4.4
            if ($leftPrerelease.Count -lt $rightPrerelease.Count) { return '<' }
            if ($leftPrerelease.Count -gt $rightPrerelease.Count) { return '>' }
        }

        return '==';
    }
}
