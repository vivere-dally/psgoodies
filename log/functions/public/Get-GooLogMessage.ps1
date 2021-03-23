function Get-GooLogMessage {
    [CmdletBinding(DefaultParameterSetName = 'Separator')]
    [OutputType([string])]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Stage')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Step')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Separator')]
        [char]
        $Character = '-',

        [Parameter(Mandatory = $false, ParameterSetName = 'Stage')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Separator')]
        [int]
        $Length = 72,

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Step')]
        [string]
        $Value,

        [Parameter(ParameterSetName = 'Stage')]
        [switch]
        $Stage,

        [Parameter(ParameterSetName = 'Step')]
        [switch]
        $Step,

        [Parameter(ParameterSetName = 'Separator')]
        [switch]
        $Separator
    )

    if ($PSCmdlet.ParameterSetName -in @('Stage', 'Step')) {
        $caller = Get-PSCallStack | Select-Object -Skip 1 -First 1
        $functionName = $caller.FunctionName
        $scriptName = try { ($caller.ScriptName | Get-Item).BaseName } catch { 'terminal' }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Stage' {
            $Value = "[ ${functionName}:${scriptName} ]"
            $fullPadLength = $Length - $Value.Length
            $leftPadLength = [int]($fullPadLength / 2) + $Value.Length
            $Value = $Value.PadLeft($leftPadLength, $Character)
            $Value = $Value.PadRight($Length, $Character)
            return $Value
        }

        'Step' {
            return "$($Character.ToString() * 3) $Value ($functionName) @ $scriptName $($Character.ToString() * 3)"
        }

        'Separator' {
            return ''.PadLeft($Length, $Character)
        }
    }
}
