BeforeAll {
    $ErrorActionPreference = 'Stop'
    Import-Module "$PSScriptRoot/../dist/PromiseGoodies.psd1"
}

Describe "Use-gThen" {
    It "executed" {
        Start-gPromise { $false } `
        | Use-gThen { $true } `
        | Complete-gPromise `
        | Should -Be $true
    }

    It "not_executed" {
        Start-gPromise { throw; } `
        | Use-gThen { $false } `
        | Use-gCatch { $true } `
        | Complete-gPromise `
        | Should -Be $true
    }

    It "receive_params" {
        Start-gPromise { 1, 2, 3 } `
        | Use-gThen {
            param($a, $b, $c)

            $a++; $b++; $c++
            $a, $b, $c
        } `
        | Complete-gPromise `
        | Should -Be 2, 3, 4
    }

    It "propagate_params" {
        Start-gPromise { 1, 2, 3 } `
        | Use-gThen {
            param($a, $b, $c)

            $a++; $b++; $c++;
            $a, $b, $c
        } `
        | Use-gThen {
            param($a, $b, $c)

            $a++; $b++; $c++;
            $a, $b, $c
        } `
        | Complete-gPromise `
        | Should -Be 3, 4, 5
    }
}
