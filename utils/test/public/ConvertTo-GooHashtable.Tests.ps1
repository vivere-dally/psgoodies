
Describe 'ConvertTo-gHashtable' {

    It 'Convert simple object' {
        # Arrange
        $expected = @{
            a = 1;
            b = 'two';
            c = $true;
            d = 12.34;
        }

        $pso = [PSCustomObject]$expected

        # Act
        $actual = $pso | ConvertTo-gHashtable
        $eqs = $actual | Compare-Object -ReferenceObject $expected -Property a, b, c, d -IncludeEqual -CaseSensitive | Select-Object -ExpandProperty SideIndicator

        # Assert
        $eqs | ForEach-Object { $_ | Should -Be '==' }
    }

    It 'Convert depth 1 object' {
        # Arrange
        $expected = @{
            a = 1;
            b = 'two';
            c = $true;
            d = 12.34;
            e = @{
                f = 2;
                g = 3;
            }
        }
        
        $pso = [PSCustomObject]@{
            a = 1;
            b = 'two';
            c = $true;
            d = 12.34;
            e = [PSCustomObject]@{
                f = 2;
                g = 3;
            }
        }
        
        # Act
        $actual = $pso | ConvertTo-gHashtable
        $eqs = $actual | Compare-Object -ReferenceObject $expected -Property a, b, c, d, e, f, g -IncludeEqual -CaseSensitive | Select-Object -ExpandProperty SideIndicator
        
        # Assert
        $eqs | ForEach-Object { $_ | Should -Be '==' }
    }

    It 'Convert depth 2 object' {
        # Arrange
        $expected = @{
            a = 1;
            b = 'two';
            c = $true;
            d = 12.34;
            e = @{
                f = 2;
                g = 3;
                h = @{
                    i = 123.123;
                    j = '123.123';
                }
            }
        }
        
        $pso = [PSCustomObject]@{
            a = 1;
            b = 'two';
            c = $true;
            d = 12.34;
            e = [PSCustomObject]@{
                f = 2;
                g = 3;
                h = [PSCustomObject]@{
                    i = 123.123;
                    j = '123.123';
                }
            }
        }
        
        # Act
        $actual = $pso | ConvertTo-gHashtable
        $eqs = $actual | Compare-Object -ReferenceObject $expected -Property a, b, c, d, e, f, g, h, i, j -IncludeEqual -CaseSensitive | Select-Object -ExpandProperty SideIndicator
        
        # Assert
        $eqs | ForEach-Object { $_ | Should -Be '==' }
    }
}
