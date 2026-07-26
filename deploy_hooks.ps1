#!/usr/bin/pwsh

if($IsWindows){
    Copy-Item .\hooks\claude_session_start.ps1 ~\.claude\hooks\claude_session_start.ps1           
    notepad (Join-Path $HOME '.claude' 'settings.json')
    notepad (Join-Path $HOME '.codex' 'hooks.json')
}
