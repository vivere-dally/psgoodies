function Reset-GooLogSettings {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [CmdletBinding()]
    [OutputType()]
    param ()

    $global:GooLogAnsiPreference = 'Unset'
    $Script:GooLog.Path = @()
    $Script:GooLog.Levels = @('INFO', 'WARNING', 'ERROR')
    $Script:GooLog.Date = @{
        UFormat = "%F %T";
        AsUTC   = $true;
    };
}
