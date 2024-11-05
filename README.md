# psConjur

![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/psConjur) ![Downloads](https://img.shields.io/powershellgallery/dt/psConjur) ![License](https://img.shields.io/github/license/infamousjoeg/psConjur)

`psConjur` is a PowerShell module for authenticating to and retrieving secrets from Conjur’s REST API. It supports session-based authentication to streamline repeated requests.

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

### Initialize a Conjur Session

Initialize a session with Conjur to set up common parameters (`ApplianceUrl`, `Account`, and `AuthToken`) for reuse across multiple commands:

```powershell
Initialize-ConjurSession -ApplianceUrl "https://your-conjur-appliance.com/api" -Account "conjur" -AuthToken "your-auth-token" -ExpiryMinutes 30
```

* `ExpiryMinutes` is optional and defaults to 30 minutes.

### Authentication

Use the `Get-ConjurAuthToken` function to authenticate and obtain an access token. This supports both JWT and API Key authentication methods.

#### JWT Authentication

```powershell
$authToken = Get-ConjurAuthToken -ServiceID "your-service-id" -JWTToken "your-jwt-token"
```

#### WorkloadID + API Key Authentication

```powershell
$authToken = Get-ConjurAuthToken -WorkloadID "your-WorkloadID" -ApiKey "your-api-key"
```

The retrieved `AuthToken` will automatically update the session and reset the expiration time.

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

### Clear the Conjur Session

When finished, manually clear the session data to remove sensitive information from memory:

```powershell
Clear-ConjurSession
```

## Security

### Security Implications and Recommendations

Using a session-based approach for storing authentication and connection information introduces security implications. Here are key considerations and recommendations:

	1. **Session Persistence**: Sensitive data, including the `AuthToken`, remains in memory during the session. This provides convenience but poses a risk if the PowerShell session remains open and unattended.
	- **Recommendation**: Always clear the session manually with `Clear-ConjurSession` when done, and avoid using this module in long-running, unattended sessions.
	2. **Session Expiration**: Sessions expire after a set time (default is 30 minutes) to prevent indefinite access with stale tokens.
	- **Recommendation**: Set an appropriate expiration time based on your security needs using `ExpiryMinutes` in `Initialize-ConjurSession`.
	3. **Unauthorized Access**: If another user gains access to the PowerShell session, they could potentially access stored tokens.
	- **Recommendation**: Limit access to the system, and use PowerShell’s ConstrainedLanguage mode to restrict unauthorized users in shared environments.
	4. **Memory Exposure**: Sensitive session data stored in memory could be accessed if the host is compromised.
	- **Recommendation**: Secure the host machine and consider automatic session clearing or periodic re-authentication in high-security environments.
	5. **Audit Logging**: This module does not log actions by default, which may complicate auditing.
	- **Recommendation**: Enable custom logging for critical actions as needed, depending on your organization’s audit requirements.

By following these best practices, you can securely leverage the session-based functionality in `psConjur` for efficient Conjur API access.

## Contributing

Feel free to submit issues and pull requests. Please ensure code is formatted for readability and follows PowerShell best practices.

## License

[MIT](LICENSE)