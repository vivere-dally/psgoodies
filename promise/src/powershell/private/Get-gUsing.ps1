function Get-gUsing {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.Dictionary[System.String, System.Object]])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [scriptblock]
        $ScriptBlock,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCmdlet]
        $ParentPSCmdlet
    )

    process {
        $usings = [System.Collections.Generic.Dictionary[System.String, System.Object]]::new()
        $usingAsts = $ScriptBlock.Ast.FindAll( { param($ast) $ast -is [System.Management.Automation.Language.UsingExpressionAst] }, $true) | ForEach-Object { $_ -as [System.Management.Automation.Language.UsingExpressionAst] }
        foreach ($usingAst in $usingAsts) {
            $varAst = $usingAst.SubExpression -as [System.Management.Automation.Language.VariableExpressionAst]
            if (-not $varAst) {
                throw "Could not determine the 'Using' expression $($usingAst.Extent.Text)"
            }

            $varValue = $ParentPSCmdlet.GetVariableValue($varAst.VariablePath.UserPath)
            if (-not $varValue) {
                throw "Could not determine the 'Using' variable $($usingAst.Extent.Text)"
            }

            $key = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($usingAst.ToString().ToLowerInvariant().ToCharArray()))
            if (-not $usings.ContainsKey($key)) {
                $usings[$key] = $varValue
            }
        }

        return , $usings
    }
}
