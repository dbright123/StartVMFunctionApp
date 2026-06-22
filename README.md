# Start-VM Azure Function App (PowerShell · Flex Consumption)

A PowerShell Azure Functions app that starts an Azure VM via two triggers:

- **`StartVMHttp`** — HTTP trigger (GET/POST), start a VM on demand.
- **`StartVMTimer`** — Timer trigger, starts the VM on a schedule (default: weekdays 07:00 UTC).

Authentication uses the Function App's **system-assigned managed identity** — no secrets stored in code.

> **Modules:** This app targets **Linux Consumption (Legion)**, which does **not** support
> Managed Dependencies (`requirements.psd1`). The Az modules are therefore **bundled** with
> the app under the `Modules/` folder. Run [`install-modules.ps1`](install-modules.ps1) once
> before deploying. See https://aka.ms/functions-powershell-include-modules.

## Project structure

```
StartVMFunctionApp/
├── host.json                 # Host config (managedDependency disabled) + extension bundle
├── requirements.psd1         # Intentionally empty (managed deps not supported)
├── install-modules.ps1       # Downloads Az modules into Modules/ for bundling
├── profile.ps1               # Cold-start: Connect-AzAccount -Identity
├── local.settings.json       # Local config (not deployed)
├── Modules/
│   ├── StartVM/             # Shared Start-TargetVM helper module (auto-loaded)
│   │   ├── StartVM.psm1
│   │   └── StartVM.psd1
│   ├── Az.Accounts/         # Bundled (created by install-modules.ps1)
│   └── Az.Compute/          # Bundled (created by install-modules.ps1)
├── StartVMHttp/
│   ├── function.json
│   └── run.ps1
└── StartVMTimer/
    ├── function.json
    └── run.ps1
```

## Prerequisites

- [Azure Functions Core Tools v4](https://learn.microsoft.com/azure/azure-functions/functions-run-local)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- PowerShell 7.4

## Deploy (Flex Consumption)

```powershell
$rg       = "rg-functions"
$location = "eastus"
$storage  = "stfuncvmstart$((Get-Random -Maximum 9999))"
$appName  = "func-startvm-$((Get-Random -Maximum 9999))"

az group create --name $rg --location $location

az storage account create --name $storage --resource-group $rg --location $location --sku Standard_LRS

# Create a Flex Consumption function app (PowerShell 7.4)
az functionapp create `
  --resource-group $rg `
  --name $appName `
  --storage-account $storage `
  --flexconsumption-location $location `
  --runtime powershell `
  --runtime-version 7.4 `
  --functions-version 4

# Enable the system-assigned managed identity
az functionapp identity assign --resource-group $rg --name $appName

# Grant the identity rights to start the VM (scope to RG or the VM itself)
$principalId = az functionapp identity show --resource-group $rg --name $appName --query principalId -o tsv
$vmRg        = "<your-vm-resource-group>"
$subId       = az account show --query id -o tsv

az role assignment create `
  --assignee $principalId `
  --role "Virtual Machine Contributor" `
  --scope "/subscriptions/$subId/resourceGroups/$vmRg"

# Configure target VM app settings
az functionapp config appsettings set --resource-group $rg --name $appName --settings `
  SUBSCRIPTION_ID=$subId `
  RESOURCE_GROUP=$vmRg `
  VM_NAME="<your-vm-name>"

# Bundle the Az modules with the app (required - managed deps not supported)
./install-modules.ps1

# Publish the code
func azure functionapp publish $appName
```

## Run locally

1. Fill in `local.settings.json` with your `SUBSCRIPTION_ID`, `RESOURCE_GROUP`, `VM_NAME`.
2. Download the bundled modules: `./install-modules.ps1`.
3. Sign in so the local host can authenticate: `Connect-AzAccount`.
4. Start the host: `func start`.

## Call the HTTP trigger

```powershell
# Uses VM from app settings
curl "https://<appName>.azurewebsites.net/api/StartVMHttp?code=<function-key>"

# Or override the target VM per request
curl -X POST "https://<appName>.azurewebsites.net/api/StartVMHttp?code=<function-key>" `
  -H "Content-Type: application/json" `
  -d '{"SubscriptionId":"...","ResourceGroup":"...","VmName":"..."}'
```

## Change the timer schedule

Edit the `schedule` (NCRONTAB) in [StartVMTimer/function.json](StartVMTimer/function.json).
Default `0 0 7 * * 1-5` = 07:00 UTC, Monday–Friday.
