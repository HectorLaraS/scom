# 1. Obtener los nombres de todas las clases
$classNames = Get-SCOMClass | Select-Object -ExpandProperty Name

# 2. Para cada clase, obtener sus instancias y guardarlas en un arreglo
$instances = foreach ($className in $classNames) {
    $class = Get-SCOMClass | Where-Object { $_.Name -eq $className }
    if ($class) {
        Get-SCOMClassInstance -Class $class | 
            Select-Object @{Name="ClassName";Expression={$className}}, Id, DisplayName, Name
    }
}

# 3. Exportar a CSV
$exportPath = "C:\Temp\SCOM_ClassInstances_ByClass.csv"
$instances | Export-Csv -Path $exportPath -NoTypeInformation