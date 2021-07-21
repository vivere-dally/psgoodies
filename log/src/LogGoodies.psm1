$ErrorActionPreference = 'Stop'

$local:publicfunctions = @(Get-ChildItem -Path "$PSScriptRoot\functions\public" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue)
foreach ($function in ($local:publicfunctions + @(Get-ChildItem -Path "$PSScriptRoot\functions\private" -Filter *.ps1 -Recurse -ErrorAction SilentlyContinue))) {
    try {
        . $function.FullName
    }
    catch {
        throw "Unable to dot source $($function.FullName)"
    }
}

New-Variable -Name DefaultLevels -Option Constant -Scope Script -Value @{
    INFO    = $null;
    WARNING = [System.ConsoleColor]::Yellow;
    ERROR   = [System.ConsoleColor]::Red;
}

New-Variable -Name Ansi -Option Constant -Scope Script -Value @{
    Colors   = @(30, 34, 32, 36, 31, 35, 33, 37, 90, 94, 92, 96, 91, 95, 93, 97);
    Template = "`e[{0}m{1}`e[{2}m";
}

New-Variable -Name DefaultDate -Option Constant -Scope Script -Value @{
    Format = 'G';
    AsUTC  = $true;
}

$Script:Levels = $Script:DefaultLevels
$Script:Date = $Script:DefaultDate

New-Variable `
    -Name 'GooLog' `
    -Scope Script `
    -Option Constant `
    -Value ([hashtable]::Synchronized(@{
            Path   = @();
            Levels = @('INFO', 'WARNING', 'ERROR');
            Date   = @{
                UFormat = "%F %T";
                AsUTC   = $true;
            };
            Ansi   = @{
                Colors   = @(30, 34, 32, 36, 31, 35, 33, 37, 90, 94, 92, 96, 91, 95, 93, 97);
                Template = "`e[{0}m{1}`e[{2}m";
            };
        })) `
    -Description @"
"@

$Global:gLogAnsiPreference = 'Unset'
Export-ModuleMember -Function $local:publicfunctions.BaseName
