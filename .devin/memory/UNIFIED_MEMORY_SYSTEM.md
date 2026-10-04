# Système de Mémoire Unifié

## Architecture
Le système de mémoire unifié intègre trois types de stockage :
- **Cache**: Mémoire rapide pour les accès fréquents
- **Graph**: Relations entre entités et connaissances
- **Vector**: Recherche sémantique et similarités

## Composants

### 1. Cache System
- Base de données: `runtime-cache.db`
- Usage: Accès rapide aux données fréquemment utilisées
- TTL: Configurable par type de donnée
- Taille: Auto-gérée avec LRU

### 2. Graph Memory
- Base de données: `graph-memory.db`
- Usage: Relations entre entités, historique
- Structure: Noeuds et arêtes pondérées
- Requêtes: Traversals, patterns, chemins

## 🧠 DISCIPLINE DE MÉMOIRE UNIFIÉE (AGENTMEMORY)

### 1. ANCRAGE DU STOCKAGE
- **OBLIGATION** : Toute donnée de mémoire persistante (KV, Graph, Vector) DOIT être stockée exclusivement dans `<AGENTMEMORY_DATA_ROOT>/current_workspace/`.
- **ISOLATION** : Utiliser un sous-dossier par projet (`<AGENTMEMORY_DATA_ROOT>/current_workspace/${projectId}/agentmemory`).
- **BRIDGE** : Le script `scripts/memory-bridge.js` assure la liaison entre les scans locaux et ce stockage.

### 2. SOURCING SYSTÉMATIQUE
- **AVANT TOUTE TÂCHE** : Utiliser systématiquement `memory_search()` pour identifier le contexte existant.
- **DURÉE DE VIE** : Ne jamais supposer qu'une information est "connue" par défaut.

### 3. TRACE DE DÉCISION (ADR)
- **APRÈS TOUTE DÉCISION** : Utiliser `memory_write()` pour documenter chaque choix structurel.

## Politiques d'Accès

### Lecture
1. Vérifier le cache d'abord
2. Si miss, consulter vector store
3. Mettre à jour le cache avec les résultats

### Écriture
1. Écrire dans la base primaire
2. Invalider le cache concerné
3. Mettre à jour les indexes si nécessaire

### Consolidation
- Quotidienne pour les données anciennes
- Automatique basée sur l'usage
- Manuelle via API d'administration

## Sécurité
- Chiffrement des données sensibles
- Contrôle d'accès par rôle
- Audit trail complet
- Backup automatique

## Performance
- Latence cible: <100ms (cache), <500ms (vector)
- Disponibilité: 99.9%
- Scalabilité: Horizontale
- Monitoring: Métriques en temps réel