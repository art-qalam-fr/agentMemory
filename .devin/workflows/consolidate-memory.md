---
description: Consolider les connaissances du Workspace vers la mémoire globale
---

# Consolidation de la Mémoire

Ce workflow guide Cascade pour analyser, filtrer et faire remonter les informations pertinentes du projet actuel vers votre mémoire centralisée.

## Étapes de Consolidation

1. **Analyse des interactions**
   - Examiner les derniers échanges et les tâches accomplies.
   - Identifier les nouveaux patterns de développement ou règles de travail adoptés.

2. **Extraction des connaissances transversales**
   - Lister les informations qui seraient utiles dans d'autres projets (Prompts, Skills, Standards).
   - Ignorer les détails spécifiques au code source de ce projet.

3. **Validation utilisateur**
   - Présenter une synthèse des points à "globaliser" pour approbation.

4. **Injection globale**
   - Utiliser les serveurs MCP (memory, zvec, qdrant) avec les chemins globaux pour stocker les connaissances validées.

5. **Clôture**
   - Marquer les données locales comme "consolidées" pour éviter les doublons.

---
*Invoquer avec : /consolidate-memory*
