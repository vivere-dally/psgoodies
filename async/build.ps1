$ErrorActionPreference = 'Stop'
$moduleName = 'PromiseGoodies'

New-Item -Path "$PSScriptRoot\output" -ItemType Directory -Force | Out-Null
& 'dotnet' @('build',  "$PSScriptRoot\src", '-o', "$PSScriptRoot\output\bin")
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Error 'dotnet build error'
}

Copy-Item -Path "$PSScriptRoot\$moduleName\*" -Destination "$PSScriptRoot\output" -Recurse -Force
Import-Module "$PSScriptRoot\output\$moduleName.psd1" -Global -Force

& "$PSScriptRoot\..\test.ps1" -Path "$PSScriptRoot\test"
