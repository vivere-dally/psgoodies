$prevErrorActionPreference = $ErrorActionPreference
BeforeAll {
    $ErrorActionPreference = 'Stop'
}

AfterAll {
    $ErrorActionPreference = $prevErrorActionPreference
}

Describe "Use-gThen" {
    It "executed" {
        {} | Start-gPromise | Use-gThen { $true | Should -Be $true }
    }

    It "not_executed" {
        { throw; } | Start-gPromise | Use-gThen { $false | Should -Be $true }
    }

    It "receive_params" {
        { return 1, 2, 3 } | Start-gPromise | Use-gThen {
            param($a, $b, $c)

            $a, $b, $c | Should -Be 1, 2, 3
        }
    }

    It "propagate_params" {
        { return 1, 2, 3 } | Start-gPromise | Use-gThen {
            param($a, $b, $c)

            $a++; $b++; $c++;
            return $a, $b, $c
        } | Use-gThen {
            param($a, $b, $c)

            $a, $b, $c | Should -Be 2, 3, 4
        }
    }
}
