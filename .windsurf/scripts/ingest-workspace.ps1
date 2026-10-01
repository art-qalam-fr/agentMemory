Param(
    [ValidateSet('watch','once')]
    [string]$Mode = 'once',
    [string]$ConfigPath = "",
    [switch]$Force = $false
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "ingestion.config.json"
}

function Load-Config {
    param([string]$Path)
    if (-not (Test-Path $Path)) { throw "Config file not found: $Path" }
    return Get-Content $Path -Raw | ConvertFrom-Json
}

function Should-Exclude {
    param($Path, $Excludes)
    if ($Path -match "ingestion\.log$") { return $true }
    foreach ($pattern in $Excludes) {
        if ($Path -like $pattern) { return $true }
    }
    return $false
}

function Collect-Files {
    param($cfg)
    $ProjectRoot = Split-Path -Parent $PSScriptRoot
    $root = $ProjectRoot
    $maxBytes = $cfg.ingestion.sources.max_file_size_mb * 1MB
    Write-Host "[ingest] Collecte des fichiers dans : $root"
    $files = Get-ChildItem -Path $root -Recurse -File -Force -ErrorAction SilentlyContinue
    $filtered = $files | Where-Object {
        -not (Should-Exclude $_.FullName $cfg.ingestion.sources.exclude) -and
        $_.Length -le $maxBytes
    }
    Write-Host "[ingest] $($filtered.Count) fichiers trouvés."
    return $filtered
}

function Build-Document {
    param($file, $cfg)
    $content = Get-Content $file.FullName -Raw
    $meta = [ordered]@{
        path = $file.FullName
        size_bytes = $file.Length
        modified = $file.LastWriteTimeUtc
        workspace = $cfg.ingestion.metadata.workspace
    }
    return [ordered]@{
        metadata = $meta
        content = $content
    }
}

function Ingest-Once {
    param($cfg, $incrementalFiles = $null)
    
    $CurrentProjectRoot = Split-Path -Parent $PSScriptRoot
    $logFile = Join-Path $PSScriptRoot "ingestion.log"
    
    # Notification de scan terminé - Cascade prend le relais
    $msg = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [ingest] Scan terminé. Prêt pour synchronisation MCP directe par Cascade."
    Write-Host $msg
    Add-Content -Path $logFile -Value $msg
}

$config = Load-Config $ConfigPath
Ingest-Once $config
