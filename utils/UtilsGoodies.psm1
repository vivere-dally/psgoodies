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

Export-ModuleMember -Function $publicfunctions.BaseName
