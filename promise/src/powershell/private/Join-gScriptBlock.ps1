function Join-gScriptBlock {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Long description
    .EXAMPLE
        PS C:\> <example usage>
        Explanation of what the example does
    .INPUTS
        Inputs (if any)
    .OUTPUTS
        Output (if any)
    .NOTES
        $argumentList = @(1, 2, 3)
        $jointSB.Invoke($argumentList)
        & $jointSB @al
    #>
    [CmdletBinding()]
    [OutputType([scriptblock])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [scriptblock]
        $ParentScriptBlock,

        [Parameter(Mandatory = $true, Position = 1)]
        [scriptblock]
        $ChildScriptBlock
    )

    $jointScriptBlock = @"
param(`$Promise)

`$shouldSkip = `$false
`$argumentList = @(Invoke-Command -ScriptBlock {[psb]} -ArgumentList @(`$Promise, [ref]`$shouldSkip))

if (`$shouldSkip) {
    return `$argumentList
}

`$result = @(Invoke-Command -ScriptBlock {[csb]} -ArgumentList `$argumentList)

return `$result
"@

    $jointScriptBlock = $jointScriptBlock.Replace('[psb]', $ParentScriptBlock.ToString()).Replace('[csb]', $ChildScriptBlock.ToString())
    return [scriptblock]::Create($jointScriptBlock)
}
