Set-StrictMode -Version Latest

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
    exit 0
}

if ($entry.PSObject.Properties['is_interrupt'] -and $entry.is_interrupt)
{
    exit 0
}

$toolName = '(unknown tool)'
if ($entry.PSObject.Properties['tool_name'] -and -not [string]::IsNullOrWhiteSpace([string]$entry.tool_name))
{
    $toolName = [string]$entry.tool_name
}

$errorType = '(none)'
if ($entry.PSObject.Properties['error_type'] -and -not [string]::IsNullOrWhiteSpace([string]$entry.error_type))
{
    $errorType = [string]$entry.error_type
}

$errorText = '(none)'
if ($entry.PSObject.Properties['error'] -and -not [string]::IsNullOrWhiteSpace([string]$entry.error))
{
    $errorText = [string]$entry.error
}

$message = @"
TOOL FAILURE: Record a Glorious Failure before continuing.

Tool:       $toolName
error_type: $errorType
error:      $errorText

Record it now with New-Memory: Relation GloriousFailures, Work Cognition. 
The notes must describe what YOU did wrong: 
- the mistake, 
- it's root cause, 
- and the requirement the failure produces.

If you do NOT actually know what you did wrong, STOP and ask the Architect
before recording. Do not invent a cause.
"@

[Console]::Error.WriteLine($message)

exit 2
