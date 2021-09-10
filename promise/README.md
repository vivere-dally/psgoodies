# PromiseGoodies

A PowerShell module for running Promise-like jobs.



The Promise Job has the same properties as a [ThreadJob](https://github.com/PaulHigin/PSThreadJob), but it also automatically imports the user defined functions into the Job session.

## Features

### $Using:

You can use values defined outside of the `Promise` by using the [Using](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_remote_variables?view=powershell-7.1) scope.

### Promise Chaining

You can chain promises, for example this

```powershell
$promise = Start-gPromise {
	Write-Host 'promise'
	Start-Sleep -Seconds 1
} | Use-gThen {
	Write-Host 'then'
	Start-Sleep -Seconds 1
} | Use-gFinally {
	Write-Host 'finally'
	Start-Sleep -Seconds 1
}

Write-Host 'hello world'

<# Prints
hello world
promise
then
finally
#>
```

### Automatic Function Import

Functions defined by the user are automatically imported into the `Promise` scope if it's used. For example:

```powershell
function foo {
	param($number)
	
	Write-Host "foo $number"
}

$promise = Start-gPromise {
	foo 123
}

<# Prints
foo 123
#>
```

The custom aliases are also imported. For example:

```powershell
function Use-FooCmdlet {
	[CmdletBinding()]
	[Alias('foo')]
	param($number)
	
	Write-Host "foo $number"
}

$promise = Start-gPromise {
	Use-FooCmdlet 123
	foo 123
}

<# Prints
foo 123
foo 123
#>
```

The user may define script modules and could not export certain function. For example the functions `foo` and `bar` are defined, but only `bar` is exported for the module. `bar` uses `foo` when executing. In this case, `foo` is also imported, even though it is private.

Define `test.psm1`:

```powershell
function foo {
	param($number)
	
	Write-Host "foo $number"
}

function bar {
	param($number)
	
	Write-Host "bar $number"
	foo $number
}

Export-ModuleMember -Function bar
```

Then you can use this module as usual without having to worry about such cases.

```powershell
Import-Module test.psm1

$promise = Start-gPromise {
	bar 123
}

<# Prints
bar 123
foo 123
#>
```

Take into account that you can't use `foo` by itself. It is still private, but the `Promise` can use it indirectly by running `bar`.

### Convenience

Every `Promise` writes to the same `PSHost` that they were created in. Moreover, the path in which the `Promises` are running is the current path.

```powershell
cd "C:/foo/bar/baz"
Write-Host $pwd
Start-gPromise {
	Write-Host $pwd
}

<# Prints
C:/foo/bar/baz
C:/foo/bar/baz
#>
```



## Credits

This module is highly inspired by the [PSThreadJob](https://github.com/PaulHigin/PSThreadJob) and [PoshRSJob](https://github.com/proxb/PoshRSJob) modules.

