@{
    # Module metadata
    ModuleVersion = '1.0.0'
    GUID = '6b2ed520-42df-4f2b-8159-4f053a069aa5'
    Author = 'Joe Garcia'
    CompanyName = 'CyberArk'
    Description = 'A PowerShell module for interacting with Conjur REST API for authentication and secret management.'
    Copyright = '(c) Joe Garcia. All Rights Reserved.'
    
    # Root module file
    RootModule = "psConjur.psm1"
    
    # Functions to export
    FunctionsToExport = @(
        'Initialize-ConjurSession',
        'Get-ConjurAuthToken',
        'Get-ConjurSecret',
        'Clear-ConjurSession',
        'Test-ConjurSession',
        'Get-ConjurSecretsBulk'
    )

    # Required modules (if any)
    RequiredModules = @()
    
    # PowerShell version compatibility
    PowerShellVersion = '5.1'
}