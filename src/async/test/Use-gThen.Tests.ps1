$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Use-gThen" {
    It "executed" {
        {} `
        | Start-gPromise `
        | Use-gThen { $true } `
        | Complete-gPromise `
        | Should -Be $true
    }

    It "not_executed" {
        { throw; } `
        | Start-gPromise `
        | Use-gThen { $false } `
        | Use-gCatch { $true } `
        | Complete-gPromise `
        | Should -Be $true
    }

    It "receive_params" {
        { 1, 2, 3 } `
        | Start-gPromise `
        | Use-gThen {
            param($a, $b, $c)

            $a++; $b++; $c++
            $a, $b, $c
        } `
        | Complete-gPromise `
        | Should -Be 2, 3, 4
    }

    It "propagate_params" {
        { 1, 2, 3 } `
        | Start-gPromise `
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
