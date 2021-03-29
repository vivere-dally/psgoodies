
Describe 'Use-GooRetryHandler' {

    It 'Throw' {
        $numberOfRetries = 1
        { { throw } | Use-GooRetryHandler -Retries $numberOfRetries -TimeoutSec 0 } | Should -Throw "ScriptBlock failed $numberOfRetries times!"
    }

    It 'Sum' {
        $sum = { 1 + 1 } | Use-GooRetryHandler
        $sum | Should -Be 2
    }
}
