# Windows Event Correlation Analyzer

A read-only PowerShell toolkit for correlating repeated Windows errors and warnings.

## Features

- System and Application event collection
- Grouping by provider and event ID
- Repeated-error ranking
- CSV, JSON, and HTML reports

## Run

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\Windows_Event_Correlation_Analyzer.ps1
```

## Safety

Read-only reporting only. No system settings are changed.
