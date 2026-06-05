#!/usr/bin/pwsh

Set-StrictMode -Version Latest

$raw = [Console]::In.ReadToEnd()
$entry = [ordered]@{}

if (-not [string]::IsNullOrWhiteSpace($raw))
{
    $entry = $raw | ConvertFrom-Json -AsHashtable
}

$stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
# Canonical log home, independent of where this script is installed from.
$logRoot = Join-Path $HOME '.codex' 'logs' 'session-start'

if (-not (Test-Path -Path $logRoot))
{
    [void](New-Item -Path $logRoot -ItemType Directory -Force)
}

$jsonFileName = "$((Get-Date).Ticks)_Codex_SessionStart.json"
$logFile = Join-Path $logRoot $jsonFileName

[PSCustomObject]@{
    timestamp = $stamp
    agent     = 'Codex'
    event     = 'SessionStart'
    input     = $entry
} | ConvertTo-Json -Depth 20 | Set-Content -Path $logFile -Encoding utf8

Write-Output "Codex SessionStart hook log written to $($logFile.Replace($HOME, '~'))."
