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

# Get the current module directory
$moduleDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Import each function from the Functions directory
Get-ChildItem -Path (Join-Path $moduleDir 'Functions') -Filter *.ps1 | ForEach-Object {
    . $_.FullName
}

# Export functions
Export-ModuleMember -Function Connect-Conjur, Clear-ConjurSession, Test-ConjurSession, Get-ConjurAuthToken, Get-ConjurSecret, Get-ConjurSecretsBulk