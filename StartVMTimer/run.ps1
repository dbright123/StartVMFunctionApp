# Input bindings are passed in via param block.
param($Timer)

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "StartVMTimer is running late!"
}

Write-Host "StartVMTimer trigger fired at: $(Get-Date -Format o)"

$subscriptionId = "46b0a57d-6e48-444c-9cd0-61977a389531"
$resourceGroup  = "onit"
$vmName         = "testing"
Install-Module -Name Az.Compute
Import-Module Az.Compute -ErrorAction Stop
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
