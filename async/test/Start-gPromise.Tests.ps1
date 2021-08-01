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

    It "using" -Skip {
        $a = 1; $b = 2; $c = 3;
        Start-gPromise {
            $using:a, $using:b, $using:c
        } | Complete-gPromise | Should -Be 1, 2, 3
    }

    It "argumentList" {
        Start-gPromise -ScriptBlock {
            param($a, $b, $c)

            $a, $b, $c
        } -ArgumentList 1, 2, 3 | Complete-gPromise | Should -Be 1, 2, 3
    }

    It "writeError" {
        $promise = Start-gPromise { $ErrorActionPreference = 'Stop'; Write-Error 123 }
        { $promise | Complete-gPromise } | Should -Throw
    }

    It "throw" {
        $promise = Start-gPromise { throw 123 }
        { $promise | Complete-gPromise } | Should -Throw
    }
}
