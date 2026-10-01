# 📥 Guide d'Installation - agentMemory

Ce guide couvre toutes les méthodes d'installation d'agentMemory selon votre environnement.

## Prérequis

| Prérequis | Version Minimale | Notes |
|-----------|------------------|-------|
| **Node.js** | 18.x ou plus | Requis pour le serveur MCP |
| **npm** | 9.x ou plus | Comes avec Node.js |
| **VS Code** | 1.85.0+ | Pour l'extension |
| **Python** | 3.8+ | Optionnel, pour scripts |

> **Note** : Vous n'avez PAS besoin de Docker - agentMemory fonctionne entièrement en local !

---

## Méthode 1 : Installation VS Code (Recommandée)

### Étape 1 : Rechercher l'Extension

1. Ouvrir **VS Code**
2. Aller dans **Extensions** (Ctrl+Shift+X / Cmd+Shift+X)
3. Rechercher **"agentMemory"**
4. Cliquer sur **Install**

### Étape 2 : Configuration Automatique

L'extension effectue automatiquement :
- ✅ Création de la configuration MCP dans `.vscode/settings.json`
- ✅ Injection des instructions memory-first dans les memory banks
- ✅ Démarrage de la synchronisation bidirectionnelle
- ✅ Activation du dashboard

### Étape 3 : Redémarrer VS Code

```
Cmd/Ctrl + R
```

---

## Méthode 2 : Installation Manuelle (Développement)

### Étape 1 : Cloner le Projet

```bash
git clone https://github.com/webzler/agentMemory
cd agentMemory
```

### Étape 2 : Installer les Dépendances

```bash
npm install
```

### Étape 3 : Compiler le Projet

```bash
npm run compile
```

### Étape 4 : Créer le Package VSIX

```bash
npm run package
```

### Étape 5 : Installer l'Extension

```bash
# Via VSIX (après npm run package)
code --install-extension agentmemory-0.1.0.vsix
```

---

## Méthode 3 : Serveur MCP Standalone

Pour utiliser agentMemory sans l'extension VS Code :

### Option A : Avec Node.js Direct

```bash
# Compiler d'abord
npm run compile

# Lancer le serveur
npm run start-server <project_id> <chemin_workspace>

# Exemple
npm run start-server mon-projet "C:/Users/MonCompte/mon-projet"
```

### Option B : Avec npx

```bash
# Version rapide (sans compilation)
npx agentmemory-server <project_id> <chemin_workspace>
```

### Configuration du Port

Le serveur MCP utilise :
- **Stdio** : Communication standard (recommandé)
- **Unix Socket** : `/tmp/mcp-memory-{project}.sock`
- **Dashboard** : `http://localhost:3333`

---

## Méthode 4 : Intégration Windsurf/Codeium

### Prérequis Windsurf

1. Installer **Windsurf** depuis [codeium.com/windsurf](https://codeium.com/windsurf)
2. Assurez-vous d'avoir accès à **Cascade** (l'agent IA de Windsurf)

### Configuration MCP pour Windsurf

#### Étape 1 : Créer le Fichier de Configuration

Créez `.windsurf/mcp_config.json` :

```json
{
  "mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [
        "chemin/vers/agentMemory/out/mcp-server/server.js",
        "nom-projet",
        "chemin/absolu/vers/votre-projet"
      ],
      "env": {
        "NODE_ENV": "development"
      }
    }
  }
}
```

#### Étape 2 : Redémarrer Windsurf

```
Cmd/Ctrl + R
```

#### Étape 3 : Vérifier la Configuration

Dans Windsurf, ouvrez la palette de commandes :
```
Cmd/Ctrl + Shift + P
```
Tapez `MCP` et recherchez "agentMemory".

---

## Méthode 5 : Intégration Trae

### Configuration MCP pour Trae

Créez `.trae/mcp.json` :

```json
{
  "servers": {
    "memory": {
      "type": "stdio",
      "command": "node",
      "args": [
        "chemin/vers/agentMemory/out/mcp-server/server.js",
        "trae-project",
        "${workspace}"
      ]
    }
  }
}
```

---

## Méthode 6 : Intégration RooCode

### Configuration MCP pour RooCode

Ajoutez dans votre `settings.json` VS Code :

```json
{
  "rooCodeplus.mcpServers": {
    "agentMemory": {
      "command": "node",
      "args": [
        "${workspace}/node_modules/agentmemory/out/mcp-server/server.js",
        "${workspaceBasename}",
        "${workspace}"
      ]
    }
  }
}
```

---

## Configuration Avancée

### Variables d'Environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `AGENTMEMORY_STORAGE` | `./.agentMemory` | Chemin de stockage |
| `AGENTMEMORY_CACHE_SIZE` | `10000` | Taille du cache LRU |
| `AGENTMEMORY_CACHE_TTL` | `3600` | TTL du cache en secondes |
| `AGENTMEMORY_DASHBOARD_PORT` | `3333` | Port du dashboard |

### Configuration de la Storage

Dans `.vscode/settings.json` :

```json
{
  "agentMemory.enabled": true,
  "agentMemory.storageLocation": "./mcp-data",
  "agentMemory.cacheSize": 10000,
  "agentMemory.cacheTTL": 3600
}
```

---

## Dépannage

### Problème : Le Serveur MCP Ne Démarre Pas

```bash
# Vérifier Node.js
node --version  # Doit être >= 18

# Vérifier les dépendances
npm ls @modelcontextprotocol/sdk

# Lancer en mode debug
node --inspect out/mcp-server/server.js
```

### Problème : Connexion Refusée

1. Vérifier que le serveur MCP est en cours d'exécution
2. Vérifier le chemin du socket Unix
3. Redémarrer l'IDE

### Problème : Extension Non Détectée

1. Vérifier dans VS Code : `Extensions` → Rechercher "agentMemory"
2. Si pas installée, suivre **Méthode 1**
3. Vérifier la version VS Code (doit être >= 1.85)

### Problème : Erreurs de Synchronisation

```bash
# Supprimer le cache
rm -rf .agentMemory/cache

# Réinitialiser le projet
node out/mcp-server/server.js <project_id> <workspace> --reinit
```

---

## Mise à Jour

### Mettre à Jour l'Extension VS Code

1. Aller dans **Extensions**
2. Cliquer sur **Update** pour agentMemory

### Mettre à Jour Manuellement

```bash
git pull
npm install
npm run compile
npm run package
code --install-extension agentmemory-0.1.0.vsix
```

---

## Désinstallation

### Extension VS Code

1. Extensions → agentMemory → **Uninstall**
2. Supprimer `.agentMemory/` si désiré

### Serveur Standalone

```bash
# Arrêter le processus
pkill -f agentMemory

# Supprimer les données
rm -rf .agentMemory/
```

---

## Prochaines Étapes

Une fois installé, consultez :
- **[FONCTIONNEMENT.md](FONCTIONNEMENT.md)** - Comprendre le flux de données
- **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - Utiliser les outils MCP
- **[IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md)** - Configuration spécifique IDE
