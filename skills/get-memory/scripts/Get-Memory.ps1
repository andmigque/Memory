Set-StrictMode -Version Latest

function Get-Memory {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet(
            'Architect', 'Gemini', 'Claude', 'Grok', 'GPT', 'Human', 'Self', 'System', 'Agent', 'Codex', 'Qwen'
        )]
        [string]$Entity,

        [Parameter(Mandatory = $false)]
        [ValidateScript({ $_ -gt 0 })]
        [int]$Limit = 10
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

    $payload = @{ limit = $Limit }
    if ($PSBoundParameters.ContainsKey('Entity')) {
        $payload['entity'] = $Entity
    }

    $request = @{
        Uri         = "$($supabaseUrl)/functions/v1/get-memory"
        Method      = 'Post'
        Headers     = @{
            apikey        = $publishableKey
            Authorization = "Bearer $($accessToken)"
        }
        ContentType = 'application/json'
        Body        = $payload | ConvertTo-Json
    }

    $response = Invoke-RestMethod @request
    return $response.results
}
