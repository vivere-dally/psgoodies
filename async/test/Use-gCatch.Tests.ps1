$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Use-gCatch" {
    It "executed" {
        { throw 123; } `
        | Start-gPromise `
        | Use-gCatch { return $true } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "not_executed" {
        { return $true; } `
        | Start-gPromise `
        | Use-gCatch { return $false } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "receive_error_from_writeError" {
        { Write-Error 'myError' } `
        | Start-gPromise `
        | Use-gCatch {
            param($err)

            return $err.Message
        } `
        | Complete-gPromise `
        | Should -BeLikeExactly '*myError*'
    }

    It "receive_error_from_throw" {
        { throw 'myError' } `
        | Start-gPromise `
        | Use-gCatch {
            param($err)

            $err.Message
        } `
        | Complete-gPromise `
        | Should -BeExactly 'myError'
    }
}
