
function ConvertTo-GooFlattenHashtable {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [hashtable]
        $Hashtable,

        [Parameter(Mandatory = $false)]
        [uint]
        $Depth = 2
    )
    begin {
        class __Item {
            [int] $Depth;
            [string] $ParentKey;
            [hashtable] $Hashtable;
            __Item([int] $depth, [string] $parentKey, [hashtable] $hashtable) {
                $this.Depth = $depth
                $this.ParentKey = $parentKey
                $this.Hashtable = $hashtable
            }
        }

        $q = [System.Collections.Queue]::new()
    }

    process {
        $root = @{}
        $Hashtable.Keys | ForEach-Object {
            if ($Hashtable.$_ -is [hashtable]) {
                $q.Enqueue([__Item]::new(1, $_, $Hashtable.$_))
            }
            else {
                $root.$_ = $Hashtable.$_
            }
        }

        $depthExceeded = $false
        while (0 -lt $q.Count) {
            [__Item]$__it = $q.Dequeue()
            if ($Depth -eq $__it.Depth) {
                $__it.Hashtable.Keys | ForEach-Object {
                    if ($__it.Hashtable.$_ -is [hashtable]) {
                        if (-not $depthExceeded) {
                            "Resulting HASHTABLE is truncated as serialization has exceeded the set depth of $Depth." | Write-Warning
                        }
        
                        $depthExceeded = $true
                    }
                    $root.("$($__it.ParentKey).$_") = $__it.Hashtable.$_
                }
            }
            else {
                $__it.Hashtable.Keys | ForEach-Object {
                    if ($__it.Hashtable.$_ -is [hashtable]) {
                        $q.Enqueue([__Item]::new($__it.Depth + 1, "$($__it.ParentKey).$_", $__it.Hashtable.$_))
                    }
                    else {
                        $root.("$($__it.ParentKey).$_") = $__it.Hashtable.$_
                    }
                }
            }
        }

        return $root
    }
}

@{a = 0; b = @{c = 1; d = @{e = 2; f = @{g = 3; } } } } | ConvertTo-GooFlattenHashtable
