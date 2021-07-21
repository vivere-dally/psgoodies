
Describe 'Use-gRetryHandler' {

    It 'Throw' {
        $numberOfRetries = 1
        { { throw } | Use-gRetryHandler -Retries $numberOfRetries -TimeoutSec 0 } | Should -Throw "ScriptBlock failed $numberOfRetries times!"
    }

    It 'Sum' {
        $sum = { 1 + 1 } | Use-gRetryHandler
        $sum | Should -Be 2
    }
}
