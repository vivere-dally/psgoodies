[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateScript( { ($_ | Test-Path) -and ($_ | Get-Item).Extension -eq '.psd1' } )]
    [string]
    $Name
)

if (-not (Test-Path env:PSGALLERY_API_KEY)) {
    Write-Error "PSGALLERY_API_KEY missing"
}

Publish-Module -Name $Name -NuGetApiKey $env:PSGALLERY_API_KEY
