# ⚙️ Fonctionnement Technique - agentMemory

Ce document détaille l'architecture technique, les flux de données et les mécanismes internes d'agentMemory.

---

## Architecture Système

### Vue d'Ensemble

```
┌──────────────────────────────────────────────────────────────────────┐
│                    COUCHE 1 : Memory Banks (Passif)                   │
├──────────────────────────────────────────────────────────────────────┤
│  .kilocode/rules/memory-bank/*.md                                   │
│  .clinerules/memory-bank/*.md                                        │
│  .roo/memory-bank/*.md                                               │
│                                                                       │
│  Rôle: Contexte au démarrage de session (lecture automatique)        │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                ▼ Synchronisation Bidirectionnelle
┌───────────────────────────────┬──────────────────────────────────────┐
│                    COUCHE 2 : Stockage Structuré                     │
├──────────────────────────────────────────────────────────────────────┤
│  .agentMemory/*.json                                                  │
│  ├── MCP Server avec 7 outils                                        │
│  └── LRU Cache (10K entrées, 1hr TTL)                               │
│                                                                       │
│  Rôle: Requêtes rapides pendant la session (programmatique)          │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
                                ▼ Données pour
┌───────────────────────────────┬──────────────────────────────────────┐
│                    COUCHE 3 : Dashboard (Analytique)                 │
├──────────────────────────────────────────────────────────────────────┤
│  ├── Webview Panel dans VS Code                                      │
│  ├── Graphiques temps réel                                            │
│  └── Insights multi-projets                                           │
│                                                                       │
│  Rôle: Supervision humaine et analytiques                            │
└──────────────────────────────────────────────────────────────────────┘
```

---

## Flux de Données

### 1. Flux d'Import (Markdown → MCP)

```
┌─────────────────┐
│ Fichiers Memory │
│    Bank .md     │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│ MemoryBankSync.importFromAgent()                │
│ - Parse le markdown en sections                 │
│ - Extrait les tags et métadonnées              │
│ - Crée des objets Memory                       │
└────────┬────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│ StorageManager.write()                          │
│ - Sauvegarde dans .agentMemory/*.json           │
│ - Met à jour le cache LRU                       │
└────────┬────────────────────────────────────────┘
         │
         ▼
    ┌────────────┐
    │  Mémoire   │
    │  Indexable │
    └────────────┘
```

**Exemple de parsing Markdown :**

```markdown
# architecture.md (KiloCode)

## Auth System

We use JWT tokens with refresh token rotation...

## Database Schema

PostgreSQL with Prisma ORM...
```

Devient :
```json
{
  "id": "uuid-001",
  "key": "auth-system",
  "type": "architecture",
  "content": "# Auth System\n\nWe use JWT tokens...",
  "tags": ["architecture", "kilocode", "auth"],
  "sourceFile": "architecture.md"
}
```

### 2. Flux d'Export (MCP → Markdown)

```
┌─────────────────────────────────────────────────┐
│ Agent appelle memory_write()                    │
└────────┬────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│ MCPTools.memory_write()                         │
│ - Crée l'objet Memory                          │
│ - Sauvegarde dans Storage                      │
└────────┬────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│ MemoryBankSync.exportToAgents()                 │
│ - Détermine le fichier cible par type          │
│ - Formate en markdown                           │
│ - Ajoute au fichier approprié                   │
└────────┬────────────────────────────────────────┘
         │
         ▼
    ┌────────────────────────────────────────────┐
    │  .kilocode/rules/memory-bank/architecture.md
    │  .clinerules/memory-bank/systemPatterns.md │
    │  .roo/memory-bank/systemPatterns.md         │
    └────────────────────────────────────────────┘
```

### 3. Flux de Recherche (Requête Agent)

```
┌─────────────────────────────────────────────────┐
│ Agent besoin d'information                      │
│ Appelle: memory_search({ query: "auth" })      │
└────────┬────────────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────────────┐
│ Vérification Cache LRU                          │
│ - Clé: "projectId:auth"                        │
└────────┬────────────────────────────────────────┘
         │
    ┌────┴────┐
    │  CACHE  │
    │  HIT?   │
    └────┬────┘
    OUI  │  NON
    ┌────┴─────────────────┐
    │                      ▼
    │              ┌─────────────────┐
    │              │ StorageManager  │
    │              │ .search()       │
    │              │ - Tags indexés  │
    │              │ - Scan contenu   │
    │              └────────┬────────┘
    │                      │
    └──────────────────┬───┘
                      ▼
              ┌──────────────┐
              │ Résultats     │
              │ Structurés    │
              └──────────────┘
                      │
                      ▼
              ┌──────────────┐
              │ L'agent       │
              │ utilise       │
              └──────────────┘
```

---

## Composants Techniques

### 1. MCP Server (`src/mcp-server/server.ts`)

**Responsabilités :**
- Gère les requêtes JSON-RPC via stdio
- Route les appels outils vers MCPTools
- Gère l'initialisation du protocole

**Protocole MCP :**

```json
// Request
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "memory_search",
    "arguments": {
      "projectId": "mon-projet",
      "query": "auth"
    }
  }
}

// Response
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {
    "content": [
      {
        "type": "text",
        "text": "[{\"id\":\"...\",\"key\":\"auth-system\",...}]"
      }
    ]
  }
}
```

### 2. Outils MCP (`src/mcp-server/tools.ts`)

7 outils disponibles :

| Outil | Latence Cible | Description |
|-------|---------------|-------------|
| `memory_write` | ~300μs | Sauvegarde nouvelle mémoire |
| `memory_read` | ~2μs | Lecture par clé exacte |
| `memory_search` | ~100μs | Recherche par mot-clé/tags |
| `memory_list` | ~50μs | Liste par type |
| `memory_update` | ~200μs | Modification existante |
| `project_init` | ~10μs | Initialisation projet |
| `memory_stats` | ~20μs | Analytiques utilisation |

### 3. Gestionnaire de Stockage (`src/mcp-server/storage.ts`)

**Modèle de données :**

```typescript
interface Memory {
  id: string;              // UUID unique
  projectId: string;       // ID projet
  key: string;             // Clé unique dans le projet
  type: 'architecture' | 'pattern' | 'feature' | 'api' | 'bug' | 'decision';
  content: string;         // Contenu markdown
  tags: string[];          // Tags pour catégorisation
  relationships: {
    dependsOn: string[];   // Dépendances
    implements: string[];  // Implémentations
  };
  metadata: {
    accessCount: number;   // Nombre d'accès
    createdBy: string;     // Source (kilocode, cline, roocode)
    sourceFile?: string;   // Fichier source markdown
  };
  createdAt: number;       // Timestamp création
  updatedAt: number;      // Timestamp mise à jour
}
```

**Organisation des fichiers :**

```
.agentMemory/
├── uuid-001.json    # Memory: OAuth architecture
├── uuid-002.json    # Memory: API patterns
├── uuid-003.json    # Memory: Bug fix JWT
└── stats.json       # Statistiques globales
```

### 4. Cache LRU (`src/mcp-server/cache.ts`)

**Configuration :**
- Taille maximale : 10,000 entrées
- TTL : 3,600 secondes (1 heure)
- Stratégie : LRU (Least Recently Used)

**Optimisations :**
- Les mémoires fréquentes restent en RAM
- Réduction des E/S disque

### 5. Synchronisation (`src/mcp-server/memory-bank-sync.ts`)

**Mapping des fichiers par agent :**

| Agent | Fichier Markdown | Type Memory |
|-------|-----------------|-------------|
| **KiloCode** | `brief.md` | architecture |
| | `product.md` | feature |
| | `context.md` | bug |
| | `architecture.md` | architecture |
| | `tech.md` | decision |
| **Cline** | `projectBrief.md` | architecture |
| | `productContext.md` | feature |
| | `activeContext.md` | pattern |
| | `systemPatterns.md` | pattern |
| | `techContext.md` | decision |
| | `progress.md` | feature |
| **RooCode** | `projectBrief.md` | architecture |
| | `productContext.md` | feature |
| | `activeContext.md` | pattern |
| | `systemPatterns.md` | pattern |
| | `techContext.md` | decision |
| | `progress.md` | feature |
| | `decisionLog.md` | decision |

---

## Modèle de Performance

### Caractéristiques Opérationnelles

| Opération | Latence | Stratégie |
|-----------|---------|-----------|
| **Memory Read** | ~2μs | Cache LRU hit |
| **Memory Write** | ~300μs | write_to_file async |
| **Search Query** | ~100μs | Tags indexés + scan contenu |
| **Sync Markdown** | ~1ms | E/S fichier groupé |
| **Dashboard Load** | ~5ms | Statistiques en cache |

### Stratégies d'Optimisation

1. **Cache LRU** - 10K entrées, 1hr TTL
2. **write_to_file Asynchrone** - E/S disque non-bloquante
3. **Sync Différée** - Markdown sync après MCP write
4. **Recherche Indexée** - Tags et types indexés

---

## Gestion des Erreurs

### Dégradation Gracieuse

| Scénario | Comportement |
|----------|--------------|
| Crash MCP | Extension continue, log erreur |
| Échec Sync | Markdown non mis à jour, données MCP sauvegardées |
| Erreur Parse | Ignore markdown malformé, continue |
| Erreur Socket | Retry connexion, fallback stdio |

### Journalisation

Tous les composants loguent vers le canal de sortie "agentMemory" :

```
[Extension] Initializing...
[MCP Server] Starting stdio transport...
[Socket Bridge] Listening at /tmp/mcp-memory-demo.sock
[DashboardServer] Started at http://localhost:3333
[MemoryBankSync] Imported 12 memories from kilocode
```

---

## Modèle de Sécurité

### Isolation par Namespace

Chaque projet a un stockage isolé :
```
/workspace-a/.agentMemory/  ← Mémoires projet A
/workspace-b/.agentMemory/  ← Mémoires projet B
```

Pas de contamination croisée sauf requête explicite.

### Contrôles d'Accès

1. **100% Local** - Pas d'accès réseau
2. **Système de fichiers** - Permissions VS Code
3. **Unix Socket** - Loopback local uniquement
4. **Pas d'authentification** - Environnement de confiance

---

## Diagramme de Séquence

### Session Start

```
┌─────────┐    ┌────────────┐    ┌──────────────┐    ┌────────────┐
│ Utilis. │    │ Extension  │    │ MCP Server   │    │  Fichiers │
│ Lance   │    │ VS Code    │    │              │    │  Markdown │
│ Agent   │    │            │    │              │    │           │
└────┬────┘    └─────┬──────┘    └──────┬───────┘    └─────┬──────┘
     │              │                   │                  │
     │─────────────▶│ Activé            │                  │
     │              │                   │                  │
     │              │──▶ Detect agents  │                  │
     │              │◀─── KiloCode,     │                  │
     │              │     Cline,        │                  │
     │              │     RooCode       │                  │
     │              │                   │                  │
     │              │──▶ Import from    │                  │
     │              │    .kilocode/     │                  │
     │              │◀─── Memories     │                  │
     │              │                   │                  │
     │              │──▶ MCP init       │                  │
     │              │◀─── Ready         │                  │
     │              │                   │                  │
     │◀─────────────│ Session ready    │                  │
     │              │                   │                  │
```

### Au Cours de la Session

```
┌─────────┐    ┌────────────┐    ┌──────────────┐    ┌────────────┐
│ Agent   │    │ Extension  │    │ MCP Server   │    │  Storage  │
│ (KC/    │    │ VS Code    │    │              │    │           │
│ C/R)    │    │            │    │              │    │           │
└────┬────┘    └─────┬──────┘    └──────┬───────┘    └─────┬──────┘
     │              │                   │                  │
     │ read context │                   │                  │
     │─────────────▶│                   │                  │
     │              │─▶ memory_read()  │                  │
     │              │─────────────────▶│                  │
     │              │◀─────────────────│                  │
     │◀─────────────│ Content found    │                  │
     │              │                   │                  │
     │ work...      │                   │                  │
     │              │                   │                  │
     │ write memory │                   │                  │
     │─────────────▶│                   │                  │
     │              │─▶ memory_write() │                  │
     │              │─────────────────▶│                  │
     │              │◀─────────────────│                  │
     │              │                   │─▶ sync to .md  │
     │              │                   │────────────────▶│
     │◀─────────────│ Success           │                  │
     │              │                   │                  │
```

---

## Points d'Extension Futurs

1. **File Watcher** - Import automatique lors de changements markdown
2. **Résolution de Conflits** - Gestion des éditions concurrentes
3. **Recherche Vectorielle** - Recherche sémantique avec embeddings
4. **Sync Distant** - Backup cloud optionnel
5. **Collaboration d'Équipe** - Partage de mémoires
6. **Outil de Migration** - Import d'autres systèmes de mémoire

---

## Pour Aller Plus Loin

- **[FEATURES.md](FEATURES.md)** - Liste complète des fonctionnalités
- **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - Guide d'intégration MCP
- **[IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md)** - Configuration par IDE
