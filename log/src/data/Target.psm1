class LogTarget {
    LogTarget() {
        if ($this -is [LogTarget]) {
            throw("Class $($this.GetType()) must be inherited")
        }
    }

    [void] Write([string] $message) {
        throw("Must override method")
    }
}

class FileTarget : LogTarget {
    hidden [string] $__Path

    FileTarget([string] $path, [bool] $create = $false) {
        if ($create) {
            $this.__CreateFile()
        }

        $this.__Path = $path
    }

    hidden [void] __CreateFile() {
        if (Test-Path -Path $this.__Path) {
            return
        }

        if (-not (Test-Path -Path $this.__Path -PathType Leaf -IsValid)) {
            throw("The path is not a valid log file")
        }

        New-Item -Path $this.__Path -ItemType File -Force | Out-Null
    }

    [void] Write([string] $message) {
        Add-Content -Path $this.__Path -Value $message
    }
}

