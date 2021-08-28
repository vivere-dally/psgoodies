BeforeAll {
    $ErrorActionPreference = 'Stop'
    Import-Module "$PSScriptRoot/../dist/PromiseGoodies.psd1"
}

Describe "Use-gCatch" {
    It "executed" {
        Start-gPromise { throw } `
        | Use-gCatch { $true } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "not_executed" {
        Start-gPromise { $true } `
        | Use-gCatch { $false } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "receive_error_from_writeError" {
        Start-gPromise { Write-Error 'myError' } `
        | Use-gCatch {
            param($err)

            $err
        } `
        | Complete-gPromise `
        | Should -BeLikeExactly '*myError*'
    }

    It "receive_error_from_throw" {
        Start-gPromise { throw 'myError' } `
        | Use-gCatch {
            param($err)

            $err
        } `
        | Complete-gPromise `
        | Should -BeExactly 'myError'
    }
}
