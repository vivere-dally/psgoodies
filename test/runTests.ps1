#Requires -Module @{ ModuleName = 'Pester'; RequiredVersion = '5.1.1' }

$__pwd = $PSScriptRoot
$psGoodiesModules = ("$__pwd\..\src" | Resolve-Path).Path | Get-ChildItem  -Filter "*.psd1" -Recurse | Select-Object -ExpandProperty FullName
Import-Module $psGoodiesModules -Force

$config = [PesterConfiguration]::Default
$config.TestResult.Enabled.Value = $true
$config.Output.Verbosity.Value = 'Detailed'
Invoke-Pester -Configuration $config
