# CASCADE System Bootstrap (Asynchrone)
$PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Configuration
$MonitorScript = Join-Path $PSScriptRoot "monitor.js"
$IngestScript = Join-Path $PSScriptRoot "auto-ingest.ps1"

# 1. Vérifier et lancer le Monitor (Port 3055)
$monitorRunning = Get-Process node -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*monitor.js*" }
if (-not $monitorRunning) {
    Start-Process node -ArgumentList $MonitorScript -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# 2. Vérifier et lancer l'Ingestion
$ingestRunning = Get-Process powershell -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*auto-ingest.ps1*" }
if (-not $ingestRunning) {
    Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$IngestScript`" -Mode auto" -WindowStyle Hidden -ErrorAction SilentlyContinue
}

# Sortie immédiate pour ne pas bloquer Cascade
exit 0
