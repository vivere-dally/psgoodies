function Select-GooSemVer {
    <#
    .SYNOPSIS
        Selects SemVer strings.
    .DESCRIPTION
        This cmdlet filters the SemVer strings by specifying a value for a certain label.
        Tests if the given Version respects the Semantic Versioning guidelines, and throws an error if not.
        This Cmdlet accepts values from the pipeline.
    .EXAMPLE
        --- Example 1 Error cases ---
        PS C:\> Select-GooSemVer -Version '1.-2.3' -Label Buildmetadata -Value 'build'
        
        The value 1.-2.3 is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 Valid select operations ---
        PS C:\> @('0.0.0', '0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build') | Select-GooSemVer -Label Patch -Value 1
        
        0.0.1      
        0.1.1-alpha
        0.1.1+build
        0.1.1-alpha+build
        PS C:\> @('0.0.1', '0.1.0', '1.0.0', '0.1.1-alpha', '0.1.1+build', '0.1.1-alpha+build', '1.2.3-beta') | Select-GooSemVer -Label Prerelease -Value alpha

        0.1.1-alpha
        0.1.1-alpha+build
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

        if ($Matches.ContainsKey($Label) -and $Matches[$Label] -eq $Value) { return $Version }
    }
}
