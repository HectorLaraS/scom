Import-Module OperationsManager
# Si corres esto desde otra máquina:
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

$results = Get-SCOMMonitor | ForEach-Object {
    $m = $_

    $targetDisplayName = $null
    $targetClassName   = $null
    $targetType        = "Class"

    try {
        $targetDisplayName = $m.Target.DisplayName
        $targetClassName   = $m.Target.Name   # 👈 nombre interno de la clase

        if ($m.Target.BaseTypes -and
            ($m.Target.BaseTypes.Name -contains "Microsoft.SystemCenter.InstanceGroup")) {
            $targetType = "Group"
        }
    }
    catch {
        $targetDisplayName = $m.Target
        $targetClassName   = $null
        $targetType        = "Unknown"
    }

    $alertSettings = $m.AlertSettings

    $generatesAlert = $false
    $alertOnState   = $null
    $priority       = $null
    $severity       = $null

    if ($alertSettings) {
        $alertOnState = $alertSettings.AlertOnState
        $priority     = $alertSettings.AlertPriority
        $severity     = $alertSettings.AlertSeverity

        if ($alertOnState -and ($alertOnState.ToString() -ne "None")) {
            $generatesAlert = $true
        }
    }

    [pscustomobject]@{
        MonitorDisplayName = $m.DisplayName
        MonitorName        = $m.Name
        Enabled            = $m.Enabled
        ManagementPack     = $m.ManagementPackName

        TargetDisplayName  = $targetDisplayName
        TargetClassName    = $targetClassName   # 👈 lo que pedías
        TargetType         = $targetType

        GeneratesAlert     = $generatesAlert
        AlertOnState       = $alertOnState
        Priority           = $priority
        Severity           = $severity
    }
}

$results |
    Sort-Object ManagementPack, MonitorDisplayName |
    Export-Csv "C:\Temp\SCOM_Monitors_With_TargetClass.csv" `
        -NoTypeInformation -Encoding UTF8
