# Configuration du Routage MCP

## Architecture de Routage

### 1. Request Router
```javascript
const router = {
  // Routage par type de requête
  routes: {
    "memory": ["cache", "memory"],
    "vector": ["qdrant", "zvec"],
    "agent": ["orchestrator"],
    "system": ["cache", "memory"]
  },
  
  // Priorités de routage
  priorities: {
    "critical": 1,
    "high": 2,
    "normal": 3,
    "low": 4
  },
  
  // Load balancing
  strategy: "round_robin",
  
  // Failover
  failover: {
    enabled: true,
    timeout: 5000,
    retries: 3
  }
};
```

### 2. Message Patterns

#### Request-Response
```json
{
  "type": "request",
  "id": "uuid",
  "target": "memory",
  "action": "get",
  "data": { "key": "user:123" },
  "priority": "normal",
  "timeout": 5000
}
```

#### Publish-Subscribe
```json
{
  "type": "event",
  "topic": "agent:status",
  "data": { "agent": "coder", "status": "busy" },
  "broadcast": true
}
```

### 3. Routes Spécifiques

#### Memory Routes
- `GET /memory/{key}`: Récupérer une valeur
- `POST /memory/{key}`: Stocker une valeur
- `DELETE /memory/{key}`: Supprimer une valeur
- `SEARCH /memory`: Rechercher dans la mémoire

#### Vector Routes
- `POST /vector/search`: Recherche vectorielle
- `POST /vector/index`: Indexer un document
- `DELETE /vector/{id}`: Supprimer un vecteur
- `GET /vector/stats`: Statistiques du vector store

#### Agent Routes
- `POST /agent/{name}/execute`: Exécuter une tâche
- `GET /agent/{name}/status`: Statut de l'agent
- `POST /agent/{name}/configure`: Configurer l'agent
- `GET /agent/list`: Lister tous les agents

### 4. Middleware Stack

```javascript
const middleware = [
  // Authentication
  auth({
    type: "jwt",
    secret: process.env.JWT_SECRET
  }),
  
  // Rate Limiting
  rateLimit({
    windowMs: 60000,
    max: 1000
  }),
  
  // Logging
  logger({
    level: "info",
    format: "json"
  }),
  
  // Metrics
  metrics({
    prometheus: true,
    labels: ["route", "method", "status"]
  }),
  
  // CORS
  cors({
    origins: ["http://localhost:3000"],
    credentials: true
  })
];
```

### 5. Circuit Breaker Pattern

```javascript
const circuitBreaker = {
  // Seuils
  threshold: {
    errorPercentage: 50,
    requestVolume: 20,
    sleepWindow: 60000
  },
  
  // États
  states: {
    CLOSED: "normal_operation",
    OPEN: "failing_fast",
    HALF_OPEN: "testing_recovery"
  },
  
  // Actions
  onOpen: () => logger.warn("Circuit breaker opened"),
  onClose: () => logger.info("Circuit breaker closed"),
  onHalfOpen: () => logger.info("Testing recovery")
};
```

## Monitoring

### Métriques Clés
- Request rate par route
- Response time percentiles
- Error rate par type
- Circuit breaker state changes

### Health Checks
- `/health`: Santé générale du routeur
- `/health/routes`: Santé des routes individuelles
- `/health/circuit`: État des circuit breakers

### Alertes
- Latence > 1s pendant 5min
- Error rate > 5% pendant 2min
- Circuit breaker ouvert
- Queue size > 1000