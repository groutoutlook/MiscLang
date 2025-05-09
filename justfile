shebang := if os() == 'windows' { 'pwsh.exe' } else { '/usr/bin/env pwsh' }
set shell := ["pwsh", "-c"]
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]
set script-interpreter := ["pwsh.exe", "-NoLogo", "-Command"]
set dotenv-load
set unstable
set dotenv-filename	:= ".env"
# set dotenv-required := true
export JUST_ENV := "just_env" # WARN: this is also a method to export env var. 
help:
    @just --list -f "{{home_directory()}}/justfile"

alias f := find
[script]
find nest_level="3":
    Clear-Content project_name.txt
    Get-ChildItem -Directory -Recurse | Where-Object {
        ($_.FullName -split '\\').Count -eq ($PWD.Path -split '\\').Count + {{nest_level}}
    } | ForEach-Object {
        $_.FullName.Substring($PWD.Path.Length + 1) >> project_name.txt
    }
alias j := jump
[script]
jump:
    cat .\project_name.txt | fzf | % { Write-Output $_} 
    | % { [System.Windows.Forms.SendKeys]::SendWait("cd $($_.ToString())") }

alias fmt := format
format args="nothing":
    # format something as `biome format --write`

# INFO: basic `run` recipe.
alias r := run
default_args := 'args here'
run args=default_args:
    @Write-Host {{default_args}} -ForegroundColor Red

var_test := "test format"
alias t := test
test:
    # also something directly test behaviour.
