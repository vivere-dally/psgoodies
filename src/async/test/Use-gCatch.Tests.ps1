$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Use-gCatch" {
    It "executed" {
        $result = { throw 123; } | Start-gPromise | Use-gCatch { return $true } | Complete-gPromise
        $result | Should -BeTrue
    }

    It "not_executed" {
        $result = { return $true; } | Start-gPromise | Use-gCatch { return $false } | Complete-gPromise
        $result | Should -BeTrue
    }

    It "receive_error_from_writeError" {
        $result = { Write-Error 'myError' } | Start-gPromise | Use-gCatch {
            param($err)

            return $err.Message
        } | Complete-gPromise

        $result | Should -BeLikeExactly '*myError*'
    }

    It "receive_error_from_throw" {
        $result = { throw 'myError' } | Start-gPromise | Use-gCatch {
            param($err)

            $err.Message
        } | Complete-gPromise

        $result | Should -BeExactly 'myError'
    }
}
