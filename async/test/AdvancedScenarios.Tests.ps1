$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "AdvancedScenarios" {
    It "1" {
        Start-gPromise { 1 } `
        | Use-gThen { param($a) $a++; $a } `
        | Use-gThen { param($b) $b++; $b } `
        | Use-gThen { param($c) throw $c } `
        | Use-gCatch { param($d) $e = [int]::Parse($d.Message); $e++; $e } `
        | Use-gThen { param($f) $f++; $f } `
        | Complete-gPromise `
        | Should -Be 5
    }

    It "2" -Skip {
        Start-gPromise { Invoke-WebRequest -Uri "https://randomuser.me/api/" } `
        | Use-gThen { param($response) $response | Select-Object -ExpandProperty Content | ConvertFrom-Json } `
        | Use-gThen { param($content) $content.results.Count }
        | Use-gCatch { 1 } `
        | Complete-gPromise `
        | Should -BeGreaterThan 0
    }
}
