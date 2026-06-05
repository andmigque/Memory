Set-StrictMode -Version Latest

function New-Memory {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'Architect', 'Gemini', 'Claude', 'Grok', 'GPT', 'Human', 'Self', 'System', 'Agent', 'Codex', 'Qwen'
        )]
        [string]$Entity,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'Architect', 'Gemini', 'Claude', 'Grok', 'GPT', 'Human', 'Self', 'System', 'Agent', 'Codex', 'Qwen'
        )]
        [string]$ToEntity,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'Depends', 'Creates', 'Tests', 'Refactors', 'Throws', 'Runs', 'Guides', 'Learns', 'Configures',
            'Thinks', 'Delivers', 'Reviews', 'Documents', 'Implements', 'Fixes', 'Observes', 'Analyzes',
            'Designs', 'Encourages', 'Requests', 'Reports', 'Credits', 'Evolves', 'Understands', 'Thanks',
            'Accepts', 'Imagines', 'Decodes', 'Collaborates', 'Questions', 'Reflects', 'Realizes', 'Integrates',
            'Delegates', 'Proposes', 'Researches', 'Retrospects', 'Opens', 'Closes', 'Receives', 'Plans',
            'Feedback', 'Decides', 'GloriousFailures'
        )]
        [string]$Relation,

        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'Devops', 'Infrastructure', 'DataPlane', 'Protocol', 'Security', 'Research', 'Backend', 'Plan',
            'Frontend', 'Troubleshoot', 'Schema', 'Skill', 'CodeQuality', 'Configure', 'UserExperience',
            'Prompt', 'Memory', 'Test', 'Cognition'
        )]
        [string]$Work,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Notes
    )

    $supabaseUrl = $env:SUPABASE_URL_DEV
    if ([string]::IsNullOrWhiteSpace($supabaseUrl)) {
        throw 'SUPABASE_URL_DEV environment variable is required.'
    }

    $publishableKey = $env:SUPABASE_PUBLISHABLE
    if ([string]::IsNullOrWhiteSpace($publishableKey)) {
        throw 'SUPABASE_PUBLISHABLE environment variable is required.'
    }

    $email = $env:AGENT_SUPABASE_MEMORY_EMAIL
    if ([string]::IsNullOrWhiteSpace($email)) {
        throw 'AGENT_SUPABASE_MEMORY_EMAIL environment variable is required.'
    }

    $secret = $env:AGENT_SUPABASE_MEMORY_SECRET
    if ([string]::IsNullOrWhiteSpace($secret)) {
        throw 'AGENT_SUPABASE_MEMORY_SECRET environment variable is required.'
    }

    $signIn = @{
        Uri         = "$($supabaseUrl)/auth/v1/token?grant_type=password"
        Method      = 'Post'
        Headers     = @{ apikey = $publishableKey }
        ContentType = 'application/json'
        Body        = @{ email = $email; password = $secret } | ConvertTo-Json
    }
    $accessToken = (Invoke-RestMethod @signIn).access_token

    $request = @{
        Uri         = "$($supabaseUrl)/rest/v1/rpc/new_memory"
        Method      = 'Post'
        Headers     = @{
            apikey        = $publishableKey
            Authorization = "Bearer $($accessToken)"
        }
        ContentType = 'application/json'
        Body        = @{
            p_entity    = $Entity
            p_to_entity = $ToEntity
            p_relation  = $Relation
            p_work      = $Work
            p_notes     = $Notes
        } | ConvertTo-Json
    }

    Invoke-RestMethod @request
}
