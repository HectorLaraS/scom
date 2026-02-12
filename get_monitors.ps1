Import-Module OperationsManager
# Si lo ejecutas remoto:
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

$out = Get-SCOMMonitor | ForEach-Object {
    $m = $_

    $targetName = $null
    $targetType = $null

    try {
        # Target suele ser una clase (ManagementPackClass)
        $targetName = $m.Target.DisplayName
        $targetType = "Class"

        # Si el target hereda de InstanceGroup, lo marcamos como "Group"
        # (algunos ambientes devuelven BaseTypes; si no, no truena el script)
        if ($m.Target.BaseTypes -and ($m.Target.BaseTypes.Name -contains "Microsoft.SystemCenter.InstanceGroup")) {
            $targetType = "Group"
        }
    } catch {
        $targetName = $m.Target
        $targetType = "Unknown"
    }

    $alertSettings = $m.AlertSettings

    $generatesAlert = $false
    $alertOnState = $null
    $priority = $null
    $severity = $null

    if ($alertSettings) {
        $alertOnState = $alertSettings.AlertOnState
        $priority     = $alertSettings.AlertPriority
        $severity     = $alertSettings.AlertSeverity

        # Normalmente: si AlertOnState viene seteado, el monitor genera alerta
        if ($alertOnState -and ($alertOnState.ToString() -notmatch "None")) {
            $generatesAlert = $true
        }
    }

    [pscustomobject]@{
        DisplayName        = $m.DisplayName
        Name               = $m.Name
        Enabled            = $m.Enabled                 # "esta activa"
        ManagementPack     = $m.ManagementPackName
        Target             = $targetName                # clase / grupo target
        TargetType         = $targetType                # Class o Group
        GeneratesAlert     = $generatesAlert            # "genera alerta"
        AlertOnState       = $alertOnState
        Priority           = $priority
        Severity           = $severity
    }
}

$out |
  Sort-Object ManagementPack, DisplayName |
  Export-Csv "C:\Temp\SCOM_Monitors_Detail.csv" -NoTypeInformation -Encoding UTF8
