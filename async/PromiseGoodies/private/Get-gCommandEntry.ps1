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
        $ScriptBlock | Get-gCommandEntryHelper -CommandEntries $commandEntriesHt -IgnoreCommandEntries $ignoreCommandEntries
        $commandEntriesHt.Values | ForEach-Object { $commandEntries.Add($_) }
        return , $commandEntries
    }
}
