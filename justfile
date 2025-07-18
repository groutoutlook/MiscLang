shebang := if os() == 'windows' { 'pwsh.exe' } else { '/usr/bin/env pwsh' }
set shell := ["pwsh", "-c"]
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]
set script-interpreter := ["pwsh.exe", "-NoLogo", "-Command"]
set dotenv-load
set unstable
set dotenv-filename	:= ".env"
# set dotenv-required := true
export JUST_ENV := "just_env" # WARN: this is also a method to export env var. 
_default:
    @just --list

help:
    @just --choose

alias f := find
[script]
find nest_level="3":
    Clear-Content project_name.md
    Get-ChildItem -Directory -Recurse | Where-Object {
        ($_.FullName -split '\\').Count -eq ($PWD.Path -split '\\').Count + {{nest_level}}
    } | ForEach-Object {
        "- $($_.FullName.Substring($PWD.Path.Length + 1))`n" >> project_name.md
    }
    
alias j := jump
[script]
jump:
    cat .\project_name.md | fzf | % { Write-Output $_} 
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


# INFO: it's heere mostly because historic reason.
alias td := track_dir
[script]
track_dir:
    Get-ChildItem -Directory -Recurse | Where-Object {
        ($_.FullName -split '\\').Count -eq ($PWD.Path -split '\\').Count + 2
    } | ForEach-Object {
        $keepingDir = "$_/.keep"
        New-Item $keepingDir -Force
        git add $keepingDir --force
    }
