$ErrorActionPreference = 'Stop'
$moduleName = 'PromiseGoodies'

& 'dotnet' @('build',  "$PSScriptRoot\src", '-o', "$PSScriptRoot\output\$moduleName\bin")
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Error 'dotnet build error'
}

Copy-Item -Path "$PSScriptRoot\$moduleName\*" -Destination "$PSScriptRoot\output\$moduleName" -Recurse -Force
Import-Module "$PSScriptRoot\output\$moduleName\$moduleName.psd1"

& "$PSScriptRoot\..\test.ps1" -Path "$PSScriptRoot\test"
