#!/usr/bin/pwsh

if($IsWindows){
    notepad (Join-Path $HOME '.claude' 'settings.json')
    notepad (Join-Path $HOME '.codex' 'hooks.json')
}
