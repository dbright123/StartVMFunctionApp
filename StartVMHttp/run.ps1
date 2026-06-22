using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

Write-Host "StartVMHttp trigger received a request."

# Allow overriding the target VM via query string or JSON body, otherwise fall back to app settings.
$subscriptionId = $Request.Query.SubscriptionId  ?? $Request.Body.SubscriptionId  ?? $env:SUBSCRIPTION_ID
$resourceGroup  = $Request.Query.ResourceGroup   ?? $Request.Body.ResourceGroup   ?? $env:RESOURCE_GROUP
$vmName         = $Request.Query.VmName          ?? $Request.Body.VmName          ?? $env:VM_NAME

$status  = [HttpStatusCode]::OK
$message = ""

try {
    if (-not $subscriptionId -or -not $resourceGroup -or -not $vmName) {
        throw "Missing required parameters. Provide SubscriptionId, ResourceGroup and VmName (via query, body, or app settings)."
    }

    $result = Start-TargetVM -SubscriptionId $subscriptionId -ResourceGroup $resourceGroup -VmName $vmName
    $message = $result
}
catch {
    $status  = [HttpStatusCode]::InternalServerError
    $message = "Failed to start VM '$vmName': $($_.Exception.Message)"
    Write-Error $message
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode  = $status
    Body        = $message
    ContentType = "text/plain"
})
