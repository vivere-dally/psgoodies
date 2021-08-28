$ErrorActionPreference = 'Stop'

New-Item -Path "$PSScriptRoot\dist" -ItemType Directory -Force | Out-Null
& 'dotnet' @('build',  "$PSScriptRoot\src", '-c', 'Release', '-o', "$PSScriptRoot\dist\bin")
if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
    Write-Error 'dotnet build error'
}

Remove-Item -Path "$PSScriptRoot\dist\bin\System.Management.Automation.dll"

Copy-Item -Path "$PSScriptRoot\src\powershell\*" -Destination "$PSScriptRoot\dist" -Recurse -Force
Import-Module "$PSScriptRoot\dist\PromiseGoodies.psd1" -Global -Force

& "$PSScriptRoot\..\test.ps1" -Path "$PSScriptRoot\test"
