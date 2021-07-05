filter isNumericIdentifier {
    [UInt32] $uIntHolder = $null
    return [UInt32]::TryParse($_, [ref] $uIntHolder)
}
