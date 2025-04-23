# Create a new function to help bootstrap the initialization
function Connect-Conjur {
    <#
    .SYNOPSIS
    Connects to Conjur by performing authentication and session initialization in a single call.

    .PARAMETER ApplianceUrl
    The base URL of the Conjur appliance.

    .PARAMETER Account
    The Conjur account name.

    .PARAMETER ServiceID
    For JWT authentication - the service ID to authenticate with.

    .PARAMETER JWTToken
    For JWT authentication - the JWT token to authenticate with.

    .PARAMETER WorkloadId
    For API key authentication - the workload ID to authenticate with.

    .PARAMETER ApiKey
    For API key authentication - the API key to authenticate with.

    .PARAMETER ExpiryMinutes
    Optional. Number of minutes until the session expires.

    .EXAMPLE
    Connect-Conjur -ApplianceUrl "https://conjur.example.com/api" -Account "myaccount" -WorkloadId "host/myapp" -ApiKey "myapikey"
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ApplianceUrl,
        
        [Parameter(Mandatory=$true)]
        [string]$Account,
        
        [Parameter(Mandatory=$false, ParameterSetName="JWT")]
        [string]$ServiceID,
        
        [Parameter(Mandatory=$false, ParameterSetName="JWT")]
        [string]$JWTToken,
        
        [Parameter(Mandatory=$false, ParameterSetName="ApiKey")]
        [string]$WorkloadId,
        
        [Parameter(Mandatory=$false, ParameterSetName="ApiKey")]
        [string]$ApiKey,
        
        [Parameter(Mandatory=$false)]
        [int]$ExpiryMinutes = 30
    )

    # First initialize the session with just the ApplianceUrl and Account
    # Don't set the AuthToken yet
    $script:ConjurSession['ApplianceUrl'] = $ApplianceUrl
    $script:ConjurSession['Account'] = $Account
    
    # Now get the auth token using direct authentication
    try {
        if ($PSCmdlet.ParameterSetName -eq "JWT") {
            # JWT Authentication
            $uri = "$ApplianceUrl/authn-jwt/$ServiceID/$Account/authenticate"
            $headers = @{
                "Accept-Encoding" = "base64"
            }
            $authToken = Invoke-RestMethod -Uri $uri -Body "jwt=$JWTToken" -Headers $headers -Method Post -ContentType "application/x-www-form-urlencoded"
        } 
        elseif ($PSCmdlet.ParameterSetName -eq "ApiKey") {
            # WorkloadId + API Key Authentication
            $encodedWorkloadId = [System.Web.HttpUtility]::UrlEncode($WorkloadId)
            $uri = "$ApplianceUrl/authn/$Account/$encodedWorkloadId/authenticate"
            $headers = @{
                "Accept-Encoding" = "base64"
            }
            $authToken = Invoke-RestMethod -Uri $uri -Body $ApiKey -Headers $headers -Method Post -ContentType "text/plain"
        }
        else {
            throw "Authentication parameters not provided. Either ServiceID and JWTToken or WorkloadId and ApiKey must be specified."
        }
        
        # Properly initialize the full session with the obtained token
        $script:ConjurSession['AuthToken'] = $authToken
        $script:ConjurSession['ExpiryTime'] = (Get-Date).AddMinutes($ExpiryMinutes)
        
        return "Successfully connected to Conjur at $ApplianceUrl"
    }
    catch {
        # Clean up the session if authentication fails
        Clear-ConjurSession
        throw "Failed to authenticate with Conjur: $_"
    }
}

# Export the new function
Export-ModuleMember -Function Connect-Conjur