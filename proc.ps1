$DurationInput = Read-Host "Wie lange möchtest du die Prozesse überwachen? (in Minuten)"
$Duration = [int]$DurationInput * 60
$Interval = 10
$Hostname = $env:COMPUTERNAME
$OutputFile = "pocmon-$Hostname.txt"
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
Write-Host "Prozesse mit der höchsten Last:" | Out-File -FilePath $OutputFile -Append
Get-Content $TempFile | Select-String -Pattern "^\d+" | Sort-Object | Group-Object | Sort-Object Count -Descending | Select-Object -First 10 | ForEach-Object {
    $_.Group | Out-File -Append -FilePath $OutputFile
}
Remove-Item $TempFile
Write-Host "Output wurde in der Datei $OutputFile gespeichert."
