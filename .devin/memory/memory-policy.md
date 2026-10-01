# Politique de Gestion de la Mémoire

## Principes Directeurs

### 1. Hiérarchie de Stockage
- **Hot Data**: Cache (accès < 1h)
- **Warm Data**: Vector store (accès < 24h)
- **Cold Data**: Archive (accès > 24h)

### 2. Cycle de Vie
```mermaid
graph LR
    A[Création] --> B[Hot Cache]
    B --> C[Vector Store]
    C --> D[Archive]
    D --> E[Suppression]
```

### 3. Rétention des Données
- **Sessions**: 30 jours
- **Décisions**: 1 an
- **Code**: Permanent
- **Logs**: 90 jours

## Politiques Spécifiques

### Cache Management
- **TTL par défaut**: 1 heure
- **Taille max**: 1GB
- **Éviction**: LRU
- **Refresh**: On-demand

### Vector Store
- **Embeddings**: OpenAI text-embedding-3-large
- **Dimension**: 3072
- **Index**: HNSW
- **Similarity**: Cosine

### Graph Memory
- **Noeuds**: Entités (utilisateurs, projets, fichiers)
- **Arêtes**: Relations (possède, modifie, dépend)
- **Pondération**: Temporelle + fréquence
- **Traversal**: Profondeur max 5

## Nettoyage et Maintenance

### Automatique
- **Quotidien**: Cache cleanup
- **Hebdomadaire**: Vector optimization
- **Mensuel**: Graph consolidation

### Manuel
- **Full rebuild**: Nécessaire après migration majeure
- **Partial sync**: Pour corrections spécifiques
- **Export**: Pour backup externe

## Monitoring
- **Utilisation**: CPU, mémoire, stockage
- **Performance**: Latence, throughput
- **Erreurs**: Rate d'échec par type
- **Alertes**: Seuils configurables