$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Start-gPromise" {
    It "executed" {
        Start-gPromise {
            $true
        } | Complete-gPromise | Should -BeTrue
    }

    It "argumentList" {
        Start-gPromise -ScriptBlock {
            param($a, $b, $c)

            $a, $b, $c
        } -ArgumentList 1, 2, 3 | Complete-gPromise | Should -Be 1, 2, 3
    }

    It "writeError" {
        $promise = { Write-Error 123 } | Start-gPromise
        { $promise | Complete-gPromise } | Should -Throw
    }

    It "throw" {
        $promise = { throw 123 } | Start-gPromise
        { $promise | Complete-gPromise } | Should -Throw
    }
}