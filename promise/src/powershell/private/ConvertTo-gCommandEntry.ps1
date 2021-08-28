function ConvertTo-gCommandEntry {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Runspaces.SessionStateCommandEntry])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Management.Automation.CommandInfo]
        $CommandInfo
    )

    process {
        switch ($CommandInfo.CommandType) {
            Alias {
                [System.Management.Automation.Runspaces.SessionStateAliasEntry]::new($CommandInfo.Name, $CommandInfo.Definition)
                break
            }

            Function {
                [System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new($CommandInfo.Name, $CommandInfo.Definition)
                break
            }

            default {
                throw "The command $commandName is not a function or an alias"
            }
        }
    }
}
