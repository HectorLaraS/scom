Import-Module OperationsManager
# Si lo ejecutas desde otra máquina:
# New-SCOMManagementGroupConnection -ComputerName "TU-MGMT-SERVER"

$monitors = Get-SCOMMonitor

$results = foreach ($m in $monitors) {

    $targetDisplayName = $null
    $targetName        = $null
    $targetType        = $null

    # 1) Intenta sacar Target directo si viene poblado
    if ($m.Target -and $m.Target.Name) {
        $targetDisplayName = $m.Target.DisplayName
        $targetName        = $m.Target.Name
        $targetType        = "Class"
    }
    else {
        # 2) Resolver por ID (lo más confiable en 2019)
        $targetId = $null

        # Distintas builds exponen TargetId diferente; probamos varias
        if ($m.PSObject.Properties.Match("TargetId").Count -gt 0) {
            $targetId = $m.TargetId
        } elseif ($m.PSObject.Properties.Match("Target").Count -gt 0 -and $m.Target) {
            # a veces Target viene como GUID/string
            $targetId = $m.Target
        }

        if ($targetId) {
            # 2a) Primero intenta como CLASE
            $cls = $null
            try { $cls = Get-SCOMClass -Id $targetId -ErrorAction Stop } catch {}

            if ($cls) {
                $targetDisplayName = $cls.DisplayName
                $targetName        = $cls.Name
                $targetType        = "Class"
            }
            else {
                # 2b) Si no es clase, intenta como GRUPO
                $grp = $null
                try { $grp = Get-SCOMGroup -Id $targetId -ErrorAction Stop } catch {}

                if ($grp) {
                    $targetDisplayName = $grp.DisplayName
                    $targetName        = $grp.Name
                    $targetType        = "Group"
                }
                else {
                    $targetDisplayName = $null
                    $targetName        = $null
                    $targetType        = "Unknown"
                }
            }
        }
        else {
            $targetType = "Unknown"
        }
    }

    # Alert settings
    $alertSettings = $m.AlertSettings
    $generatesAlert = $false
    $alertOnState   = $null
    $priority       = $null
    $severity       = $null

    if ($alertSettings) {
        $alertOnState = $alertSettings.AlertOnState
        $priority     = $alertSettings.AlertPriority
        $severity     = $alertSettings.AlertSeverity
        if ($alertOnState -and ($alertOnState.ToString() -ne "None")) { $generatesAlert = $true }
    }

    [pscustomobject]@{
        MonitorDisplayName = $m.DisplayName
        MonitorName        = $m.Name
        Enabled            = $m.Enabled
        ManagementPack     = $m.ManagementPackName

        TargetDisplayName  = $targetDisplayName
        TargetName         = $targetName
        TargetType         = $targetType

        GeneratesAlert     = $generatesAlert
        AlertOnState       = $alertOnState
        Priority           = $priority
        Severity           = $severity
    }
}

$results |
  Sort-Object ManagementPack, MonitorDisplayName |
  Export-Csv "C:\Temp\SCOM2019_Monitors_With_Target.csv" -NoTypeInformation -Encoding UTF8
