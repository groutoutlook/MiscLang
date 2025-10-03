shebang := if os() == 'windows' { 'pwsh.exe' } else { '/usr/bin/env pwsh' }
set shell := ["pwsh", "-c"]
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]
set script-interpreter := ["pwsh.exe", "-NoProfile","-NoLogo", "-Command"]
set dotenv-load
set unstable
set dotenv-filename	:= ".env"
# set dotenv-required := true
export JUST_ENV := "just_env" # WARN: this is also a method to export env var. 
_default:
    @just --list

help:
    @just --choose

alias roote :=root-edit
[working-directory: '']
root-edit:
    just -e
    
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

patch_folder := "patch"
alias crs := check-repo-status
[no-cd,script]
check-repo-status:
    gci |%{if($_.Attributes -eq "Directory" -and $_.BaseName -ne "{{patch_folder}}") {
        $_.BaseName && (git -C $_ st) | oh
    }
    else {"no need to check"}
    }

alias cp := create-patch
alias cpatch := create-patch
[no-cd,script]
create-patch:
    # created based on the uncommit tho.
    $final_name = "$(Get-Date -UFormat '%Y-%m-%d').patch"
    git stk -m "Patch on $(Get-Date)"
    git stash show -p > "./$final_name"
    gci $final_name | oh
    
alias mp := move-patch
[no-cd,script]
move-patch:
    # TODO: You may want to create patch first as well...
    mv -Path *patch -Destination ( "../{{patch_folder}}/$(split-path $pwd -Leaf)/" | % { ni $_ -ItemType Directory ; $destination = $_; write-output $_ }) -Force
    gci $destination | Out-Host


alias pu := pull-update
[script,no-cd]
pull-update:
    $depth = (pwd) -split '\\' | Tee -var split -ob 99 | % { $i = 0 }{ if ($_ -match "misclang") { $split.Count - $i;} else { $i++ } }
    $max_pull_depth = 3 
    $depthPattern = "*"+"/*"*[int]($max_pull_depth - $depth) 
    Write-Host "Currently $depthPattern" -ForegroundColor Green
    gci $depthPattern -Directory | % {Write-Host $_.BaseName -ForeGroundColor Cyan; git -C $_ pull}


alias rba := rebuild-all
[script, no-cd]
rebuild-all:
    gci | where { (Get-Date) - $_.LastWriteTime -lt (New-TimeSpan -Days 1) }
        | sort LastWriteTime
        | %{write-host $_.Name -Fore Blue;cd $_; just b; cd ..}