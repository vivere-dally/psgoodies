
function ConvertTo-GooFlattenHashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [psobject]
        $InputObject,

        [Parameter(Mandatory = $false)]
        [uint]
        $Depth = 2
    )
    begin {
        class __Item {
            [string] $ParentKey;
            [hashtable] $Hashtable;
            __Item([string] $parentKey, [hashtable] $hashtable) {
                $this.ParentKey = $parentKey
                $this.Hashtable = $hashtable
            }
        }

        $q = [System.Collections.Queue]::new()
    }

    process {
        $ht = $InputObject | ConvertTo-GooHashtable -Depth $Depth
        $q.Enqueue([__Item]::new('', $ht))
        $root = @{}
        while (0 -lt $q.Count) {
            [__Item]$__item = $q.Dequeue()
            $__item.Hashtable.Keys | ForEach-Object {
                $__key = ([string]::IsNullOrEmpty($__item.ParentKey)) ? $_ : "$($__item.ParentKey).$_"
                if ($__item.Hashtable.$_ -is [hashtable]) {
                    $q.Enqueue([__Item]::new($__key, $__item.Hashtable.$_))
                }
                else {
                    $root[$__key] = $__item.Hashtable.$_
                }
            }
        }

        return $root
    }
}
