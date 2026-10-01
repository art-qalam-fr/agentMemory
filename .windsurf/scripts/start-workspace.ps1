Param(
    [ValidateSet('auto','force','skip')]
    [string]$IngestMode = 'auto',
    [switch]$Watch = $true,
    [switch]$Quiet = $true
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptRoot
$autoIngest = Join-Path $ScriptRoot 'auto-ingest.ps1'
$ingestScript = Join-Path $ScriptRoot 'ingest-workspace.ps1'
$ingestConfig = Join-Path $ScriptRoot 'ingestion.config.json'
$monitorScript = Join-Path $ScriptRoot 'monitor.js'

# --- INITIALISATION STRUCTURELLE CRITIQUE (SYNCHRONE) ---
$MemoryDbRoot = Join-Path $ScriptRoot "../memory-database"
$GraphDir = Join-Path $MemoryDbRoot "graph"
$VectorDir = Join-Path $MemoryDbRoot "vector"
$CacheDir = Join-Path $MemoryDbRoot "cache"
$KnowledgeDir = Join-Path $ScriptRoot "../knowledge"

# Création immédiate des dossiers parents UNIQUEMENT.
# Les fichiers .db seront créés proprement par les serveurs MCP lors de l'accès.
$criticalDirs = @($GraphDir, $VectorDir, $CacheDir, $KnowledgeDir)
foreach ($dir in $criticalDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

Write-Host "[start-workspace] Structure de répertoires locale synchronisée."

# --- REDIRECTION PAR JONCTION (ISOLATION ROBUSTE) ---
$JunctionPoint = "F:\Sqlite-DB\current_workspace"
$CacheJunction = Join-Path $ProjectRoot "semantic-cache-data"

Write-Host "[start-workspace] Mise à jour des points de montage Junction..."

# 1. Junction principale (Mémoire & Vector)
if (Test-Path $JunctionPoint) {
    $cmd = "cmd /c rmdir `"$JunctionPoint`""
    Invoke-Expression $cmd | Out-Null
    if (Test-Path $JunctionPoint) { Remove-Item -Path $JunctionPoint -Force -Recurse | Out-Null }
}
$targetPath = Join-Path $ProjectRoot "memory-database"
if (-not (Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath -Force | Out-Null }
New-Item -ItemType Junction -Path $JunctionPoint -Target $targetPath -Force | Out-Null

# 2. Junction Cache (Rediriger semantic-cache-data vers memory-database/cache)
# NOTE: Cette jonction doit être à la RACINE du projet car le serveur de cache cherche ./semantic-cache-data
$ProjectRootDir = Split-Path -Parent $ScriptRoot
$CacheJunctionAtRoot = Join-Path $ProjectRootDir "semantic-cache-data"

Write-Host "[start-workspace] Nettoyage et création du tunnel Cache..."
if (Test-Path $CacheJunctionAtRoot) {
    Write-Host "  [!] Libération du verrou sur $CacheJunctionAtRoot..."
    # Tenter de tuer les processus node qui pourraient verrouiller la DB
    # EXCLUSION : On ne tue JAMAIS les processus dont le nom contient "Windsurf" ou "Code"
    $lockingProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object { 
        try {
            $isNode = $_.Name -eq "node" -or $_.Path -like "*node.exe*"
            $isNotIDE = $_.Path -notlike "*Windsurf*" -and $_.Path -notlike "*Code*" -and $_.CommandLine -notlike "*Windsurf*"
            
            if ($isNode -and $isNotIDE) {
                $_.CommandLine -like "*cache*" -or 
                $_.CommandLine -like "*semantic-cache-data*" -or
                ($_.Path -and (Test-Path $_.Path) -and ($_.Modules.FileName -contains "better-sqlite3"))
            } else { $false }
        } catch { $false }
    }
    if ($lockingProcs) {
        $lockingProcs | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }

    # Suppression agressive via CMD pour forcer si nécessaire
    cmd /c "rmdir /s /q `"$CacheJunctionAtRoot`"" 2>$null
    
    # Fallback si rmdir échoue
    if (Test-Path $CacheJunctionAtRoot) {
        Remove-Item -Path $CacheJunctionAtRoot -Force -Recurse -ErrorAction SilentlyContinue | Out-Null
    }
}

$cacheTarget = Join-Path $targetPath "cache"
if (-not (Test-Path $cacheTarget)) { New-Item -ItemType Directory -Path $cacheTarget -Force | Out-Null }

# Création forcée de la Junction
New-Item -ItemType Junction -Path $CacheJunctionAtRoot -Target $cacheTarget -Force | Out-Null

Write-Host "  [!] Redirections actives :"
Write-Host "      - Global -> $JunctionPoint"
Write-Host "      - Local Cache -> $CacheJunctionAtRoot"

# Lancer le moniteur en arrière-plan
Write-Host "[start-workspace] Lancement du Moniteur (Port 3055)"
Start-Process node -ArgumentList $monitorScript -WindowStyle Hidden

Write-Host "[start-workspace] Vérification/ingestion initiale ($IngestMode)"
& powershell -ExecutionPolicy Bypass -File $autoIngest -Mode $IngestMode -ConfigPath $ingestConfig

if ($Watch) {
    Write-Host "[start-workspace] Lancement de la surveillance continue (Ctrl+C pour arrêter)"
    $cmdArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $ingestScript, "-Mode", "watch", "-ConfigPath", $ingestConfig)
    if ($Quiet) { $cmdArgs += "-Quiet" }
    & powershell @cmdArgs
}
else {
    Write-Host "[start-workspace] Surveillance désactivée (paramètre -Watch:$false)"
}
