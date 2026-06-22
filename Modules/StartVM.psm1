# Shared helper functions for the Function App.
# Files in the 'Modules' folder are auto-loaded for every function in the app.

function Start-TargetVM {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)] [string] $SubscriptionId,
        [Parameter(Mandatory = $true)] [string] $ResourceGroup,
        [Parameter(Mandatory = $true)] [string] $VmName
    )

    # Ensure we operate against the correct subscription.
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null

    # Check current power state to avoid an unnecessary start call.
    $vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -Status -ErrorAction Stop
    $powerState = ($vm.Statuses | Where-Object { $_.Code -like 'PowerState/*' }).Code

    if ($powerState -eq 'PowerState/running') {
        $msg = "VM '$VmName' is already running. No action taken."
        Write-Host $msg
        return $msg
    }

    Write-Host "Starting VM '$VmName' in resource group '$ResourceGroup' (current state: $powerState)..."
    Start-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -ErrorAction Stop | Out-Null

    $msg = "VM '$VmName' started successfully."
    Write-Host $msg
    return $msg
}

Export-ModuleMember -Function Start-TargetVM
