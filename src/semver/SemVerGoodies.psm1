$ErrorActionPreference = 'Stop'

$publicfunctions = @(Get-ChildItem -Path "$PSScriptRoot\functions\public" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
foreach ($function in ($publicfunctions + @(Get-ChildItem -Path "$PSScriptRoot\functions\private" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue))) {
    try {
        . $function.FullName
    }
    catch {
        throw "Unable to dot source $($function.FullName)"
    }
}

New-Variable `
    -Name 'GooSemVer' `
    -Scope Script `
    -Option Constant `
    -Value ([hashtable]::Synchronized(@{
            Rex                                  = '^(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)(?:-(?<prerelease>(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+(?<buildmetadata>[0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$';
            InvalidVersionFormatMessage          = 'The value {0} is not following the SemVer guidelines.';
            InvalidResultingVersionFormatMessage = 'The resulted Version is in an invalid state {0}. The value {1} is not following the SemVer guidelines.';
        })) `
    -Description @"
    Rex                                  = RegEx for matching a SemVer string. See: https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
    InvalidVersionFormatMessage          = The error message that should be thrown when an invalid version is passed.
    InvalidResultingVersionFormatMessage = The error message that should be thrown when an invalid version is created.
"@

Export-ModuleMember -Function $publicfunctions.BaseName
