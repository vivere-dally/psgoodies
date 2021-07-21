function Promise {
    [CmdletBinding()]
    [OutputType()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $false, Position = 1)]
        [AllowEmptyCollection()]
        [object[]]
        $ArgumentList = @()
    )

    begin {
        # Load user defined commands
        $commandEntries = $ScriptBlock | Get-gCommandEntry

        # Load $using:* values
        $usings = $ScriptBlock | Get-gUsing
    }

    process {
    }

    end {
    }
}
