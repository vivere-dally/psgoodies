class GooLogValidLevels : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return [string[]] $Script:GooLog.Levels
    }
}

function Write-gLog {
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [OutputType([string])]
    [OutputType($null)]
    param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeline = $true, ParameterSetName = 'Color')]
        [AllowNull()]
        [AllowEmptyString()]
        [string]
        $Message,

        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Color')]
        [ValidateSet([GooLogValidLevels])]
        [string]
        $Level = 'INFO',

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Color')]
        [switch]
        $NoNewline,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Color')]
        [switch]
        $NoDate,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Color')]
        [switch]
        $NoLevel,

        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Color')]
        [switch]
        $PassThru,

        [Parameter(Mandatory = $false, ParameterSetName = 'Color')]
        [System.ConsoleColor]
        $BackgroundColor,

        [Parameter(Mandatory = $false, ParameterSetName = 'Color')]
        [System.ConsoleColor]
        $ForegroundColor,

        [Parameter(ParameterSetName = 'Color')]
        [switch]
        $Ansi
    )

    process {
        $__date = if (-not $NoDate) {
            $dateParams = $Script:GooLog.Date
            "[$(Get-Date @dateParams)]"
        }

        $__level = if (-not $NoLevel) {
            "[$Level]"
        }

        $__message = (@($__date, $__level, $Message) | Where-Object { $null -ne $_ }) -join ' '
        if ($Script:GooLog.Path) {
            $__message | Add-Content -Path $Script:GooLog.Path -NoNewline:$NoNewline
        }

        $writeHostParams = @{
            NoNewLine = $NoNewline;
        }

        if ('Color' -eq $PSCmdlet.ParameterSetName) {
            if (Test-gLogAnsi $Ansi) {
                if ($BackgroundColor) {
                    $__message = $Script:GooLog.Ansi.Template -f ($Script:GooLog.Ansi.Colors[$BackgroundColor.value__] + 10), $__message, 49
                }

                if ($ForegroundColor) {
                    $__message = $Script:GooLog.Ansi.Template -f $Script:GooLog.Ansi.Colors[$ForegroundColor.value__], $__message, 39
                }
            }
            else {
                if ($BackgroundColor) {
                    $writeHostParams['BackgroundColor'] = $BackgroundColor
                }

                if ($ForegroundColor) {
                    $writeHostParams['ForegroundColor'] = $ForegroundColor
                }
            }
        }

        $__message | Write-Host @writeHostParams
        if ($PassThru) {
            return $__message
        }
    }
}
