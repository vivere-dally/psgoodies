function Invoke-GooNativeCommand {
    <#
    .SYNOPSIS
        Invoke a command
    .DESCRIPTION
        This cmdlet uses the Call Operator to run a command.
        If the $LASTEXITCODE automatic variable is different than 0, an error is thrown.
    .PARAMETER Command
        Command that will get ran
    .PARAMETER CommandArgs
        Arguments that will get passed to the command
    .EXAMPLE
        PS C:\> Invoke-GooNativeCommand 'cmd.exe' -CommandArgs @('/c', 'exit 1')
    .EXAMPLE
        PS C:\> 'cmd.exe' | Invoke-GooNativeCommand -CommandArgs '/c', 'exit 1'
    .EXAMPLE
        PS C:\> 'cmd.exe' | Invoke-GooNativeCommand -CommandArgs '/c', 'exit 1'

        VERBOSE: [Command   ] cmd.exe
        VERBOSE: [Arguments ] /c exit 1
        VERBOSE: [Exit code ] 1
        VERBOSE: [Total time] 0.0236452 s
    .EXAMPLE
        PS C:\> { 1 + 1 } | Invoke-GooNativeCommand

        2
    .NOTES
        This command is using the call operator (&) under the hood.
    #>
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [ValidateScript( { $_ -is [string] -or $_ -is [scriptblock] })]
        [object]
        $Command,
        
        [Parameter(Mandatory = $false)]
        [array]
        $CommandArgs
    )

    $stopWatch = [Diagnostics.Stopwatch]::StartNew()
    if ($CommandArgs) {
        & $Command $CommandArgs
    }
    else {
        & $Command
    }

    $stopWatch.Stop()
    "[Command   ] $($Command.ToString())" | Write-Verbose
    "[Arguments ] $($CommandArgs -join ' ')" | Write-Verbose
    "[Exit code ] $LASTEXITCODE" | Write-Verbose
    "[Total time] $($stopWatch.Elapsed.TotalSeconds) s" | Write-Verbose
    
    # A null/missing exit code is considered valid.
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) {
        throw $LASTEXITCODE
    }
}
