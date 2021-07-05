[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [string]
    $Path
)

$config = [PesterConfiguration]::Default

$config.CodeCoverage.Enabled.Value = $true

$config.TestResult.Enabled.Value = $true

$config.Output.Verbosity.Value = 'Diagnostic'

$config.Run.Path = $Path
$config.Run.Exit.Value = $true

Invoke-Pester -Configuration $config

#Requires -Module @{ ModuleName = 'Pester'; RequiredVersion = '5.1.1' }
