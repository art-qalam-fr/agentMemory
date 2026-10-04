---
description: Initialisation complète d'un nouveau workspace (Injection Template + Isolation)
---

# Workflow d'Initialisation (AI-Cascade-System)

Ce workflow décrit la procédure stricte pour initialiser un nouveau workspace avec l'architecture de mémoire hybride isolée.

## 1. Injection du Template
- Copier récursivement le répertoire de référence vers la racine du nouveau projet :
  `Source : <USERPROFILE>\.codeium\devin\templates\AI-Cascade-System\`
- S'assurer que les dossiers `.devin/` et `.vscode/` sont bien présents à la racine.

## 2. Configuration du Projet
- Mettre à jour le champ `**Projet**:` dans `.devin/CASCADE.md`.
- Mettre à jour le champ `"workspace":` dans `.devin/scripts/ingestion.config.json`.

## 3. Activation de l'Isolation (Variables d'Environnement)
- Lancer le script de démarrage en mode force pour initialiser les variables utilisateur Windows :
  `powershell -ExecutionPolicy Bypass -File .\.devin\scripts\start-workspace.ps1 -IngestMode force`
- Vérifier que le message "Environnement utilisateur mis à jour" apparaît.

## 4. Finalisation (Redémarrage IDE)
- **OBLIGATOIRE** : Redémarrer Devin pour que les serveurs MCP rechargent les nouvelles variables d'environnement utilisateur.
- À la réouverture, la Task `.vscode/tasks.json` lancera automatiquement l'ingestion et le monitor.

## 5. Vérification du Système de Mémoire Unifié
- Effectuer une commande de test (ex: `/initialize-memory`).
- Vérifier que les fichiers dans `.devin/memory-database/graph/` ne sont plus à 0 Ko.

---
*Invoquer avec : /int*
