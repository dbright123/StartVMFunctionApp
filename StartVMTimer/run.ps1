# Input bindings are passed in via param block.
param($Timer)

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "StartVMTimer is running late!"
}

Write-Host "StartVMTimer trigger fired at: $(Get-Date -Format o)"

$subscriptionId = $env:SUBSCRIPTION_ID
$resourceGroup  = $env:RESOURCE_GROUP
$vmName         = $env:VM_NAME

try {
    if (-not $subscriptionId -or -not $resourceGroup -or -not $vmName) {
        throw "Missing required app settings: SUBSCRIPTION_ID, RESOURCE_GROUP and VM_NAME must be configured."
    }

    $result = Start-TargetVM -SubscriptionId $subscriptionId -ResourceGroup $resourceGroup -VmName $vmName
    Write-Host $result
}
catch {
    Write-Error "Failed to start VM '$vmName': $($_.Exception.Message)"
    throw
}
