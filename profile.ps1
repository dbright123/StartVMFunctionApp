# Azure Functions profile.ps1
#
# This profile.ps1 will get executed every "cold start" of your Function App.
# "cold start" occurs when:
#
# * A Function App starts up for the very first time
# * A Function App starts up after being de-allocated due to inactivity
#
# You can define helper functions, run commands, or specify environment variables
# NOTE: any variables defined that are not environment variables will get reset after the first execution

# Authenticate with Azure PowerShell using the Function App's managed identity.
# Ensure MSI is enabled and the identity has the required role (e.g. "Virtual Machine Contributor")
# on the target VM / resource group / subscription.
#
# Different hosting platforms expose the managed identity differently:
#   * App Service / classic Functions  -> MSI_SECRET
#   * Linux Consumption (Legion)/Flex  -> IDENTITY_ENDPOINT + IDENTITY_HEADER
# Check for any of them so auth works across plans.
Install-Module -Name Az.Compute
if ($env:MSI_SECRET -or $env:IDENTITY_ENDPOINT) {
    try {
        Disable-AzContextAutosave -Scope Process | Out-Null
        Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
        Write-Host "Connected to Azure using the managed identity."
    }
    catch {
        Write-Error "Managed identity sign-in failed: $($_.Exception.Message)"
        throw
    }
}
else {
    Write-Warning "No managed identity environment detected. Skipping Connect-AzAccount (expected only for local dev where you run Connect-AzAccount manually)."
}

# Uncomment the next line to enable legacy AzureRm alias in Cloud Shell.
# Enable-AzureRmAlias

# You can also define functions or aliases that can be referenced in any of your PowerShell functions.
