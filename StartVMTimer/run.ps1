param($Timer)

if ($Timer.IsPastDue) {
    Write-Host "StartVMTimer is running late!"
}

Write-Host "StartVMTimer triggered at: $(Get-Date -Format o)"

$subscriptionId = "46b0a57d-6e48-444c-9cd0-61977a389531"
$resourceGroup  = "onit"
$vmName         = "testing"

# Ensure Modules path (for Linux Consumption workaround)
$env:PSModulePath = "$PSScriptRoot/../Modules:$env:PSModulePath"

try {
    # Import modules
    Import-Module Az.Accounts -ErrorAction Stop
    Import-Module Az.Compute  -ErrorAction Stop

    # Authenticate using Managed Identity
    Connect-AzAccount -Identity
    Set-AzContext -SubscriptionId $subscriptionId

    # ✅ Get VM status
    $vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName -Status

    $powerState = ($vm.Statuses | Where-Object { $_.Code -like "PowerState/*" }).DisplayStatus

    Write-Host "Current VM power state: $powerState"

    # ✅ Check and start if NOT running
    if ($powerState -ne "VM running") {

        Write-Host "VM is not running. Attempting to start..."

        Start-AzVM -ResourceGroupName $resourceGroup -Name $vmName

        Write-Host "VM start initiated successfully."
    }
    else {
        Write-Host "VM is already running. No action required."
    }
}
catch {
    Write-Error "Failed during VM check/start operation: $($_.Exception.Message)"
    throw
}
