#!/usr/bin/pwsh

param(
    [string]$ClaudeSkillPath = (Join-Path -Path $HOME -ChildPath '.claude' -AdditionalChildPath 'skills'),
    [string]$GeminiSkillPath = (Join-Path -Path $HOME -ChildPath '.gemini' -AdditionalChildPath 'skills'),
    [string]$CodexSkillPath  = (Join-Path -Path $HOME -ChildPath '.codex'  -AdditionalChildPath 'skills'),

    [string]$ClaudeCommandPath = (Join-Path -Path $HOME -ChildPath '.claude' -AdditionalChildPath 'commands'),
    [string]$GeminiCommandPath = (Join-Path -Path $HOME -ChildPath '.gemini' -AdditionalChildPath 'commands'),
    [string]$CodexCommandPath  = (Join-Path -Path $HOME -ChildPath '.codex'  -AdditionalChildPath 'commands')
)

$skillsRoot = Join-Path $PSScriptRoot 'skills'
$zipStaging = Join-Path $PSScriptRoot 'Generated' 'zip'
$targets = @($ClaudeSkillPath, $GeminiSkillPath, $CodexSkillPath)

#### 1. Zip each skill
#### One zip per skill, staged under gen/zip/. Staging is wiped first so re-runs are clean.

Write-Host '=== Stage 1: Zip each skill ===' -ForegroundColor Cyan
if (Test-Path $zipStaging) {
    Remove-Item $zipStaging -Recurse -Force
}
[void](New-Item -ItemType Directory -Force -Path $zipStaging)

$skillFolders = Get-ChildItem $skillsRoot -Directory
foreach ($skill in $skillFolders) {
    $zipPath = Join-Path $zipStaging "$($skill.Name).zip"
    Compress-Archive -Path $skill.FullName -DestinationPath $zipPath -Force
    Write-Host "Stage 1: $($skill.Name) zipped"
}

#### 2. Deploy
#### Clean replace into each local skill root. The unpacked skill and its staged zip both land.

Write-Host "`n=== Stage 2: Deploy ===" -ForegroundColor Cyan
Write-Host "Stage 2: deploying $($skillFolders.Count) skills to $($targets.Count) targets"

foreach ($target in $targets) {
    if (-not (Test-Path $target)) {
        Write-Warning "Creating $($target.Replace($HOME, '~'))"
        [void](New-Item -Path $target -ItemType Directory -Force)
    }

    foreach ($skill in $skillFolders) {
        $destination = Join-Path $target $skill.Name
        $stagedZip = Join-Path $zipStaging "$($skill.Name).zip"
        $zipDest = Join-Path $target "$($skill.Name).zip"

        if (Test-Path $destination) { Remove-Item $destination -Recurse -Force }
        if (Test-Path $zipDest)     { Remove-Item $zipDest -Force }

        Copy-Item -Path $skill.FullName -Destination $target -Recurse -Force
        Copy-Item -Path $stagedZip -Destination $zipDest -Force
    }

    Write-Host "Stage 2: $($target.Replace($HOME, '~')) ($($skillFolders.Count))"
}

Write-Host "`nPipeline complete." -ForegroundColor Green
