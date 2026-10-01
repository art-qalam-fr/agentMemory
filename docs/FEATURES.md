# ✨ Fonctionnalités - agentMemory

Guide complet des fonctionnalités actuelles et futures d'agentMemory.

---

## Fonctionnalités Actuelles

### 🔄 Synchronisation Bidirectionnelle

#### Markdown → MCP
- Parse les fichiers memory bank existants
- Importe les sections comme mémoires recherchables
- Préserve la documentation lisible

#### MCP → Markdown
- Génère automatiquement du markdown depuis MCP
- Ajoute aux fichiers appropriés :
  - `architecture.md` ← Décisions d'architecture
  - `systemPatterns.md` ← Patterns de code
  - `techContext.md` ← Choix tech
  - `productContext.md` ← Features
  - `progress.md` ← Suivi de statut

#### Support Multi-Agent

| Agent | Emplacement Memory Bank | Status Sync |
|-------|----------------------|-------------|
| **KiloCode** | `.kilocode/rules/memory-bank/` | ✅ Sync complet |
| **Cline** | `.clinerules/memory-bank/` | ✅ Sync complet |
| **RooCode** | `.roo/memory-bank/` | ✅ Sync complet |

---

### 🔍 Recherche Puissante

#### Types de Recherche

```typescript
// Recherche par requête textuelle
memory_search({ 
  query: "authentication", 
  limit: 5
})

// Recherche par tags
memory_search({ 
  tags: ["security", "oauth"] 
})

// Recherche par type
memory_search({ 
  type: "architecture" 
})

// Recherche combinée
memory_search({
  query: "api",
  tags: ["backend"],
  type: "pattern",
  limit: 10
})
```

#### Moteurs de Recherche

| Méthode | Performance | Use Case |
|---------|-------------|----------|
| **Tags indexés** | ~10μs | Recherche rapide par catégorie |
| **Contenu textuel** | ~100μs | Recherche par mot-clé |
| **Métadonnées** | ~50μs | Filtres (type, date, auteur) |

---

### 📊 Dashboard Visuel

#### Fonctionnalités Dashboard

- **Vue d'ensemble** : Total mémoires, agents actifs, activité récente
- **Graphiques** : Types de mémoires, activité agent, tendances temporelles
- **Recherche** : Requêtes avec filtres
- **Export** : Génération de résumés markdown
- **Status Sync** : Voir quels fichiers sont synchronisés

#### Accès Dashboard

```
Cmd/Ctrl+Shift+P → "agentMemory: Open Memory Dashboard"
```

#### Mode Serveur Externe

```bash
# Démarrer le serveur dashboard
npm run start-dashboard

# Accéder via navigateur
http://localhost:3333
```

---

### 🤖 Support Multi-Agent

#### Compatibilité Extensions

| Extension | ID VS Code | Version Minimale |
|-----------|------------|-----------------|
| KiloCode | `kilocode.kilo-code` | 1.0.0+ |
| Cline | `saoudrizwan.claude-dev` | 3.0.0+ |
| RooCode | `rooveterinaryinc.roo-cline` | 2.0.0+ |

#### Mémoires Synchronisées

- `projectBrief.md` / `brief.md`
- `architecture.md` / `systemPatterns.md`
- `productContext.md` / `product.md`
- `techContext.md` / `tech.md`
- `activeContext.md` / `context.md`
- `progress.md`
- `decisionLog.md` (RooCode)

---

### 🛠️ Outils MCP

7 outils disponibles :

| Outil | Description | Exemple |
|-------|-------------|---------|
| `memory_write` | Sauvegarder nouvelle mémoire | Documenter décision architecture |
| `memory_read` | Lire mémoire spécifique | Récupérer implémentation OAuth |
| `memory_search` | Rechercher par contenu/tags | Trouver tous patterns auth |
| `memory_list` | Lister par type | Afficher toutes décisions |
| `memory_update` | Modifier existante | Ajouter à pattern existant |
| `project_init` | Initialiser stockage | Configurer nouveau projet |
| `memory_stats` | Voir analytiques | Statistiques d'utilisation |

---

### 📈 Analytiques et Statistiques

#### Métriques Disponibles

```json
{
  "totalMemories": 42,
  "byType": {
    "architecture": 12,
    "pattern": 15,
    "feature": 8,
    "api": 4,
    "bug": 2,
    "decision": 1
  },
  "byAgent": {
    "kilocode": 20,
    "cline": 15,
    "roocode": 7
  },
  "cache": {
    "size": 842,
    "hitRate": 0.87
  },
  "sync": {
    "enabled": true,
    "lastSync": "2024-01-15T10:30:00Z"
  }
}
```

---

### 🔒 Sécurité et Vie Privée

- ✅ **100% Local** - Pas de stockage cloud
- ✅ **Offline-First** - Fonctionne sans internet
- ✅ **Git-Friendly** - Commit `.agentMemory/` au versionnement
- ✅ **Open Source** - Auditez le code vous-même

---

## Fonctionnalités Futures

### Phase 2 : Recherche Avancée

| Feature | Status | Description |
|---------|--------|-------------|
| **Recherche Vectorielle** | 🚧 Planifié | Recherche sémantique avec embeddings |
| **Recherche Hybride** | 🚧 Planifié | Combinaison vectoriel + keyword |
| **Auto-tagging** | 📋 Idée | Tagging automatique par IA |

### Phase 3 : Collaboration

| Feature | Status | Description |
|---------|--------|-------------|
| **Sync Cloud** | 📋 Idée | Backup optionnel cloud |
| **Team Memories** | 📋 Idée | Partage cross-équipe |
| **Conflict Resolution** | 📋 Idée | Gestion édition concurrente |

### Phase 4 : Extensions

| Feature | Status | Description |
|---------|--------|-------------|
| **Intégration GitHub** | 📋 Idée | Sync avec GitHub Copilot |
| **Intégration GitLab** | 📋 Idée | Support Duo |
| **Plugin System** | 📋 Idée | Extensions tierces |

---

## Comparatif Features

| Feature | agentMemory | Memory Banks Natif | MCP Standalone |
|---------|-------------|-------------------|----------------|
| **Fichiers Markdown** | ✅ Sync | ✅ Manuel | ❌ Non |
| **Recherche** | ✅ Indexée rapide | ❌ Non | ✅ Oui |
| **Analytiques** | ✅ Dashboard | ❌ Non | ❌ Non |
| **Automation** | ✅ Auto-sync | ❌ Manuel | ⚠️ Partiel |
| **Multi-Agent** | ✅ Tous 3 | ✅ Par agent | ✅ Tous |
| **Git-Friendly** | ✅ Oui | ✅ Oui | ⚠️ Dépend |
| **Cross-Project** | ✅ Oui | ❌ Non | ❌ Non |

---

## Cas d'Usage

### Exemple 1 : Documentation Automatique

**Jour 1** : L'utilisateur demande à KiloCode de créer l'authentification OAuth

1. KiloCode implémente OAuth
2. Appelle : `memory_write({ key: "oauth-impl", type: "architecture", ... })`
3. **agentMemory sauvegarde dans :**
   - `.agentMemory/uuid-001.json` (base de données)
   - `.kilocode/rules/memory-bank/architecture.md` (markdown)

**Jour 3** : Un autre agent (Cline) étend avec Google OAuth

1. Cline lit `.clinerules/memory-bank/architecture.md`
2. Voit la documentation OAuth (sync depuis notre base)
3. Appelle : `memory_search({ query: "oauth" })`
4. Obtient les résultats instantanément
5. Implémente Google provider de manière cohérente

### Exemple 2 : Onboarding Nouveau Développeur

**Nouveau développeur** demande à RooCode : "Comment fonctionne l'authentification ?"

1. RooCode lit `.roo/memory-bank/systemPatterns.md`
2. Voit les patterns auth complets (auto-sync)
3. Appelle : `memory_read({ key: "oauth-impl" })`
4. Obtient le doc complet architecture OAuth
5. ✅ **Compréhension instantanée** - Courbe d'apprentissage zéro

---

## Utilisation Avancée

### Recherche Croisée Projets

```typescript
// Rechercher dans tous les projets
memory_search({
  query: "api-design",
  projectId: "*"  // Wildcard pour tous projets
})
```

### Relations entre Mémoires

```typescript
memory_write({
  key: "feature-x",
  content: "...",
  relationships: {
    dependsOn: ["auth-system", "database-schema"],
    implements: ["api-v1"]
  }
})
```

### Webhooks de Synchronisation

```typescript
// Écouter les événements mémoire
memoryAPI.subscribe((event) => {
  console.log(`[${event.action}] ${event.key} par ${event.agent}`);
  
  if (event.action === 'write') {
    // Trigger notification externe
    sendSlackNotification(event);
  }
});
```

---

## Configuration Avancée

### Personnalisation Types de Mémoire

```json
{
  "agentMemory.types": [
    "architecture",
    "pattern", 
    "feature",
    "api",
    "bug",
    "decision",
    "customType"
  ]
}
```

### Personnalisation Tags

```json
{
  "agentMemory.autoTags": {
    "enabled": true,
    "keywords": ["auth", "api", "database", "security"]
  }
}
```

---

## Pour Aller Plus Loin

- **[INSTALLATION.md](INSTALLATION.md)** - Guide d'installation
- **[FONCTIONNEMENT.md](FONCTIONNEMENT.md)** - Architecture technique
- **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - Intégration MCP
- **[IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md)** - Configuration IDE
