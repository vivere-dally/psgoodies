function Get-gCommandEntryHelper {
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
        $IgnoreCommandEntries,

        [Parameter()]
        [AllowNull()]
        [psmoduleinfo]
        $ParentModuleInfo
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
            if (-not $commandInfo -and $ParentModuleInfo) {
                $commandInfo = & $ParentModuleInfo { Get-Command -Name $args[0] -ErrorAction SilentlyContinue } $commandName
            }

            if (-not $commandInfo) {
                throw "Could not find command $($commandName)"
            }

            if (-not ($commandInfo | Test-gCustomCommand)) {
                $IgnoreCommandEntries.Add($commandName) | Out-Null
                continue
            }

            $CommandEntries[$commandName] = $commandInfo | ConvertTo-gCommandEntry
            if ($commandInfo.ScriptBlock) {
                $commandInfo.ScriptBlock | Get-gCommandEntryHelper -CommandEntries $CommandEntries -IgnoreCommandEntries $IgnoreCommandEntries -ParentModuleInfo $commandInfo.Module
            }
        }
    }
}
