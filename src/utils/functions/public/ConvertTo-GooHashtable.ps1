
function ConvertTo-GooHashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [PSCustomObject]
        $PSCustomObject
    )
    begin {
        $q = [System.Collections.Generic.Queue[System.Tuple[[hashtable], [PSCustomObject]]]]::new()
    }

    process {
        $root = @{}
        $q.Enqueue([System.Tuple[[hashtable], [PSCustomObject]]]::new($root, $PSCustomObject))
        while (0 -lt $q.Count) {
            [System.Tuple[[hashtable], [PSCustomObject]]]$item = $q.Dequeue()
            foreach ($nvp in $item.Item2.PSObject.Properties) {
                if ($nvp.Value -is [PSCustomObject]) {
                    $value = @{}
                    $q.Enqueue([System.Tuple[[hashtable], [PSCustomObject]]]::new($value, $nvp.Value))
                }
                else {
                    $value = $nvp.Value
                }

                $item.Item1.($nvp.Name) = $value
            }
        }

        return $root
    }
}
