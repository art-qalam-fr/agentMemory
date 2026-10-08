---
status: draft
owner: cascade
summary: Compatibilité de l’extension agentMemory avec l’infrastructure MCP locale (cache, memory, sqlite-node, qdrant, zvec) et recommandations d’intégration.
---

## 1. Contexte
- Extension VS Code/Devin **agentMemory 0.1.0** (packagée en `.vsix`).
- Serveurs MCP locaux déjà déclarés : `cache`, `agentmemory`, `filesystem`, `memory`, `orchestrator`, `postgres`, `qdrant`, `sqlite-node`, `zvec` (@<USERPROFILE>\.codeium\devin\mcp_config.json#1-166).
- L’extension démarre un serveur MCP **embarqué** (`out/mcp-server/server.js`) pour chaque workspace (@<HEPHAISTOS_ROOT>\agentMemory\src\extension.ts#104-131). Le `mcp_config.json` démarre aussi un serveur agentmemory **externe** via Node.

## 2. Points de compatibilité
- **Double serveur agentMemory** :
  - L’extension lance son serveur MCP bundlé (paramètres: `projectId = basename(workspace)` + `workspacePath`).
  - Le fichier mcp_config.json lance aussi `<HEPHAISTOS_ROOT> avec `${workspaceBasename}`, `${workspace}`.
  - Conclusion : OK mais redondant. Garder un seul chemin de démarrage pour éviter des conflits de ports/logs.

- **Cache / memory / sqlite-node** :
  - Les serveurs MCP `cache` et `memory` utilisent SQLite sous `<AGENTMEMORY_DATA_ROOT>/current_workspace/...` et respectent l’architecture unifiée locale (cache + graph).
  - L’extension agentMemory stocke par défaut `./mcp-data` (config `agentMemory.storageLocation`). Compatibilité fonctionnelle, mais non mutualisée avec `<AGENTMEMORY_DATA_ROOT>/current_workspace`. Pour une mutualisation complète, reconfigurer `agentMemory.storageLocation` vers `<AGENTMEMORY_DATA_ROOT>/current_workspace` (ou un sous-dossier dédié) dans les settings VS Code/Devin.

- **Qdrant / Zvec** :
  - Les serveurs `qdrant` (vecteurs denses) et `zvec` (hybride local) sont déjà configurés dans `mcp_config.json`.
  - L’extension agentMemory n’appelle pas directement qdrant/zvec ; elle expose un API Memory (KV + cache + dashboard). Pas d’incompatibilité directe.

- **Security / Interceptor** :
  - `SecurityManager` et `InterceptorManager` injectent des règles côté VS Code (@<HEPHAISTOS_ROOT>\agentMemory\src\extension.ts#42-99). Pas de conflit MCP détecté.

## 3. Risques et mitigations
- **Port dashboard (3333)** : si vous démarrez le dashboard (commande `Start Dashboard Server`), vérifier qu’aucun autre service n’occupe le port. Mitigation : changer le port via env `AGENTMEMORY_DASHBOARD_PORT` dans les settings si besoin.
- **Taille du VSIX** (9.44 MB, 5720 fichiers) : warning `vsce` recommande un bundling et un `.vscodeignore` plus strict. Non bloquant pour l’intégration, mais à optimiser.
- **Redondance de stockage** : extension stocke localement dans `./mcp-data` alors que l’architecture unifiée vise `<AGENTMEMORY_DATA_ROOT>/current_workspace`. Recommandé d’aligner le chemin pour faciliter la consolidation.

## 4. Recommandations d’intégration
1) **Choisir un seul point de démarrage agentMemory** :
   - Option A (recommandée) : garder le serveur MCP via `mcp_config.json` (chemin absolu déjà corrigé) et désactiver le démarrage automatique dans l’extension (à faire dans le code ou via une option future).
   - Option B : laisser l’extension démarrer son serveur bundlé et retirer l’entrée `agentmemory` de `mcp_config.json`. 
   - Éviter le double démarrage pour limiter le bruit de logs.

2) **Aligner le stockage** :
   - Dans les settings VS Code/Devin, définir `agentMemory.storageLocation` sur `<AGENTMEMORY_DATA_ROOT>/current_workspace/agentmemory` (ou similaire) pour rester cohérent avec `cache/memory/sqlite-node`.

3) **Dashboard** :
   - Si besoin du dashboard, lancer la commande `agentMemory: Start Dashboard Server`. Changer le port via env si conflit (`AGENTMEMORY_DASHBOARD_PORT`).

4) **Optimisation VSIX** (non bloquant) :
   - Ajouter un `.vscodeignore` pour exclure `node_modules` superflus, `.git`, tests, scripts non nécessaires.
   - Envisager un bundling (esbuild/webpack) pour réduire le nombre de fichiers.

5) **Version vsce** :
   - Mettre à jour @vscode/vsce global (2.32.0 → 3.7.1) pour profiter des fixes et avertissements récents.

## 5. Conclusion
- Compatibilité générale : OK. Aucun conflit critique avec les MCP existants (cache/memory/sqlite-node/qdrant/zvec).
- Action recommandée : éviter le double démarrage du serveur agentMemory et aligner le chemin de stockage sur `<AGENTMEMORY_DATA_ROOT>/current_workspace` pour rester dans l’architecture mémoire unifiée locale/globale.
