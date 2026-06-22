<#
.SYNOPSIS
    Downloads the required Az modules into the app's 'Modules' folder so they are
    deployed together with the function app content.

.DESCRIPTION
    Managed Dependencies (requirements.psd1) are NOT supported on Linux Consumption
    (Legion). Instead, the modules must be packaged with the app. Run this script
    once locally before deploying. The downloaded modules are picked up automatically
    because the 'Modules' folder is on the PSModulePath at runtime.

    See: https://aka.ms/functions-powershell-include-modules

.NOTES
    Requires PowerShell 7.x and the PowerShellGet module.
#>
[CmdletBinding()]
param(
    # Pin to the same major versions previously used in requirements.psd1.
    [hashtable] $Modules = @{
        'Az.Accounts' = '5.*'
        'Az.Compute'  = '9.*'
    }
)

$ErrorActionPreference = 'Stop'

$targetPath = Join-Path $PSScriptRoot 'Modules'
if (-not (Test-Path $targetPath)) {
    New-Item -ItemType Directory -Path $targetPath | Out-Null
}

foreach ($name in $Modules.Keys) {
    $version = $Modules[$name]
    Write-Host "Saving $name ($version) to $targetPath ..."

    $saveParams = @{
        Name            = $name
        Path            = $targetPath
        Repository      = 'PSGallery'
        Force           = $true
        ErrorAction     = 'Stop'
    }

    # Translate a wildcard pin (e.g. '5.*') into a minimum version constraint.
    if ($version -match '^\d+') {
        $major = ($version -split '\.')[0]
        $saveParams['MinimumVersion'] = "$major.0.0"
        $saveParams['MaximumVersion'] = "$([int]$major + 1).0.0"
    }

    Save-Module @saveParams
}

Write-Host "Done. The following modules are bundled under '$targetPath':"
Get-ChildItem -Path $targetPath -Directory | Select-Object Name | Format-Table -AutoSize
