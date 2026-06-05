Set-StrictMode -Version Latest

function Search-Memory {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Query = 'Memories where the architect is angry or frustrated'
    )

    $supabaseUrl = $env:SUPABASE_URL_DEV
    if ([string]::IsNullOrWhiteSpace($supabaseUrl)) {
        throw 'SUPABASE_URL_DEV environment variable is required.'
    }

    $serviceRoleKeyDev = $env:SUPABASE_SERVICE_ROLE_KEY_DEV
    if ([string]::IsNullOrWhiteSpace($serviceRoleKeyDev)) {
        throw 'SUPABASE_SERVICE_ROLE_KEY_DEV environment variable is required.'
    }

    $request = @{
        Uri         = "$($supabaseUrl)/functions/v1/invoke-memory-embedding"
        Method      = 'Post'
        Headers     = @{
            apikey        = $serviceRoleKeyDev
            Authorization = "Bearer $($serviceRoleKeyDev)"
        }
        ContentType = 'application/json'
        Body        = @{ action = 'search_memory'; mode = 'semantic'; query = $Query } | ConvertTo-Json
    }

    $response = Invoke-RestMethod @request
    return $response.results | Sort-Object -Property score -Descending
}
