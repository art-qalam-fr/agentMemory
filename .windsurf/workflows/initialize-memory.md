---
description: Initialiser la mémoire locale à partir du scan d'ingestion
---

# Initialisation de la Mémoire Locale

Ce workflow permet à Cascade d'injecter les données scannées par les scripts PowerShell dans les serveurs MCP locaux (Zvec, Qdrant, Memory).

## Étapes d'Initialisation

1. **Vérification du Scan**
   - Lire le fichier `.windsurf/knowledge/ingestion_queue.json`.
   - Si le fichier est absent, demander à l'utilisateur de lancer `.\.windsurf\scripts\start-system.bat`.

2. **Injection Vectorielle (Zvec/Qdrant)**
   - Extraire les documents du JSON.
   - Utiliser `zvec_add_documents` pour stocker le contenu dans la collection locale.

3. **Injection Relationnelle (Graph/Memory)**
   - Créer les entités correspondantes aux fichiers importants via `create_entities`.
   - Établir les relations de base via `create_relations`.

4. **Nettoyage**
   - Une fois l'injection terminée, vider le fichier `ingestion_queue.json` pour éviter les doublons lors des prochains runs.

---
*Invoquer avec : /initialize-memory*
