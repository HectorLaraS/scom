Import-Module OperationsManager
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

$m = Get-SCOMMonitor | Select-Object -First 1

"Monitor: $($m.DisplayName)"
"Target type: $($m.Target.GetType().FullName)"
"Target string: $($m.Target)"

"--- Target properties ---"
$m.Target | Get-Member -MemberType Properties | Select-Object Name, Definition
