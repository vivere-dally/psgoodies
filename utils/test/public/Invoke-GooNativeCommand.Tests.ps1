
Describe 'Invoke-gNativeCommand' {

    It 'Throw 1' {
        { 'cmd.exe' | Invoke-gNativeCommand -CommandArgs '/c', 'exit 1' } | Should -Throw 1
    }

    It 'Does not throw' {
        { 'cmd.exe' | Invoke-gNativeCommand -CommandArgs '/c', 'exit 0' } | Should -Not -Throw
    }

    It 'Sum' {
        $sum = { 1 + 1 } | Invoke-gNativeCommand
        $sum | Should -Be 2
    }
}
