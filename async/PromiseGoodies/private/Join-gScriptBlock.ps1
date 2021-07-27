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
`$argumentList = @({[psb]}.Invoke(`$args))

if (`$argumentList.Count -eq 1 -and `$argumentList[0] -is [PSGoodies.Async.Model.Promise]) {
    return `$argumentList[0]
}

`$result = @({[csb]}.Invoke(`$argumentList))

return `$result
"@

    $jointScriptBlock = $jointScriptBlock.Replace('[psb]', $ParentScriptBlock.ToString()).Replace('[csb]', $ChildScriptBlock.ToString())
    return [scriptblock]::Create($jointScriptBlock)
}
