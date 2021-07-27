function Join-gFinallyScriptBlock {
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
`$promise = @({[psb]}.Invoke(`$args))

{[csb]}.Invoke() | Out-Null

return `$promise
"@

    $jointScriptBlock = $jointScriptBlock.Replace('[psb]', $ParentScriptBlock.ToString()).Replace('[csb]', $ChildScriptBlock.ToString())
    return [scriptblock]::Create($jointScriptBlock)
}
