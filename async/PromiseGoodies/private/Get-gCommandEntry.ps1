function Get-gCommandEntryInternal {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [hashtable]
        $CommandEntries,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[System.String]]
        $IgnoreCommandEntries
    )

    process {
        $commandAsts = $ScriptBlock.Ast.FindAll( { param($ast) $ast -is [System.Management.Automation.Language.CommandAst] }, $true)
        foreach ($commandAst in $commandAsts) {
            $commandName = $commandAst.GetCommandName()
            if (-not $commandName) {
                throw "Could not determine command name $($commandAst.Extent.Text)"
            }

            if ($CommandEntries.ContainsKey($commandName) -or $IgnoreCommandEntries.Contains($commandName)) {
                continue
            }

            $commandInfo = Get-Command -Name $commandName -ErrorAction SilentlyContinue
            if (-not $commandInfo) {
                throw "Could not find command $($commandName)"
            }

            if (-not ($commandInfo | Test-gCustomCommand)) {
                $IgnoreCommandEntries.Add($commandName) | Out-Null
                continue
            }

            $CommandEntries[$commandName] = $commandInfo | ConvertTo-gCommandEntry
            if ($commandInfo.ScriptBlock) {
                $commandInfo.ScriptBlock | Get-gCommandEntryInternal -CommandEntries $CommandEntries -IgnoreCommandEntries $IgnoreCommandEntries
            }
        }
    }
}

function Get-gCommandEntry {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[System.Management.Automation.Runspaces.SessionStateCommandEntry]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [scriptblock]
        $ScriptBlock
    )

    process {
        $commandEntries = [System.Collections.Generic.List[System.Management.Automation.Runspaces.SessionStateCommandEntry]]::new()
        $commandEntriesHt = @{}
        $ignoreCommandEntries = [System.Collections.Generic.HashSet[System.String]]::new()
        $ScriptBlock | Get-gCommandEntryInternal -CommandEntries $commandEntriesHt -IgnoreCommandEntries $ignoreCommandEntries
        $commandEntriesHt.Values | ForEach-Object { $commandEntries.Add($_) }
        return $commandEntries
    }
}
