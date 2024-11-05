@{
    # Module metadata
    ModuleVersion = '1.0.0'
    GUID = 'put-a-unique-guid-here'
    Author = 'Your Name'
    CompanyName = 'Your Company'
    Description = 'A PowerShell module for interacting with Conjur REST API for authentication and secret management.'
    Copyright = '(c) Your Name. All rights reserved.'
    
    # Functions to export
    FunctionsToExport = @(
        'Get-ConjurAuthToken',
        'Get-ConjurSecret'
    )

    # Required modules (if any)
    RequiredModules = @()
    
    # PowerShell version compatibility
    PowerShellVersion = '5.1'
}