$exportPath = "C:\Temp\SCOM2019_Classes_Report.csv"

Get-SCOMClass | Select-Object id, DisplayName, Name | Export-Csv -Path $exportPath -NoTypeInformation