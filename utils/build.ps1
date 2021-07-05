$ErrorActionPreference = 'Stop'
$moduleName = 'UtilsGoodies'

Import-Module "$PSScriptRoot\src\$moduleName.psd1"

& "$PSScriptRoot\..\test.ps1" -Path "$PSScriptRoot\test"
