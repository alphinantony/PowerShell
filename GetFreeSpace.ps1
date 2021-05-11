$DriveFreeSpace = Get-CimInstance -ClassName Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "D:" }  | Select-Object -Property Size, DeviceID, @{'Name' = 'FreeSpace (GB)'; Expression = { [Math]::Round($_.FreeSpace / 1GB, 2) } }
$DriveFreeSpacePerc = "{0:p1}" -f (($DriveFreeSpace.'FreeSpace (GB)') / ($DriveFreeSpace.size / 1GB))
if ($DriveFreeSpace.'FreeSpace (GB)' -lt 30) {
    Write-Host $($DriveFreeSpace.'FreeSpace (GB)')GB "`n"  $DriveFreeSpacePerc
}