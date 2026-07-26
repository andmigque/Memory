Set-StrictMode -Version Latest

$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) {
    exit 0
}

$root = $PSScriptRoot

$parent = Split-Path $root -Parent

try {
    $resolvedSkillsDirectory = Resolve-Path -Path (Join-Path -Path $parent -ChildPath "skills")
    $getMemorySkill = Join-Path -Path $resolvedSkillsDirectory -ChildPath "get-memory" -AdditionalChildPath 'scripts', 'Get-Memory.ps1'
    . $getMemorySkill
} catch {
    Write-Error "$_"
    exit 0
}

$context = Get-Memory | ForEach-Object {
@"

Epoch $($_.epoch) $($_.entity) $($_.relation) $($_.to_entity) $($_.work)
$($_.notes)

"@
}

[PSCustomObject]@{
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName     = 'SessionStart'
        additionalContext = ($context -join ",")
    }
} | ConvertTo-Json -Depth 5

exit 0
