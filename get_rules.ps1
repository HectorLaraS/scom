<# 
SCOM 2019 - Export rules inventory with target class + alert settings
Output: C:\Temp\SCOM2019_Rules_Report.csv
#>

Import-Module OperationsManager
# Si lo ejecutas desde otra máquina, descomenta:
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

$exportPath = "C:\Temp\SCOM2019_Rules_Report.csv"

# Asegura que exista el folder
$dir = Split-Path $exportPath -Parent
if (-not (Test-Path $dir)) {
    New-Item -Path $dir -ItemType Directory -Force | Out-Null
}

Get-SCOMRule |
    Select-Object `
        @{n='RuleDisplayName';e={$_.DisplayName}},
        @{n='RuleName';e={$_.Name}},
        @{n='Enabled';e={$_.Enabled}},
        @{n='ManagementPack';e={$_.ManagementPackName}},

        # Target class details (expand Target object)
        @{n='TargetClassDisplayName';e={$_.Target.DisplayName}},
        @{n='TargetClassName';e={$_.Target.Name}},
        @{n='TargetClassId';e={$_.Target.Id}},

        # Alert settings (Rules también pueden traer AlertSettings)
        @{n='GeneratesAlert';e={
            $as = $_.AlertSettings
            if ($null -eq $as) { return $false }

            # En rules, si hay AlertSettings normalmente es porque genera alertas
            # (dejamos lógica tolerante)
            if ($as.AlertName -or $as.AlertDescription -or $as.AlertSeverity -or $as.AlertPriority) { return $true }

            return $false
        }},
        @{n='AlertName';e={$_.AlertSettings.AlertName}},
        @{n='AlertOnState';e={$_.AlertSettings.AlertOnState}},   # a veces viene null en rules, lo dejamos
        @{n='Priority';e={$_.AlertSettings.AlertPriority}},
        @{n='Severity';e={$_.AlertSettings.AlertSeverity}} |
    Sort-Object ManagementPack, RuleDisplayName |
    Export-Csv $exportPath -NoTypeInformation -Encoding UTF8

"✅ Report generated: $exportPath"
