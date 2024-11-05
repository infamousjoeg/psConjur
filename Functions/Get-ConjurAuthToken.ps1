# Updated Get-ConjurAuthToken function (unchanged but now relies on session)
function Get-ConjurAuthToken {
    param (
        [string]$ServiceID,
        [string]$JWTToken,
        [string]$WorkloadId,
        [string]$ApiKey
    )

    $ApplianceUrl = $script:ConjurSession['ApplianceUrl']
    $Account = $script:ConjurSession['Account']

    if (!$ApplianceUrl -or !$Account) {
        throw "Please initialize the Conjur session with ApplianceUrl and Account using Initialize-ConjurSession."
    }

    try {
        if ($ServiceID -and $JWTToken) {
            $uri = "$ApplianceUrl/authn-jwt/$ServiceID/$Account/authenticate"
            $headers = @{
                "Accept-Encoding" = "base64"
            }
            $response = Invoke-RestMethod -Uri $uri -Body "jwt=$JWTToken" -Headers $headers -Method Post -ContentType "application/x-www-form-urlencoded"
        } elseif ($WorkloadId -and $ApiKey) {
            $encodedWorkloadId = [System.Web.HttpUtility]::UrlEncode($WorkloadId)
            $uri = "$ApplianceUrl/authn/$Account/$encodedWorkloadId/authenticate"
            $headers = @{
                "Accept-Encoding" = "base64"
            }
            $response = Invoke-RestMethod -Uri $uri -Body $ApiKey -Headers $headers -Method Post -ContentType "text/plain"
        } else {
            throw "Provide either ServiceID and JWTToken for JWT authentication or WorkloadID and ApiKey for WorkloadID+apikey authentication."
        }

        # Update the session's AuthToken and reset expiry
        $script:ConjurSession['AuthToken'] = $response
        $script:ConjurSession['ExpiryTime'] = (Get-Date).AddMinutes(30) # Reset expiry to default 30 minutes
    } catch {
        throw "Authentication failed: $_"
    }
}