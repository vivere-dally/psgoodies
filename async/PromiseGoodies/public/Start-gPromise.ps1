function Start-gPromise {
    <#
    .SYNOPSIS
        Start a Promise.
    .DESCRIPTION
        The Start-gPromise cmdlet starts a PowerShell background job on the local computer similar to Start-Job and Start-ThreadJob.

        Similar to Start-ThreadJob, the values specified by the $using scope are used.
        Similar to Start-RSJob, functions and aliases are imported into the Promise, but in an automatic manner.

        The Start-gPromise cmdlet will start a job which will use the current PSHost.
    .EXAMPLE
        PS C:\> Start-gPromise { Write-Host 'hello world' }

        hello world
    .EXAMPLE
        PS C:\> $x = 1
        PS C:\> Start-gPromise { Write-Host "x = $using:x" }

        x = 1
    .EXAMPLE
        PS C:\> function foo { param($p) Write-Host "foo: $p" }
        PS C:\> Start-gPromise { foo "x = $using:x" }

        foo: x = 1
    .INPUTS
        System.Management.Automation.PSCustomObject[]
    .OUTPUTS
        PSGoodies.PromiseGoodies.Model.Promise
    .NOTES
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/start-job
        https://docs.microsoft.com/en-us/powershell/module/threadjob/start-threadjob
        https://github.com/proxb/PoshRSJob
    #>
    [CmdletBinding(DefaultParameterSetName = 'Pipeline')]
    [Alias('Start-Promise', 'Promise', 'gPromise')]
    [OutputType([PSGoodies.PromiseGoodies.Model.Promise])]
    param (
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = 'Position')]
        [AllowEmptyCollection()]
        [psobject[]]
        $ArgumentList = @(),

        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Pipeline')]
        [Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'Position')]
        [scriptblock]
        $ScriptBlock
    )

    begin {
        # Load user defined commands
        $commandEntries = $ScriptBlock | Get-gCommandEntry

        # Load $using:* values
        $usings = $ScriptBlock | Get-gUsing -ParentPSCmdlet $PSCmdlet
    }

    process {
        $ScriptBlock | Start-gInternalPromise -CommandEntries $commandEntries -Usings $usings -ArgumentList $ArgumentList
    }
}
