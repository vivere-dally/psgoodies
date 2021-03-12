function New-GooSemVer {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $true)]
        [string]
        $Major,

        [Parameter(Mandatory = $true)]
        [string]
        $Minor,

        [Parameter(Mandatory = $true)]
        [string]
        $Patch,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Prerelease,

        [Parameter(Mandatory = $false)]
        [AllowEmptyString()]
        [AllowNull()]
        [string]
        $Buildmetadata
    )

    process {
        $value = "$Major.$Minor.$Patch"
        if ($Prerelease) {
            $value = "$value-$Prerelease"
        }

        if ($Buildmetadata) {
            $value = "$value+$Buildmetadata"
        }

        return $value
    }
}
