# 📚 Documentation agentMemory

Ce dossier contient la documentation complète du projet **agentMemory** - un système de mémoire hybride pour les agents IA de codage.

## Structure de la Documentation

| Fichier | Description |
|---------|-------------|
| [INSTALLATION.md](INSTALLATION.md) | Guide d'installation complet |
| [FONCTIONNEMENT.md](FONCTIONNEMENT.md) | Détails techniques et flux de données |
| [FEATURES.md](FEATURES.md) | Fonctionnalités actuelles et futures |
| [INTEGRATION_MCP.md](INTEGRATION_MCP.md) | Guide d'intégration MCP |
| [IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md) | Compatibilité avec les IDE (Devin, Codeium, etc.) |
| [DEVIN_CASCADE.md](DEVIN_CASCADE.md) | Configuration Devin/Cascade |
| [ANTIGRAVITY.md](ANTIGRAVITY.md) | Intégration avec le système Antigravity |

## Accès Rapide

### Pour Commencer
→ **[INSTALLATION.md](INSTALLATION.md)** - Installation depuis zéro

### Pour Comprendre le Fonctionnement
→ **[FONCTIONNEMENT.md](FONCTIONNEMENT.md)** - Architecture et flux de données

### Pour les Fonctionnalités
→ **[FEATURES.md](FEATURES.md)** - Liste complète des features

### Pour l'Intégration MCP
→ **[INTEGRATION_MCP.md](INTEGRATION_MCP.md)** - Configuration MCP serveur

### Pour Devin/Codeium/Cascade
→ **[IDE_COMPATIBILITE.md](IDE_COMPATIBILITE.md)** et **[DEVIN_CASCADE.md](DEVIN_CASCADE.md)**

---

## Qu'est-ce qu'agentMemory ?

**agentMemory** est un système de mémoire hybride qui améliore les memory banks intégrés de KiloCode, Cline et RooCode avec des capacités puissantes de recherche, d'analyse et d'automatisation.

### Problème Résolu

Les memory banks natifs sont :
- ❌ **Manuels** - Les agents doivent réécrire les fichiers manuellement
- ❌ **Sans recherche** - Pas de moyen de trouver une information spécifique
- ❌ **Sans analytics** - Impossible de suivre l'évolution des connaissances
- ❌ **Isolés** - Mémoires verrouillées sur un seul projet

### Solution agentMemory

```
.agentMemory/                    ← Base de données structurée
  ├── Synchronisation bidirectionnelle
  ├── Recherche puissante
  ├── Dashboard visuel
  └── Outils MCP
```

---

## Compatibilité IDE

| IDE | Extension ID | Support |
|-----|--------------|---------|
| **KiloCode** | `kilocode.kilo-code` | ✅ Support complet |
| **Cline** | `saoudrizwan.claude-dev` | ✅ Support complet |
| **RooCode** | `rooveterinaryinc.roo-cline` | ✅ Support complet |
| **Devin** (Codeium) | `codeium.devin` | ✅ Via MCP |
| **Trae** | N/A | ✅ Via configuration MCP |
| **Cursor** | N/A | ⚠️ En évaluation |

---

## Démarrage Rapide

```bash
# 1. Installer les dépendances
npm install

# 2. Compiler le projet
npm run compile

# 3. Lancer le serveur MCP
npm run start-server <project_id> <chemin_workspace>

# 4. Utiliser les outils MCP
# - memory_write : Sauvegarder une mémoire
# - memory_read : Lire une mémoire spécifique
# - memory_search : Rechercher par mot-clé/tags
# - memory_stats : Voir les statistiques
```

---

## Architecture Système

```
┌─────────────────────────────────────────────────────────────┐
│  Memory Banks des Agents (Markdown)                          │
│  .kilocode/rules/memory-bank/                              │
│  .clinerules/memory-bank/                                   │
│  .roo/memory-bank/                                         │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼ Synchronisation Bidirectionnelle
┌─────────────────────┬───────────────────────────────────────┐
│  agentMemory (Stockage Structuré + MCP)                     │
│  .agentMemory/*.json                                        │
│  ├── Outils MCP (memory_write, memory_search, etc.)       │
│  ├── Dashboard avec analyses                               │
│  └── Recherche multi-projets                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Licence

MIT © Amit Rathiesh (Webzler Solutions Inc.)
