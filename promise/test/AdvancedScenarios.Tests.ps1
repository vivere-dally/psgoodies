BeforeAll {
    $ErrorActionPreference = 'Stop'
    Import-Module "$PSScriptRoot/../dist/PromiseGoodies.psd1"
}

Describe "AdvancedScenarios" {

    It "using" {
        $a = 1; $b = 2; $c = 3; $d = 'str';
        Start-gPromise { $using:a } `
        | Use-gThen { param($a) $a, $using:b } `
        | Use-gThen { param($a, $b) throw $a, $b, $using:c } `
        | Use-gCatch { param($err) "$err $using:d" } `
        | Complete-gPromise `
        | Should -Be '1 2 3 str'
    }

    It "web_request" {
        if (-not (Test-NetConnection).PingSucceeded) {
            $true | Should -BeTrue
            return
        }

        Start-gPromise { Invoke-WebRequest -Uri "https://randomuser.me/api/" } `
        | Use-gThen { param($response) $response | Select-Object -ExpandProperty Content | ConvertFrom-Json } `
        | Use-gThen { param($content) $content.results.Count } `
        | Use-gCatch { 1 } `
        | Complete-gPromise `
        | Should -BeGreaterThan 0
    }
}
