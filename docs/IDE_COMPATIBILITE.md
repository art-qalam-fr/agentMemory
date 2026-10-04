# 💻 Compatibilité IDE - agentMemory

Guide complet pour utiliser agentMemory avec différents IDE et extensions.

---

## Vue d'Ensemble des IDE Supportés

| IDE | Support | Méthode d'Intégration |
|-----|---------|----------------------|
| **VS Code + Extension** | ✅ Complet | Extension native |
| **Devin** | ✅ Complet | Configuration MCP |
| **KiloCode** | ✅ Complet | Sync automatique |
| **Cline** | ✅ Complet | Sync automatique |
| **RooCode** | ✅ Complet | Sync automatique |
| **Trae** | ✅ Complet | Configuration MCP |
| **Cursor** | ⚠️ Partiel | MCP externe |
| **Codeium (Extension)** | ✅ Complet | Via Devin |

---

## VS Code - Extension Native

### Installation

1. Ouvrir VS Code
2. Extensions → Rechercher "agentMemory"
3. Installer et redémarrer

### Configuration

L'extension crée automatiquement :

```json
// .vscode/settings.json
{
  "agentMemory.enabled": true,
  "agentMemory.storageLocation": "./mcp-data",
  "agentMemory.cacheSize": 10000,
  "agentMemory.cacheTTL": 3600
}
```

### Commandes

| Commande | Raccourci |
|----------|-----------|
| `agentMemory.openDashboard` | `Ctrl+Shift+P` → "Open Memory Dashboard" |
| `agentMemory.showStats` | `Ctrl+Shift+P` → "Show Memory Stats" |
| `agentMemory.startDashboardServer` | Mode debug |

---

## Devin (Codeium)

### À Propos de Devin

Devin est l'IDE de Codeium avec l'agent IA **Cascade** intégré. Il supporte nativement MCP.

### Configuration MCP

#### Méthode 1 : Fichier de Configuration (Recommandée)

Créez `.devin/mcp_config.json` à la racine du projet :

```json
{
  "mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [
        "${workspace}/../agentMemory/out/mcp-server/server.js",
        "${workspaceBasename}",
        "${workspace}"
      ],
      "env": {
        "NODE_ENV": "development"
      }
    }
  }
}
```

> **Note** : Ajustez le chemin vers agentMemory selon votre installation.

#### Méthode 2 : Configuration Utilisateur

Ajoutez dans les paramètres utilisateur Devin :

```json
{
  "mcpServers": {
    "agentMemory": {
      "command": "node",
      "args": [
        "chemin/vers/agentMemory/out/mcp-server/server.js",
        "nom-projet",
        "chemin/workspace"
      ]
    }
  }
}
```

#### Méthode 3 : Via settings.json Projet

Dans `.vscode/settings.json` :

```json
{
  "codeium.devin.mcpServers": {
    "agentMemory": {
      "url": "unix:///tmp/mcp-memory-monprojet.sock"
    }
  }
}
```

### Activation avec Cascade

1. Démarrer Devin avec un projet configuré
2. Cascade détectera automatiquement agentMemory
3. Les instructions memory-first seront injectées
4. Utiliser les outils MCP directement dans les prompts

### Vérification

```
Cmd/Ctrl + Shift + P
→ Tapez "MCP"
→ Vérifier que agentMemory est listé
```

---

## KiloCode

### Support Natif

KiloCode est **nativement supporté** par agentMemory. La synchronisation est automatique.

### Emplacement Memory Bank

```
.kilocode/rules/memory-bank/
├── brief.md
├── product.md
├── context.md
├── architecture.md
└── tech.md
```

### Flux de Travail

1. **Détection** : agentMemory détecte KiloCode installé
2. **Import** : Importe les fichiers existants au premier lancement
3. **Sync** : Synchronisation bidirectionnelle automatique

### Configuration

Aucun configuration manuelle nécessaire !

### Personnalisation

Pour modifier le comportement :

```json
// .vscode/settings.json
{
  "kilocode.mcpServers": {
    "memory-bank": {
      "url": "unix:///tmp/mcp-memory-{project}.sock"
    }
  }
}
```

---

## Cline

### Support Natif

Cline (anciennement Claude Dev) est **nativement supporté**.

### Emplacement Memory Bank

```
.clinerules/memory-bank/
├── projectBrief.md
├── productContext.md
├── activeContext.md
├── systemPatterns.md
├── techContext.md
└── progress.md
```

### Configuration

```json
// .vscode/settings.json
{
  "cline.mcpServers": {
    "memory-bank": {
      "url": "unix:///tmp/mcp-memory-{project}.sock"
    }
  }
}
```

### Utilisation avec Cline

Cline lira automatiquement les fichiers memory bank au démarrage. Utilisez :

```markdown
# Dans votre contexte

Utilisez agentMemory pour documenter les décisions importantes.
Appelez memory_write() après chaque implémentation significative.
```

---

## RooCode

### Support Natif

RooCode (Roo Veterinary Inc.) est **nativement supporté**.

### Emplacement Memory Bank

```
.roo/memory-bank/
├── projectBrief.md
├── productContext.md
├── activeContext.md
├── systemPatterns.md
├── techContext.md
├── progress.md
└── decisionLog.md
```

### Configuration

```json
// settings.json
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

## Trae

### Configuration MCP

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

### Utilisation

1. Lancer Trae avec le projet configuré
2. Le serveur MCP démarre automatiquement
3. Les outils sont disponibles via les prompts

---

## Cursor

### Support Partiel

Cursor n'a pas de support MCP natif complet. Utilisez une configuration externe.

### Option 1 : Serveur Externe

Démarrez le serveur MCP séparément :

```bash
npm run start-server cursor-project /path/to/workspace
```

### Option 2 : Intégration via Extension

Utilisez une extension MCP tiers pour Cursor, puis configurez agentMemory.

---

## Codeium (Extension VS Code)

### Via Devin

L'extension Codeium dans VS Code peut être remplacée par Devin pour le support MCP complet.

### Configuration Alternative

Si vous utilisez l'extension Codeium单独的 :

```json
{
  "codeium.extensionPath": "chemin/vers/extension"
}
```

---

## Tableau Récapitulatif

| IDE | Native MCP | Memory Bank Sync | Dashboard |
|-----|------------|------------------|-----------|
| VS Code + ext | ✅ | ✅ | ✅ |
| Devin | ✅ | ✅ | ✅ |
| KiloCode | ⚠️ Via ext | ✅ | ✅ |
| Cline | ⚠️ Via ext | ✅ | ✅ |
| RooCode | ⚠️ Via ext | ✅ | ✅ |
| Trae | ✅ | ⚠️ Config | ⚠️ Config |
| Cursor | ⚠️ Externe | ⚠️ Externe | ⚠️ Externe |

---

## Dépannage Commun

### Problème : IDE Ne Détecte Pas MCP

1. Vérifier la configuration :
   ```bash
   cat .vscode/settings.json | grep mcp
   ```

2. Redémarrer l'IDE
3. Vérifier les logs MCP

### Problème : Conflit de Port

Si plusieurs instances utilisent le même socket :

```bash
# Supprimer les sockets existants
rm /tmp/mcp-memory-*.sock
```

### Problème : Extension Non Détectée

```bash
# Script de détection
node detect-agents.js
```

---

## Prochaines Étapes

- **[INSTALLATION.md](INSTALLATION.md)** - Guide d'installation
- **[DEVIN_CASCADE.md](DEVIN_CASCADE.md)** - Guide Devin/Cascade spécifique
- **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - Configuration MCP avancée
