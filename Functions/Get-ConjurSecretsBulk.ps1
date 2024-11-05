# Updated function to retrieve multiple secrets in bulk, using session values and session check
function Get-ConjurSecretsBulk {
    param (
        [string[]]$SecretIds
    )

    Test-ConjurSession
    $ApplianceUrl = $script:ConjurSession['ApplianceUrl']
    $Account = $script:ConjurSession['Account']
    $AuthToken = $script:ConjurSession['AuthToken']

    $AuthHeader = "Token token=`"$AuthToken`""
    $headers = @{
        "Authorization" = $AuthHeader
    }

    $secrets = @{}

    foreach ($secretId in $SecretIds) {
        $uri = "$ApplianceUrl/secrets/$Account/variable/$secretId"
        
        try {
            $secretValue = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
            $secrets[$secretId] = $secretValue
        } catch {
            Write-Warning "Failed to retrieve secret with ID ${secretId}: $_"
            $secrets[$secretId] = $null
        }
    }

    return $secrets
}