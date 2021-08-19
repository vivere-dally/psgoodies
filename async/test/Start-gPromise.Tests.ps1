BeforeAll {
    $ErrorActionPreference = 'Stop'
    Import-Module "$PSScriptRoot/../dist/PromiseGoodies.psd1"
}

Describe "Start-gPromise" {
    It "executed" {
        Start-gPromise { $true } `
        | Complete-gPromise `
        | Should -BeTrue
    }

    It "argumentList" {
        Start-gPromise {
            param($a, $b, $c)

            $a, $b, $c
        } -ArgumentList 1, 2, 3 `
        | Complete-gPromise `
        | Should -Be 1, 2, 3
    }

    It "writeError" {
        $promise = Start-gPromise { Write-Error 123 }
        { $promise | Complete-gPromise } | Should -Throw -ExpectedMessage 123
    }

    It "throw" {
        $promise = Start-gPromise { throw 123 }
        { $promise | Complete-gPromise } | Should -Throw -ExpectedMessage "Exception: 123"
    }
}
