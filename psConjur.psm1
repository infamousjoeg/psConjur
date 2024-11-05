# psConjur.psm1 - PowerShell Module for Conjur REST API
# Author: Joe Garcia (joe.garcia@cyberark.com)
# Description: A PowerShell module to authenticate with and retrieve secrets from Conjur REST API.

# Module-scoped session data
$script:ConjurSession = @{
    ApplianceUrl = $null
    Account      = $null
    AuthToken    = $null
    ExpiryTime   = $null
}

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

# Function to clear the Conjur session data
function Clear-ConjurSession {
    <#
    .SYNOPSIS
    Clears the current Conjur session data, including any stored authentication tokens.
    #>

    $script:ConjurSession = @{
        ApplianceUrl = $null
        Account      = $null
        AuthToken    = $null
        ExpiryTime   = $null
    }
}

# Helper function to check session expiration and re-authenticate if expired
function Test-ConjurSession {
    if (-not $script:ConjurSession['AuthToken'] -or (Get-Date) -gt $script:ConjurSession['ExpiryTime']) {
        throw "Session expired or not initialized. Please re-authenticate using Initialize-ConjurSession."
    }
}

# Updated Get-ConjurAuthToken function (unchanged but now relies on session)
function Get-ConjurAuthToken {
    param (
        [string]$ServiceID,
        [string]$JWTToken,
        [string]$Username,
        [string]$ApiKey
    )

    $ApplianceUrl = $script:ConjurSession['ApplianceUrl']
    $Account = $script:ConjurSession['Account']

    if (!$ApplianceUrl -or !$Account) {
        throw "Please initialize the Conjur session with ApplianceUrl and Account using Initialize-ConjurSession."
    }

    try {
        if ($ServiceID -and $JWTToken) {
            $AuthHeader = "Token token=`"$JWTToken`""
            $uri = "$ApplianceUrl/authn-jwt/$ServiceID/$Account/authenticate"
            $headers = @{
                "Authorization" = $AuthHeader
            }
            $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Post
        } elseif ($Username -and $ApiKey) {
            $uri = "$ApplianceUrl/authn/$Account/$Username/authenticate"
            $response = Invoke-RestMethod -Uri $uri -Body $ApiKey -Method Post -ContentType "text/plain"
        } else {
            throw "Provide either ServiceID and JWTToken for JWT authentication or Username and ApiKey for username+apikey authentication."
        }

        # Update the session's AuthToken and reset expiry
        $script:ConjurSession['AuthToken'] = $response
        $script:ConjurSession['ExpiryTime'] = (Get-Date).AddMinutes(30) # Reset expiry to default 30 minutes
        return $response
    } catch {
        throw "Authentication failed: $_"
    }
}

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

# Export functions
Export-ModuleMember -Function Initialize-ConjurSession, Clear-ConjurSession, Get-ConjurAuthToken, Get-ConjurSecret, Get-ConjurSecretsBulk