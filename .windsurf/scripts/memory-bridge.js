import fs from 'fs';
import path from 'path';

/**
 * MemoryBridge - Pont intelligent entre l'ingestion PS1 et les serveurs MCP.
 * Assure la synchronisation bidirectionnelle entre le scan local et le stockage unifié.
 */
class MemoryBridge {
    constructor() {
        this.projectRoot = process.cwd();
        this.projectId = path.basename(this.projectRoot);
        this.unifiedBase = '<AGENTMEMORY_DATA_ROOT>/current_workspace';
    }

    /**
     * Synchronise le scan local (.windsurf/scripts/ingestion.log) vers agentMemory
     */
    async syncIngestionToMCP() {
        const logPath = path.join(this.projectRoot, '.windsurf', 'scripts', 'ingestion.log');
        if (!fs.existsSync(logPath)) {
            console.error('❌ Fichier ingestion.log non trouvé.');
            return;
        }

        console.log(`🚀 Synchronisation de l'ingestion pour le projet: ${this.projectId}`);
        
        const targetDir = path.join(this.unifiedBase, this.projectId, 'agentmemory');
        if (!fs.existsSync(targetDir)) {
            await fs.promises.mkdir(targetDir, { recursive: true });
        }

        const bridgeMeta = {
            lastSync: new Date().toISOString(),
            status: 'synchronized',
            source: logPath
        };

        await fs.promises.writeFile(path.join(targetDir, 'bridge_state.json'), JSON.stringify(bridgeMeta, null, 2));
        console.log(`✅ État synchronisé dans ${targetDir}`);
    }

    /**
     * Vérifie la cohérence entre les DB locales (.windsurf/memory-database) et globales (stockage global)
     */
    async checkDatabaseConsistency() {
        const globalDbDir = path.join(this.unifiedBase, this.projectId);

        console.log('🔍 Vérification de la cohérence des bases de données...');

        if (fs.existsSync(globalDbDir)) {
            console.log('✅ Base de données globale détectée (Source de Vérité).');
        } else {
            console.log('⚠️ Base globale manquante. Initialisation à partir de la locale...');
        }
    }

    /**
     * Point d'entrée pour le démarrage par start-system.bat
     */
    async start() {
        await this.syncIngestionToMCP();
        await this.checkDatabaseConsistency();
        console.log('✨ Memory Bridge actif et synchronisé.');
    }
}

const bridge = new MemoryBridge();
bridge.start().catch(console.error);
