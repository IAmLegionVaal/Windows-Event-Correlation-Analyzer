#requires -Version 5.1
[CmdletBinding()]
param([int]$Hours=48,[string]$OutputPath)
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
if([string]::IsNullOrWhiteSpace($OutputPath)){$OutputPath=Join-Path ([Environment]::GetFolderPath('Desktop')) 'Event_Correlation_Reports'}
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$start=(Get-Date).AddHours(-1*$Hours)
$events=@()
foreach($log in 'System','Application'){$events+=Get-WinEvent -FilterHashtable @{LogName=$log;StartTime=$start;Level=1,2,3} -ErrorAction SilentlyContinue|Select-Object TimeCreated,LogName,Id,ProviderName,LevelDisplayName,Message}
$groups=$events|Group-Object LogName,ProviderName,Id|Sort-Object Count -Descending|ForEach-Object{[PSCustomObject]@{Count=$_.Count;LogName=$_.Group[0].LogName;ProviderName=$_.Group[0].ProviderName;EventId=$_.Group[0].Id;Level=$_.Group[0].LevelDisplayName;Latest=($_.Group|Sort-Object TimeCreated -Descending|Select-Object -First 1).TimeCreated}}
$events|Export-Csv (Join-Path $OutputPath "events_$stamp.csv") -NoTypeInformation -Encoding UTF8
$groups|Export-Csv (Join-Path $OutputPath "correlated_events_$stamp.csv") -NoTypeInformation -Encoding UTF8
@{Generated=Get-Date;Computer=$env:COMPUTERNAME;Hours=$Hours;EventCount=@($events).Count;Groups=$groups}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputPath "correlation_$stamp.json") -Encoding UTF8
$html="<h1>Windows Event Correlation - $env:COMPUTERNAME</h1><p>Generated $(Get-Date)</p><h2>Top Repeated Events</h2>$($groups|Select-Object -First 50|ConvertTo-Html -Fragment)"
$html|ConvertTo-Html -Title 'Windows Event Correlation'|Set-Content (Join-Path $OutputPath "correlation_$stamp.html") -Encoding UTF8
$groups|Select-Object -First 20|Format-Table -AutoSize
Write-Host "Reports saved to: $OutputPath" -ForegroundColor Green
