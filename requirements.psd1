# Managed Dependencies are NOT supported on Linux Consumption (Legion).
# Modules are instead bundled with the app under the 'Modules' folder.
# See https://aka.ms/functions-powershell-include-modules
# Keep this hashtable empty so the worker does not try to restore modules at runtime.
@{
  'Az' = '10.*'  
  'Az.Compute' = '5.*'
  
}
