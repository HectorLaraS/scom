Import-Module OperationsManager
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

Get-SCOMMonitor |
    Select-Object DisplayName, Name, Enabled, Target, ManagementPackName |
    Sort-Object ManagementPackName, DisplayName |
    Export-Csv "C:\Temp\SCOM_Monitors.csv" -NoTypeInformation -Encoding UTF8
