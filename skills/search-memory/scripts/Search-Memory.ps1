Set-StrictMode -Version Latest

function Search-Memory {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Query = 'Memories where the architect is angry or frustrated',

        [Parameter(Mandatory = $false)]
        [ValidateScript({ $_ -gt 0 })]
        [int]$Count = 20
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
        Uri         = "$($supabaseUrl)/functions/v1/search-memory"
        Method      = 'Post'
        Headers     = @{
            apikey        = $publishableKey
            Authorization = "Bearer $($accessToken)"
        }
        ContentType = 'application/json'
        Body        = @{ query = $Query; mode = 'semantic'; count = $Count } | ConvertTo-Json
    }

    $response = Invoke-RestMethod @request
    return $response.results | Sort-Object -Property score -Descending
}
