function Reset-gLogSettings {
    [CmdletBinding()]
    [OutputType()]
    param ()

    $Global:gLogAnsiPreference = 'Unset'
    $Script:Levels = $Script:DefaultLevels
    $Script:Date = $Script:DefaultDate
}
