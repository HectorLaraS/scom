<# 
SCOM 2019 - Export monitors inventory with target class + alert settings
Output: C:\Temp\SCOM2019_Monitors_Report.csv
#>

Import-Module OperationsManager
# Si lo ejecutas desde otra máquina, descomenta:
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

$exportPath = "C:\Temp\SCOM2019_Monitors_Report.csv"

# Asegura que exista el folder
$dir = Split-Path $exportPath -Parent
if (-not (Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
}

Get-SCOMMonitor |
    Select-Object `
        @{n='MonitorDisplayName';e={$_.DisplayName}},
        @{n='MonitorName';e={$_.Name}},
        @{n='Enabled';e={$_.Enabled}},
        @{n='ManagementPack';e={$_.ManagementPackName}},

        # Target class details (expand Target object)
        @{n='TargetClassDisplayName';e={$_.Target.DisplayName}},
        @{n='TargetClassName';e={$_.Target.Name}},
        @{n='TargetClassId';e={$_.Target.Id}},

        # Alert settings
        @{n='GeneratesAlert';e={
            $as = $_.AlertSettings
            if ($null -eq $as) { return $false }
            if ($as.AlertOnState -and ($as.AlertOnState.ToString() -ne 'None')) { return $true }
            return $false
        }},
        @{n='AlertOnState';e={$_.AlertSettings.AlertOnState}},
        @{n='Priority';e={$_.AlertSettings.AlertPriority}},
        @{n='Severity';e={$_.AlertSettings.AlertSeverity}} |
    Sort-Object ManagementPack, MonitorDisplayName |
    Export-Csv $exportPath -NoTypeInformation -Encoding UTF8

"✅ Report generated: $exportPath"
