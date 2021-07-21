$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Use-gCatch" {
    It "executed" {
        Start-gPromise { throw 123; } `
        | Use-gCatch { return $true } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "not_executed" {
        Start-gPromise { return $true; } `
        | Use-gCatch { return $false } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "receive_error_from_writeError" {
        Start-gPromise { Write-Error 'myError' } `
        | Use-gCatch {
            param($err)

            return $err.Message
        } `
        | Complete-gPromise `
        | Should -BeLikeExactly '*myError*'
    }

    It "receive_error_from_throw" {
        Start-gPromise { throw 'myError' } `
        | Use-gCatch {
            param($err)

            $err.Message
        } `
        | Complete-gPromise `
        | Should -BeExactly 'myError'
    }
}
