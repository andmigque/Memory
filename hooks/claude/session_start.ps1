Set-StrictMode -Version Latest

# SessionStart hook for the Memory project.
# Reads the hook payload from stdin, determines the project the model was
# launched in (the payload's cwd), and returns additionalContext that
# instructs the model to ground itself by searching memory for THAT project.

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
$projectPath = $null
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

$context = @"
Before acting, ground yourself in prior memory for the project you were launched in: $projectName ($displayPath).

Use your search-memory skill to recall memories tied to this project — prior decisions, owned failures, and in-progress work. Use what returns to orient yourself; do not ask the user to catch you up.
"@

$output = [PSCustomObject]@{
    hookSpecificOutput = [PSCustomObject]@{
        hookEventName     = 'SessionStart'
        additionalContext = $context
    }
}

$output | ConvertTo-Json -Depth 5

exit 0
