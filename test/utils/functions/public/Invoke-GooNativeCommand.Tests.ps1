
Describe 'Invoke-GooNativeCommand' {

    It 'Throw 1' {
        { 'cmd.exe' | Invoke-GooNativeCommand -CommandArgs '/c', 'exit 1' } | Should -Throw 1
    }

    It 'Does not throw' {
        { 'cmd.exe' | Invoke-GooNativeCommand -CommandArgs '/c', 'exit 0' } | Should -Not -Throw
    }

    It 'Sum' {
        $sum = { 1 + 1 } | Invoke-GooNativeCommand
        $sum | Should -Be 2
    }
}
