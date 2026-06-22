@{
    RootModule        = 'StartVM.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'd2f5a3c1-9b4e-4c6a-8f7d-1a2b3c4d5e6f'
    Author            = 'StartVMFunctionApp'
    Description       = 'Shared helpers for starting an Azure VM from the Function App.'
    PowerShellVersion = '7.4'
    FunctionsToExport = @('Start-TargetVM')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
