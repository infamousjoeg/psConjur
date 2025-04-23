# psConjur <!-- omit from toc -->

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/psConjur) ![Downloads](https://img.shields.io/powershellgallery/dt/psConjur) ![License](https://img.shields.io/github/license/infamousjoeg/psConjur)

`psConjur` is a PowerShell module for authenticating to and retrieving secrets from Conjur’s REST API. It supports session-based authentication to streamline repeated requests.

- [Installation](#installation)
  - [From PowerShell Gallery](#from-powershell-gallery)
  - [Manual Installation](#manual-installation)
- [Usage](#usage)
  - [Connect to Conjur](#connect-to-conjur)
  - [Retrieve a Secret](#retrieve-a-secret)
  - [Retrieve Multiple Secrets in Bulk](#retrieve-multiple-secrets-in-bulk)
  - [Test Session Status](#test-session-status)
  - [Clear the Conjur Session](#clear-the-conjur-session)
- [Security](#security)
  - [Security Implications and Recommendations](#security-implications-and-recommendations)
- [Example Workflow](#example-workflow)
- [Contributing](#contributing)
- [License](#license)

## Installation

### From PowerShell Gallery

You can install `psConjur` directly from the PowerShell Gallery:

```powershell
Install-Module -Name psConjur -Scope CurrentUser
```

### Manual Installation

Download the module files and import them into your PowerShell session:

```powershell
Import-Module .\psConjur\psConjur.psd1
```

## Usage

### Connect to Conjur

Use the `Connect-Conjur` function to establish a connection to Conjur. This will handle both authentication and session initialization in a single step:

```powershell
# Using JWT Authentication
Connect-Conjur -ApplianceUrl "https://your-conjur-appliance.com/api" -Account "conjur" -ServiceID "your-service-id" -JWTToken "your-jwt-token" -ExpiryMinutes 30

# Using WorkloadID + API Key Authentication
Connect-Conjur -ApplianceUrl "https://your-conjur-appliance.com/api" -Account "conjur" -WorkloadId "your-workload-id" -ApiKey "your-api-key" -ExpiryMinutes 30
```

* `ExpiryMinutes` is optional and defaults to 30 minutes.

This connection establishes a session that contains all the necessary parameters for subsequent API calls.

### Retrieve a Secret

Retrieve a single secret using the `Get-ConjurSecret` function:

```powershell
$secret = Get-ConjurSecret -SecretId "my/secret/id"
```

### Retrieve Multiple Secrets in Bulk

Retrieve multiple secrets at once by providing an array of secret IDs to `Get-ConjurSecretsBulk`:

```powershell
$secrets = Get-ConjurSecretsBulk -SecretIds @("secret/id/one", "secret/id/two")
```

This returns a hashtable with secret IDs as keys and their values.

### Test Session Status

Check if the current session is still valid:

```powershell
try {
    Test-ConjurSession
    Write-Output "Session is valid"
} catch {
    Write-Output "Session expired or not initialized"
    # Reconnect here if needed
}
```

### Clear the Conjur Session

When finished, manually clear the session data to remove sensitive information from memory:

```powershell
Clear-ConjurSession
```

## Security

### Security Implications and Recommendations

Using a session-based approach for storing authentication and connection information introduces security implications. Here are key considerations and recommendations:

|Implication|Description|Recommendation|
|---|---|---|
|**Session Persistence**|Sensitive data, including the `AuthToken`, remains in memory during the session. This provides convenience but poses a risk if the PowerShell session remains open and unattended.|Always clear the session manually with `Clear-ConjurSession` when done, and avoid using this module in long-running, unattended sessions.|
|**Session Expiration**|Sessions expire after a set time (default is 30 minutes) to prevent indefinite access with stale tokens.|Set an appropriate expiration time based on your security needs using `ExpiryMinutes` in `Connect-Conjur`.|
|Unauthorized Access|If another user gains access to the PowerShell session, they could potentially access stored tokens.|Limit access to the system, and use PowerShell's ConstrainedLanguage mode to restrict unauthorized users in shared environments.|
|Memory Exposure|Sensitive session data stored in memory could be accessed if the host is compromised.|Secure the host machine and consider automatic session clearing or periodic re-authentication in high-security environments.|
|Audit Logging|This module does not log actions by default, which may complicate auditing.|Enable custom logging for critical actions as needed, depending on your organization's audit requirements.|

## Example Workflow

A typical workflow using this module would look like:

```powershell
# Connect to Conjur
Connect-Conjur -ApplianceUrl "https://conjur.example.com/api" -Account "myaccount" -WorkloadId "host/myapp" -ApiKey "myapikey"

try {
    # Get secrets
    $dbPassword = Get-ConjurSecret -SecretId "myapp/db/password"
    $apiCredentials = Get-ConjurSecretsBulk -SecretIds @("myapp/api/key", "myapp/api/secret")
    
    # Use the secrets
    $connection = New-DatabaseConnection -Password $dbPassword
    # ... your application code ...
}
catch {
    Write-Error "Error: $_"
}
finally {
    # Always clean up
    Clear-ConjurSession
}
```

## Contributing

Feel free to submit issues and pull requests. Please ensure code is formatted for readability and follows PowerShell best practices.

## License

[MIT](LICENSE)