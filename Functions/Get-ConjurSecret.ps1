# Updated function to retrieve a single secret, using session values and session check
function Get-ConjurSecret {
    param (
        [string]$SecretId
    )

    Test-ConjurSession
    $ApplianceUrl = $script:ConjurSession['ApplianceUrl']
    $Account = $script:ConjurSession['Account']
    $AuthToken = $script:ConjurSession['AuthToken']

    $AuthHeader = "Token token=`"$AuthToken`""
    $uri = "$ApplianceUrl/secrets/$Account/variable/$SecretId"
    $headers = @{
        "Authorization" = $AuthHeader
    }

    try {
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get
        return $response
    } catch {
        throw "Failed to retrieve secret: $_"
    }
}