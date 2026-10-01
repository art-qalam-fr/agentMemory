# Configuration des Serveurs MCP

## Serveurs Actifs

### 1. Cache Server
```json
{
  "name": "cache",
  "host": "localhost",
  "port": 3001,
  "type": "redis",
  "database": "cache",
  "max_connections": 100,
  "timeout": 5000
}
```

### 2. Memory Server
```json
{
  "name": "memory",
  "host": "localhost",
  "port": 3002,
  "type": "sqlite",
  "database": "memory_mcp.db",
  "connection_pool": 20,
  "timeout": 10000
}
```

### 3. Orchestrator Server
```json
{
  "name": "orchestrator",
  "host": "localhost",
  "port": 3003,
  "type": "websocket",
  "max_clients": 50,
  "heartbeat": 30000
}
```

### 4. Qdrant Server
```json
{
  "name": "qdrant",
  "host": "localhost",
  "port": 6333,
  "type": "vector",
  "api_key": "${QDRANT_API_KEY}",
  "collection": "default"
}
```

### 5. Zvec Server
```json
{
  "name": "zvec",
  "host": "localhost",
  "port": 3004,
  "type": "vector",
  "provider": "local",
  "dimension": 3072,
  "index_type": "hnsw"
}
```

## Configuration de Connexion

### Environment Variables
```bash
export MCP_CACHE_URL="redis://localhost:6379"
export MCP_MEMORY_DB="memory_mcp.db"
export MCP_ORCHESTRATOR_URL="ws://localhost:3003"
export QDRANT_URL="http://localhost:6333"
export ZVEC_URL="http://localhost:3004"
```

### Health Checks
```bash
# Vérifier tous les serveurs
./mcp-health-check --all

# Vérifier un serveur spécifique
./mcp-health-check --server cache

# Redémarrer un serveur
./mcp-restart --server memory
```

## Load Balancing
- Round-robin pour les serveurs stateless
- Sticky sessions pour les serveurs avec état
- Auto-scaling basé sur la charge
- Failover automatique

## Sécurité
- TLS 1.3 pour toutes les connexions
- API keys rotation mensuelle
- Rate limiting par IP
- Audit logging complet