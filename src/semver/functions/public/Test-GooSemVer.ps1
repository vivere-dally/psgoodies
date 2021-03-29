function Test-GooSemVer {
    <#
    .SYNOPSIS
        Test if a given string is a valid SemVer.
    .DESCRIPTION
        Test if a given string is respects the Semantic Versioning guidelines.
        This Cmdlet accepts values from the pipeline.
    .PARAMETER Version
        Version that will get tested
    .EXAMPLE
        --- Example 1 Test valid versions ---
        PS C:\> @('1.0.0', '0.1.0', '0.0.1', '0.1.0-alpha', '0.1.0+build', '1.2.3-alpha+build') | Test-GooSemVer
    .EXAMPLE
        --- Example 2 Test invalid versions ---
        PS C:\> @('-1.0.0', '0,1,0', '0.0.1=alpha', '0.1.0-alpha.1,2', '0.1.0+build.3,3', '1.2.3-alpha++build') | Test-GooSemVer
    .INPUTS
        System.String
    .OUTPUTS
        System.Boolean
    .NOTES
        For more information about Semantic Versioning 2.0.0, see this: https://semver.org/
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Version
    )

    process {
        return $Version -match $Script:GooSemVer.Rex
    }
}
