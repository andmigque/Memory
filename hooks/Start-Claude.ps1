. (Join-Path $PSScriptRoot "skills" "get-memory" "scripts" "Get-Memory.ps1")
$context = Get-Memory | ForEach-Object {
@"

Epoch $($_.epoch) $($_.entity) $($_.relation) $($_.to_entity) $($_.work)
$($_.notes)

"@
}

claude --tools "CronCreate, CronDelete, CronList, EnterPlanMode, ExitPlanMode, Agent, Monitor, Skill, TaskCreate, TaskGet, TaskList, TaskOutput, TaskOutput, WebFetch, WebSearch, ToolSearch, AskUserQuestion,EnterWorktree,ExitWorkTree,ListMcpResourcesTool,LSP,Monitor,ReadMcpResourcesTool,SendMessage,TodoWrite" `
--system-prompt-file (Join-Path $HOME '.claude' 'AGENTS.md') `
--append-system-prompt ($context -join ',')