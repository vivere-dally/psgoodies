$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Use-gFinally" {
    It "executed" {
        $var = $false

        Start-gPromise { } `
        | Use-gFinally { ([ref]$var).Value = $true } `
        | Complete-gPromise `

        $var | Should -BeTrue
    }

    It "executed_then" {
        $var = $false

        Start-gPromise { } `
        | Use-gThen { } `
        | Use-gFinally { ([ref]$var).Value = $true } `
        | Complete-gPromise

        $var | Should -BeTrue
    }

    It "executed_catch" {
        $var = $false

        Start-gPromise { throw } `
        | Use-gCatch { } `
        | Use-gFinally { ([ref]$var).Value = $true } `
        | Complete-gPromise

        $var | Should -BeTrue
    }

    It "executed_both" {
        $var = $false

        Start-gPromise { } `
        | Use-gThen { } `
        | Use-gCatch { } `
        | Use-gFinally { ([ref]$var).Value = $true } `
        | Complete-gPromise

        $var | Should -BeTrue
    }
}
