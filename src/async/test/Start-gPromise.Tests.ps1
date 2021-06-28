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
            $true | Should -BeTrue
        }
    }

    It "argumentList" {
        Start-gPromise -ScriptBlock {
            param($a, $b, $c)

            $a, $b, $c | Should -Be 1, 2, 3
        } -ArgumentList 1, 2, 3
    }

    It "return" {
        $promise = { return 123 } | Start-gPromise
        $promise | Complete-gPromise | Should -Be 123
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
