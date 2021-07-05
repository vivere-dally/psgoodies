$ErrorActionPreference = 'Stop'
$moduleName = 'SemVerGoodies'

Import-Module "$PSScriptRoot\src\$moduleName.psd1"

& "$PSScriptRoot\..\test.ps1" -Path "$PSScriptRoot\test"
