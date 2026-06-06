Set-StrictMode -Version Latest

# SessionStart hook for the Memory project.
# Reads the hook payload from stdin, determines the project the model was
# launched in (the payload's cwd), executes a grounding read against the
# memory store, and returns additionalContext that carries the latest
# memories as data plus the standing advice to ground before acting.
#
# The grounding read is best-effort: any failure degrades to the advice
# alone and never blocks session start.

$raw = [Console]::In.ReadToEnd()

if ([string]::IsNullOrWhiteSpace($raw))
{
    exit 0
}

try
{
    $entry = $raw | ConvertFrom-Json -ErrorAction Stop
}
catch
{
    # A malformed payload must never block session start.
    exit 0
}

# The launch project is the payload's cwd. Fall back to the current location
# if the field is absent, rather than failing the session start.

$projectPath = ''

if ($entry.PSObject.Properties['cwd'])
{
    $projectPath = $entry.cwd
}

if ([string]::IsNullOrWhiteSpace($projectPath))
{
    $projectPath = (Get-Location).Path
}

$projectName = Split-Path -Path $projectPath -Leaf

# Redact the home directory to ~ for display, the way deploy_skills.ps1 does.
$homePath = Convert-Path -Path $HOME
$displayPath = $projectPath
if ($displayPath.StartsWith($homePath, [System.StringComparison]::OrdinalIgnoreCase))
{
    $displayPath = '~' + $displayPath.Substring($homePath.Length)
}

# The standing advice. Kept verbatim: grounding is the reflex, not a one-off.
$advice = @"
Before acting, ground yourself in prior memory for the project you were launched in: $projectName ($displayPath).

Use your search-memory skill to recall memories tied to this project — prior decisions, owned failures, and in-progress work. Use what returns to orient yourself; do not ask the user to catch you up.
"@

# Execute the grounding read. Best-effort: any failure leaves the grounding
# block empty and falls back to the advice alone.
$grounding = ''

try
{
    $rows = Get-Memory
    if ($rows)
    {
        $lines = foreach ($row in $rows)
        {
            "- ($($row.id)) $($row.entity) $($row.relation) $($row.to_entity) [$($row.work)]: $($row.notes)"
        }
        $grounding = "`n`nLatest recorded memory (newest first):`n" + ($lines -join "`n")
    }
}
catch
{
    $grounding = ''
}

$context = $advice + $grounding

$output = [PSCustomObject]@{
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName     = 'SessionStart'
        additionalContext = $context
    }
}

$output | ConvertTo-Json -Depth 5

exit 0
