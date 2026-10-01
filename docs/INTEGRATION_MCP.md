# 🔌 Intégration MCP - agentMemory

Guide complet pour intégrer agentMemory avec votre infrastructure MCP existante.

---

## Qu'est-ce que MCP ?

Le **Model Context Protocol (MCP)** est un protocole standardisé qui permet aux agents IA d'interagir avec des outils et services externes de manière cohérente.

agentMemory implémente un serveur MCP complet offrant 7 outils de gestion de mémoire.

---

## Architecture MCP d'agentMemory

### Serveur MCP

```
┌─────────────────────────────────────────────────────────┐
│                    MCP Server agentMemory                │
├─────────────────────────────────────────────────────────┤
│  Transport: stdio / Unix Socket                         │
│  Protocole: JSON-RPC 2.0                               │
│  Port dashboard: localhost:3333                          │
└─────────────────────────────────────────────────────────┘
```

### Protocole de Communication

#### Format des Requêtes

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "memory_write",
    "arguments": {
      "projectId": "mon-projet",
      "key": "nouvelle-fonctionnalite",
      "type": "feature",
      "content": "# Nouvelle Fonctionnalité\n\nDescription...",
      "tags": ["frontend", "react"]
    }
  }
}
```

#### Format des Réponses

```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "{\"success\":true,\"id\":\"uuid-001\"}"
      }
    ]
  }
}
```

---

## Outils MCP Disponibles

### 1. memory_write

Sauvegarde une nouvelle mémoire dans la base de connaissances.

```typescript
{
  name: "memory_write",
  description: "Store new memory in the memory bank",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string", description: "Project identifier" },
      key: { type: "string", description: "Unique memory key" },
      type: { 
        type: "string", 
        enum: ["architecture", "pattern", "feature", "api", "bug", "decision"] 
      },
      content: { type: "string", description: "Memory content (markdown supported)" },
      tags: { type: "array", items: { type: "string" }, description: "Tags" },
      relationships: { type: "object", description: "Dependencies and implementations" }
    },
    required: ["projectId", "key", "type", "content"]
  }
}
```

**Exemple d'utilisation :**

```javascript
// Dans un agent
await memory_write({
  projectId: "mon-projet",
  key: "oauth-implementation",
  type: "architecture",
  content: "# OAuth Implementation\n\nWe use Passport.js with JWT tokens...",
  tags: ["oauth", "authentication", "security"],
  relationships: {
    dependsOn: ["user-model", "jwt-service"],
    implements: []
  }
});
```

---

### 2. memory_read

Lit une mémoire par sa clé exacte.

```typescript
{
  name: "memory_read",
  description: "Read memory by exact key",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string" },
      key: { type: "string" }
    },
    required: ["projectId", "key"]
  }
}
```

---

### 3. memory_search

Recherche des mémoires par mot-clé, tags ou type.

```typescript
{
  name: "memory_search",
  description: "Search memories by keyword, tags, or type",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string" },
      query: { type: "string", description: "Search query" },
      tags: { type: "array", items: { type: "string" } },
      type: { type: "string", enum: ["architecture", "pattern", "feature", "api", "bug", "decision"] },
      limit: { type: "number", default: 10 }
    },
    required: ["projectId"]
  }
}
```

---

### 4. memory_list

Liste toutes les mémoires d'un type spécifique.

```typescript
{
  name: "memory_list",
  description: "List all memories of a specific type",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string" },
      type: { type: "string", enum: ["architecture", "pattern", "feature", "api", "bug", "decision"] }
    },
    required: ["projectId"]
  }
}
```

---

### 5. memory_update

Met à jour une mémoire existante.

```typescript
{
  name: "memory_update",
  description: "Update existing memory",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string" },
      key: { type: "string" },
      content: { type: "string" },
      tags: { type: "array", items: { type: "string" } },
      relationships: { type: "object" }
    },
    required: ["projectId", "key"]
  }
}
```

---

### 6. project_init

Initialise le stockage pour un projet.

```typescript
{
  name: "project_init",
  description: "Initialize project storage",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string" }
    },
    required: ["projectId"]
  }
}
```

---

### 7. memory_stats

Retourne les statistiques d'utilisation.

```typescript
{
  name: "memory_stats",
  description: "Get storage and cache statistics",
  inputSchema: {
    type: "object",
    properties: {
      projectId: { type: "string" }
    },
    required: ["projectId"]
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
| `AGENTMEMORY_CACHE_TTL` | `3600` | TTL cache (secondes) |
| `AGENTMEMORY_DASHBOARD_PORT` | `3333` | Port dashboard |

### Configuration de Production

```json
{
  "agentMemory": {
    "enabled": true,
    "storageLocation": "./mcp-data",
    "cacheSize": 50000,
    "cacheTTL": 7200
  }
}
```

---

## Intégration avec Votre Infrastructure

### Configuration Multi-Projet

Pour gérer plusieurs projets avec un seul serveur :

```javascript
// Démarrer avec projet par défaut
npm run start-server default-project /path/to/workspace

// Ou basculer entre projets
// - Arrêter le serveur actuel
// - Relancer avec nouveau projectId
```

### Socket Unix Personnalisé

Le serveur crée automatiquement un socket Unix :
```
/tmp/mcp-memory-{projectId}.sock
```

Pour utiliser un chemin personnalisé :

```javascript
// Modifier dans server.ts
const socketPath = '/chemin/custom/mon-socket.sock';
```

### Connexion via HTTP

Pour les environnements sans stdio :

```bash
# Le dashboard inclut une API REST
curl http://localhost:3333/api/memories
curl http://localhost:3333/api/stats
```

---

## Tests d'Intégration

### Tester la Connexion MCP

```bash
# Envoyer une requête JSON-RPC
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | node out/mcp-server/server.js test-project /tmp
```

### Vérifier les Outils Disponibles

```javascript
// Dans une console
const response = await fetch('http://localhost:3333/api/tools');
const tools = await response.json();
console.log(tools);  // Liste des 7 outils
```

---

## Dépannage

### Problème : Connexion Refusée

1. Vérifier que le serveur est en cours d'exécution :
   ```bash
   ps aux | grep agentMemory
   ```

2. Vérifier le socket :
   ```bash
   ls -la /tmp/mcp-memory-*.sock
   ```

3. Redémarrer le serveur :
   ```bash
   npm run start-server <project> <workspace>
   ```

### Problème : Outils Non Disponibles

1. Vérifier l'initialisation :
   ```json
   {
     "method": "initialize",
     "params": {
       "protocolVersion": "2024-11-05"
     }
   }
   ```

2. Vérifier les tools/list :
   ```json
   {
     "method": "tools/list"
   }
   ```

### Problème : Erreurs de Timeout

Augmenter le timeout dans la configuration client :

```json
{
  "mcpServers": {
    "agentMemory": {
      "timeout": 30000
    }
  }
}
```

---

## Patterns d'Utilisation

### Pattern 1 : Context-Aware Development

```javascript
// Au début de chaque tâche
const existingPatterns = await memory_search({
  projectId: projectId,
  query: taskDescription,
  limit: 3
});

if (existingPatterns.length > 0) {
  console.log("Pattern existant trouvé :", existingPatterns[0].key);
  // Utiliser le pattern existant
} else {
  // Créer nouveau pattern
}
```

### Pattern 2 : Auto-Documentation

```javascript
// Après chaque implémentation significative
await memory_write({
  projectId: projectId,
  key: `feature-${featureName}`,
  type: "feature",
  content: `# ${featureName}\n\n${implementationDetails}`,
  tags: extractTagsFromCode(code),
  metadata: {
    createdBy: agentName,
    filesModified: files
  }
});
```

### Pattern 3 : Cross-Project Knowledge

```javascript
// Rechercher dans tous les projets
const allProjects = await Promise.all([
  memory_search({ projectId: "projet-a", query: "auth" }),
  memory_search({ projectId: "projet-b", query: "auth" }),
  memory_search({ projectId: "projet-c", query: "auth" })
]);

const combinedResults = allProjects.flat();
```

---

## Pour Aller Plus Loin

- **[INSTALLATION.md](INSTALLATION.md)** - Guide d'installation
- **[FONCTIONNEMENT.md](FONCTIONNEMENT.md)** - Architecture technique
- **[FEATURES.md](FEATURES.md)** - Liste complète des fonctionnalités
- **[IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md)** - Configuration par IDE
