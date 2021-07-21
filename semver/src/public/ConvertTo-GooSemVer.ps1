function ConvertTo-gSemVer {
    <#
    .SYNOPSIS
        Convert identifiers to a SemVer string.
    .DESCRIPTION
        Convert identifiers to a SemVer string.
        Tests if the given Versions respect the Semantic Versioning guidelines, and throws an error if not.
        This Cmdlet accepts values from the pipeline.
    .EXAMPLE
        --- Example 1 Error case ---
        PS C:\> ConvertTo-gSemVer -Major 1 -Minor 2 -Patch 'abc'

        The value 1.2.abc is not following the SemVer guidelines.
    .EXAMPLE
        --- Example 2 By Identifier ---
        PS C:\> ConvertTo-gSemVer -Major 1 -Minor 2 -Patch 3 -Prerelease 'alpha' -Buildmetadata 'build'

        1.2.3-alpha+build
    .EXAMPLE
        --- Example 3 By Splatting ---
        PS C:\> $version = @{ Major = 1; Minor = 2; Patch = 3; Prerelease = 'alpha'; Buildmetadata = 'build' }
        PS C:\> ConvertTo-gSemVer @version

        1.2.3-alpha+build
    .EXAMPLE
        --- Example 4 By Pipeline ---
        PS C:\> $version = @{ Major = 1; Minor = 2; Patch = 3; Prerelease = 'alpha'; Buildmetadata = 'build' }
        PS C:\> $version | ConvertTo-gSemVer

        1.2.3-alpha+build
        PS C:\> $version = [PSCustomObject] $version
        PS C:\> $version | ConvertTo-gSemVer

        1.2.3-alpha+build
    .INPUTS
        System.Management.Automation.PSCustomObject
        
        System.Collections.Hashtable

        System.String
    .OUTPUTS
        System.String
    .NOTES
        For more information about Semantic Versioning 2.0.0, see this: https://semver.org/
    #>
    [CmdletBinding(DefaultParameterSetName = 'ByIdentifier')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'ByObject')]
        [PSCustomObject]
        $InputObject,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByIdentifier')]
        [string]
        $Major,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByIdentifier')]
        [string]
        $Minor,

        [Parameter(Mandatory = $true, ParameterSetName = 'ByIdentifier')]
        [string]
        $Patch,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByIdentifier')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Prerelease,

        [Parameter(Mandatory = $false, ParameterSetName = 'ByIdentifier')]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Buildmetadata
    )

    process {
        if ('ByObject' -eq $PSCmdlet.ParameterSetName) {
            if (-not ($InputObject -is [hashtable])) {
                $InputObject = $InputObject | ConvertTo-Json | ConvertFrom-Json -AsHashtable
            }

            return ConvertTo-gSemVer @InputObject
        }

        $value = "$Major.$Minor.$Patch"
        if ($Prerelease) {
            $value = "$value-$Prerelease"
        }

        if ($Buildmetadata) {
            $value = "$value+$Buildmetadata"
        }

        if (-not ($value -match $Script:GooSemVer.Rex)) {
            throw $Script:GooSemVer.InvalidVersionFormatMessage -f $value
        }

        return $value
    }
}
