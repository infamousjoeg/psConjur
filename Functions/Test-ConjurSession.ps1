# Helper function to check session expiration and re-authenticate if expired
function Test-ConjurSession {
    if (-not $script:ConjurSession['AuthToken'] -or (Get-Date) -gt $script:ConjurSession['ExpiryTime']) {
        throw "Session expired or not initialized. Please re-authenticate using Initialize-ConjurSession."
    }
}