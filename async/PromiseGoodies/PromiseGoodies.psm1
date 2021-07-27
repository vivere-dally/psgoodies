$ErrorActionPreference = 'Stop'

$publicFunctions, $privateFunctions = @("$PSScriptRoot/public", "$PSScriptRoot/private") | ForEach-Object {
    , @(Get-ChildItem -Path $_ -Filter *.ps1 -Recurse)
}

foreach ($function in ($publicFunctions + $privateFunctions)) {
    try {
        . $function.FullName
    }
    catch {
        throw "Unable to dot source $($function.FullName)"
    }
}

Export-ModuleMember -Function $publicFunctions.BaseName
