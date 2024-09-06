$Duration = 30 * 60 # 30 Minuten
$Interval = 10
$TempFile = [System.IO.Path]::GetTempFileName()
function Monitor-Processes {
    while ($true) {
        Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | ForEach-Object {
            "$($_.Id) $($_.ProcessName) $($_.CPU) $($_.PM) $($_.Path)" | Out-File -Append -FilePath $TempFile
        }
        "-----------------------------" | Out-File -Append -FilePath $TempFile
        Start-Sleep -Seconds $Interval
    }
}
$MonitorJob = Start-Job -ScriptBlock { Monitor-Processes }
Start-Sleep -Seconds $Duration
Stop-Job $MonitorJob
Remove-Job $MonitorJob
Write-Host "Prozesse mit der höchsten Last:"
Get-Content $TempFile | Select-String -Pattern "^\d+" | Sort-Object | Group-Object | Sort-Object Count -Descending | Select-Object -First 10
Remove-Item $TempFile
