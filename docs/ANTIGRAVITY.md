# 🚀 Intégration Antigravity - agentMemory

Guide pour intégrer agentMemory avec le système Antigravity.

---

## Qu'est-ce qu'Antigravity ?

Antigravity est un système multi-agents qui utilise des **skills** pour étendre les capacités des agents IA. agentMemory est compatible en tant que **skill** officiel.

---

## Architecture Antigravity + agentMemory

```
┌─────────────────────────────────────────────────────────────┐
│                    ANTI gravity SYSTEM                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐       │
│  │  Architect  │  │   Coder     │  │   Memory    │       │
│  │   Agent    │  │    Agent    │  │    Agent    │       │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘       │
│         │                 │                 │                │
│         └─────────────────┼─────────────────┘                │
│                           │                                  │
│                    ┌──────▼──────┐                          │
│                    │   Skills    │                          │
│                    │  (agentMem) │                          │
│                    └─────────────┘                          │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              SERVEUR MCP agentMemory                        │
│  ┌──────────────┬──────────────┬──────────────────┐          │
│  │   memory_   │    storage   │      sync       │          │
│  │   write()   │     .json    │   memory-bank   │          │
│  └──────────────┴──────────────┴──────────────────┘          │
└─────────────────────────────────────────────────────────────┘
```

---

## Installation du Skill agentMemory

### Méthode 1 : Via Fichier SKILL.md

Copiez le fichier `SKILL.md` à la racine de votre projet Antigravity :

```bash
# Dans votre workspace Antigravity
cp chemin/vers/agentMemory/SKILL.md ./skills/agentMemory.md
```

### Méthode 2 : Configuration YAML

Ajoutez dans la configuration Antigravity :

```yaml
skills:
  - name: agentMemory
    source: ./skills/agentMemory.md
    enabled: true
```

---

## Utilisation avec Antigravity

### Activation du Skill

Le skill est automatiquement activé quand :

1. Le fichier `SKILL.md` existe dans le projet
2. Le serveur MCP agentMemory est en cours d'exécution
3. Les variables d'environnement sont configurées

### Workflow Antigravity avec Mémoire

#### 1. Avant une Tâche

```
Architect Agent analyze le projet
    │
    ├─▶ memory_search({ query: "architecture" })
    │
    └─▶ Utilise le contexte trouvé
```

#### 2. Pendant la Tâche

```
Coder Agent implémente
    │
    ├─▶ Besoin de contexte → memory_read({ key: "..." })
    │
    └─▶ Décision importante → memory_write({ ... })
```

#### 3. Après la Tâche

```
Memory Agent synchronise
    │
    ├─▶ sync to markdown files
    │
    └─▶ Update .agent/ workflows
```

---

## Configuration pour Antigravity

### Structure de Projet Recommandée

```
mon-projet/
├── .agentMemory/              # Données agentMemory
│   ├── *.json
│   └── stats.json
│
├── .agent/                    # Configuration Antigravity
│   ├── agents/
│   │   ├── architect.md
│   │   ├── coder.md
│   │   └── memory.md
│   │
│   ├── workflows/
│   │   └── update-memory.md   # Workflow auto-généré
│   │
│   └── memory-policy.md
│
├── .kilocode/rules/memory-bank/   # Sync KiloCode
├── .clinerules/memory-bank/       # Sync Cline
└── .roo/memory-bank/              # Sync RooCode
```

### Configuration Automatique

agentMemory crée automatiquement le fichier `.agent/workflows/update-memory.md` :

```markdown
---
description: How to update the project memory bank with new findings
---

# Update Memory Bank

Follow this workflow to document important architectural decisions, patterns, or features.

1. **Search First**: Check if a similar memory already exists.
   \`\`\`bash
   memory_search({ "query": "<topic>" })
   \`\`\`

2. **Decide Action**:
   - If it's **new**, use \`memory_write\`.
   - If it **exists** but needs updates, use \`memory_update\`.

3. **write_to_file Memory**:
   Use the \`memory_write\` tool.
   - \`type\`: Choose one of \`architecture\`, \`pattern\`, \`decision\`, \`feature\`.
   - \`key\`: A unique identifier (e.g., \`auth-flow-v2\`).

4. **Verify**: Run \`memory_stats\` to confirm.
```

---

## Intégration Avancée

### Création d'un Agent Mémoire Dédié

Dans Antigravity, vous pouvez créer un agent spécialisé mémoire :

```yaml
# .agent/agents/memory.md
name: Memory Agent
description: Specialist in knowledge management
capabilities:
  - memory_write
  - memory_search
  - memory_read
  - memory_stats
tools:
  - agentMemory MCP
```

### Workflow de Synchronisation

```yaml
# .agent/workflows/sync-memory.yaml
name: Memory Sync
trigger: on_task_complete
steps:
  - name: Check for new decisions
    action: memory_search
    params:
      query: "decision"
      type: "decision"
      
  - name: Update documentation
    if: "${results.length > 0}"
    action: memory_write
    params:
      key: "project-decisions"
      type: "decision"
      content: "${format_decisions(results)}"
```

---

## Meilleures Pratiques avec Antigravity

### 1. Policy de Rétention

Définir une politique de rétention dans `.agent/memory-policy.md` :

```markdown
# Memory Policy

## Règles de Rétention

- **Architecture decisions** : Garder indéfiniment
- **Patterns** : Garder 1 an
- **Features** : Garder 6 mois
- **Bugs** : Garder 3 mois après résolution

## Nettoyage

- Auto-cleanup : Mensuel
- Archive : Trimestriel
```

### 2. Métadonnées pour Agents

Ajouter des métadonnées structurées :

```typescript
await memory_write({
  key: "feature-x",
  type: "feature",
  content: "...",
  metadata: {
    createdBy: "architect-agent",
    taskId: "TASK-123",
    phase: "implementation",
    complexity: "high"
  }
});
```

### 3. Relations Entre Mémoires

Exploiter les relations :

```typescript
await memory_write({
  key: "microservice-auth",
  type: "architecture",
  content: "...",
  relationships: {
    dependsOn: ["database-schema", "api-gateway"],
    implements: ["oauth-spec", "jwt-standard"]
  }
});
```

---

## Dépannage Antigravity

### Problème : Skill Non Chargé

**Vérifications** :
1. Le fichier `SKILL.md` existe dans le bon dossier
2. Le format YAML est valide
3. Le serveur MCP est démarré

### Problème : Erreurs de Synchronisation

**Solution** :
```bash
# Vérifier les permissions
ls -la .agent/workflows/

# Re-générer le workflow
npm run start-server <project> <workspace> --force-init
```

### Problème : Conflits avec Autres Skills

**Solution** : Prioriser les skills dans la configuration :

```yaml
skills:
  - name: agentMemory
    priority: 100  # Haute priorité
  - name: other-skill
    priority: 50
```

---

## Exemple de Projet Antigravity Complet

```
mon-projet/
│
├─ .agentMemory/
│   ├─ uuid-001.json    # Auth architecture
│   ├─ uuid-002.json    # API patterns
│   └─ stats.json
│
├─ .agent/
│   ├─ agents/
│   │   ├─ architect.md
│   │   ├─ coder.md
│   │   └─ memory.md    # Agent spécialisé mémoire
│   │
│   ├─ workflows/
│   │   ├─ update-memory.md    # Auto-généré
│   │   └─ decision-log.md
│   │
│   └─ memory-policy.md
│
├─ .kilocode/rules/memory-bank/
├─ .clinerules/memory-bank/
└─ .roo/memory-bank/
```

---

## Pour Aller Plus Loin

- **[INSTALLATION.md](INSTALLATION.md)** - Guide d'installation
- **[FEATURES.md](FEATURES.md)** - Fonctionnalités complètes
- **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - Configuration MCP
