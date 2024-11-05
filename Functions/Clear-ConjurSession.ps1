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