# Function to initialize a Conjur session with automatic expiry
function Initialize-ConjurSession {
    <#
    .SYNOPSIS
    Initializes a session with common Conjur parameters.

    .PARAMETER ApplianceUrl
    The base URL of the Conjur appliance.

    .PARAMETER Account
    The Conjur account name.

    .PARAMETER AuthToken
    The access token obtained from Get-ConjurAuthToken.

    .PARAMETER ExpiryMinutes
    Optional. Number of minutes until the session expires and needs re-authentication.

    .EXAMPLE
    Initialize-ConjurSession -ApplianceUrl "https://your-conjur-appliance.com/api" -Account "conjur" -AuthToken $authToken -ExpiryMinutes 30
    #>

    param (
        [string]$ApplianceUrl,
        [string]$Account,
        [string]$AuthToken,
        [int]$ExpiryMinutes = 30
    )

    # Store session parameters with expiry time
    $script:ConjurSession['ApplianceUrl'] = $ApplianceUrl
    $script:ConjurSession['Account'] = $Account
    $script:ConjurSession['AuthToken'] = $AuthToken
    $script:ConjurSession['ExpiryTime'] = (Get-Date).AddMinutes($ExpiryMinutes)
}