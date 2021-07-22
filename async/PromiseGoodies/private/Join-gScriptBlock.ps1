function Join-gScriptBlock {
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
[System.Object[]]`$argumentList = {[psb]}.Invoke(`$args)
[System.Object[]]`$result = {[csb]}.Invoke(`$argumentList)
return `$result
"@

    $jointScriptBlock = $jointScriptBlock.Replace('[psb]', $ParentScriptBlock.ToString()).Replace('[csb]', $ChildScriptBlock.ToString())
    return [scriptblock]::Create($jointScriptBlock)
}
