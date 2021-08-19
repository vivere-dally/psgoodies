function Test-gCustomCommand {
    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        [System.Management.Automation.CommandInfo]
        $CommandInfo
    )

    if ([string]::IsNullOrEmpty($CommandInfo.Source)) {
        return $true
    }

    $modulePath = $CommandInfo.Module.Path.ToLowerInvariant()
    foreach ($psModulePath in $env:PSModulePath.Split(';')) {
        if ($modulePath.Contains($psModulePath.ToLowerInvariant())) {
            return $false
        }
    }

    return $true
}
