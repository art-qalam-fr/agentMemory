# 🌊 Windsurf & Cascade - Guide d'Intégration

Guide spécifique pour configurer agentMemory avec Windsurf et l'agent Cascade.

---

## Pourquoi Windsurf ?

Windsurf est l'IDE nouvelle génération de Codeium avec :

- **Cascade** : Agent IA intégré pour le développement autonome
- **Support MCP natif** : Configuration simplifiée des outils externes
- **Flow-aware** : Compréhension du contexte de projet
- **Multi-fichiers** : Éditer plusieurs fichiers simultanément

---

## Architecture Windsurf + agentMemory

```
┌─────────────────────────────────────────────────────────────┐
│                      WINDSURF IDE                            │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────────────────────────────────────────┐    │
│  │                    CASCADE                            │    │
│  │            (Agent IA Multimodal)                     │    │
│  └─────────────────────┬───────────────────────────────┘    │
│                        │                                     │
│  ┌─────────────────────▼───────────────────────────────┐    │
│  │              MCP Client Layer                        │    │
│  │         (Connexion agentMemory)                     │    │
│  └─────────────────────┬───────────────────────────────┘    │
│                        │                                     │
└────────────────────────┼────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              SERVEUR MCP agentMemory                        │
│  ┌──────────────┬──────────────┬──────────────────┐       │
│  │   Outils     │   Storage    │   Dashboard      │       │
│  │   MCP        │   .json      │   localhost:3333│       │
│  └──────────────┴──────────────┴──────────────────┘       │
└─────────────────────────────────────────────────────────────┘
```

---

## Configuration Pas à Pas

### Prérequis

1. **Windsurf installé** : [Télécharger](https://codeium.com/windsurf)
2. **Node.js 18+** : Vérifier avec `node --version`
3. **agentMemory compilé** : `npm run compile`

### Étape 1 : Préparer l'Environnement

```bash
# Se placer dans le dossier agentMemory
cd chemin/vers/agentMemory

# Compiler le projet
npm install
npm run compile

# Vérifier la compilation
ls -la out/mcp-server/
# Doit contenir : server.js, tools.js, storage.js, etc.
```

### Étape 2 : Créer la Configuration MCP

Créez un fichier `.windsurf/mcp_config.json` à la racine de votre projet :

```json
{
  "mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [
        "/chemin/absolu/vers/agentMemory/out/mcp-server/server.js",
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

> **Important** : Utilisez des chemins absolus pour éviter les problèmes de résolution.

### Étape 3 : Redémarrer Windsurf

```
Cmd/Ctrl + R
```

### Étape 4 : Vérifier la Configuration

1. Ouvrir la palette de commandes : `Cmd/Ctrl + Shift + P`
2. Taper `MCP`
3. Chercher "agentMemory" dans la liste

---

## Configuration Alternative : settings.json

### PourTous les Projets

Ajoutez dans `.vscode/settings.json` (à la racine du workspace) :

```json
{
  "codeium.windsurf.mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [
        "chemin/vers/agentMemory/out/mcp-server/server.js",
        "nom-projet",
        "${workspace}"
      ]
    }
  }
}
```

### Variables Disponibles

| Variable | Description | Exemple |
|----------|-------------|---------|
| `${workspace}` | Chemin absolut du workspace | `C:/Projects/mon-projet` |
| `${workspaceBasename}` | Nom du dossier projet | `mon-projet` |
| `${workspaceFolder}` | ID du dossier | `${workspaceFolder:1}` |

---

## Utilisation avec Cascade

### Concept : Cascade avec Mémoire

Cascade est un agent "flow-aware". En combinant avec agentMemory :

1. **Mémoire persistante** : Les décisions traversent les sessions
2. **Recherche contextuelle** : Cascade trouve les patterns existants
3. **Documentation automatique** : Les implémentations sont documentées

### Workflow Recommandé

#### 1. Initialisation du Projet

```markdown
# Prompt Cascade

Initialise ce projet avec agentMemory pour la gestion de mémoire.
Utilise memory_search() avant chaque travail important.
Documente les décisions avec memory_write() après.
```

#### 2. Recherche de Contexte

```markdown
# Prompt Cascade

Avant d'implémenter l'authentification, cherche d'abord 
si des patterns existent avec memory_search({ query: "auth" }).
```

#### 3. Documentation

```markdown
# Prompt Cascade

Après avoir implémenté le système OAuth, appelle 
memory_write() pour documenter :
- key: "oauth-implementation"
- type: "architecture"  
- content: Description détaillée
- tags: ["auth", "oauth", "security"]
```

---

## Configuration Avancée Windsurf

### Mode Debug

Pour activer les logs détaillés :

```json
{
  "codeium.windsurf.mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [
        "--inspect",
        "chemin/vers/agentMemory/out/mcp-server/server.js",
        "projet",
        "${workspace}"
      ]
    }
  }
}
```

### Timeout Personnalisé

```json
{
  "codeium.windsurf.mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [...],
      "timeout": 30000
    }
  }
}
```

### Variables d'Environnement

```json
{
  "codeium.windsurf.mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [...],
      "env": {
        "AGENTMEMORY_CACHE_SIZE": "50000",
        "AGENTMEMORY_CACHE_TTL": "7200",
        "AGENTMEMORY_DASHBOARD_PORT": "3333"
      }
    }
  }
}
```

---

## Dashboard Windsurf

### Accès

Le dashboard reste accessible via :

```bash
# URL directe
http://localhost:3333
```

### Intégration Windsurf

Vous pouvez intégrer le dashboard dans Windsurf via :

1. **Webview** : Créer une extension Windsurf personnalisée
2. **Terminal** : Ouvrir dans le navigateur intégré

---

## Dépannage Windsurf

### Problème : MCP Non Détecté

**Symptôme** : Cascade ne voit pas les outils agentMemory

**Solution** :
1. Vérifier `.windsurf/mcp_config.json`
2. Vérifier les permissions du fichier
3. Redémarrer Windsurf complètement

### Problème : Erreur de Chemin

**Symptôme** : `ENOENT: no such file or directory`

**Solution** :
- Utiliser des chemins absolus
- Vérifier que le chemin vers server.js est correct

### Problème : Port Dashboard Occupé

**Symptôme** : `EADDRINUSE: address already in use 3333`

**Solution** :
```bash
# Trouver le processus
lsof -i :3333

# Tuer le processus
kill <PID>
```

### Problème : Cascade Ignore les Mémoires

**Solution** : Ajouter des instructions explicites dans le prompt système :

```markdown
# Instructions pour Cascade

Ce projet utilise agentMemory pour la gestion de connaissances.
- AVANT tout travail : utilise memory_search() pour trouver le contexte existant
- APRÈS toute implémentation significative : utilise memory_write() pour documenter
- Utilise memory_stats() pour voir l'état de la mémoire
```

---

## Optimisation pour Cascade

### Configuration Optimale

```json
{
  "codeium.windsurf.mcpServers": {
    "agentmemory": {
      "command": "node",
      "args": [
        "chemin/vers/agentMemory/out/mcp-server/server.js",
        "${workspaceBasename}",
        "${workspace}"
      ],
      "env": {
        "AGENTMEMORY_CACHE_SIZE": "50000",
        "AGENTMEMORY_CACHE_TTL": "7200"
      },
      "timeout": 60000
    }
  }
}
```

### Meilleures Pratiques

1. **Chemin absolus** - Toujours utiliser des chemins absolus
2. **Timeout adapté** - 60s pour les opérations complexes
3. **Cache important** - 50K entrées pour projets volumineux
4. **Dashboard actif** - Garder localhost:3333 pour suivi

---

## Comparaison Windsurf vs VS Code

| Feature | Windsurf + Cascade | VS Code + Extension |
|---------|-------------------|---------------------|
| Configuration MCP | Native | Via settings.json |
| Agent IA | Cascade intégré | Externe |
| Flow-aware | ✅ Oui | ⚠️ Limité |
| Dashboard | Ext | In-box |
| Performance | ++ | + |

---

## Pour Aller Plus Loin

- **[INSTALLATION.md](INSTALLATION.md)** - Guide d'installation
- **[IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md)** - Autres IDE
- **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - MCP avancé
