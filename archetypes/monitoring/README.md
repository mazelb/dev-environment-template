# Monitoring Archetype

## Overview

Complete observability stack with Prometheus (metrics), Grafana (visualization), and Loki (logs) for monitoring AI/ML applications.

## Features

- 📊 **Metrics**: Prometheus for time-series metrics
- 📈 **Visualization**: Grafana dashboards for insights
- 📝 **Logs**: Loki for centralized log aggregation
- 🚨 **Alerting**: Prometheus alerting rules
- 🔍 **Tracing**: Ready for OpenTelemetry integration

## Quick Start

### 1. Start Monitoring Stack

```bash
docker-compose up -d
```

### 2. Access Dashboards

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Loki**: http://localhost:3100

### 3. Instrument Your Application

```python
from prometheus_fastapi_instrumentator import Instrumentator
from fastapi import FastAPI

app = FastAPI()

# Add Prometheus metrics
Instrumentator().instrument(app).expose(app)
```

## Services

### Prometheus (Port 9090)

Metrics collection and storage:
- Scrapes `/metrics` endpoints
- Stores time-series data
- Evaluates alerting rules

### Grafana (Port 3000)

Visualization and dashboards:
- Pre-configured datasources
- Custom dashboards
- Alerting integration

### Loki (Port 3100)

Log aggregation:
- Collects logs from containers
- Indexes for fast search
- Integrates with Grafana

### Promtail

Log shipping agent:
- Scrapes Docker container logs
- Labels and forwards to Loki
- Automatic service discovery

## Configuration

### Prometheus Scrape Targets

Edit `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'my-api'
    static_configs:
      - targets: ['api:8000']
```

### Alert Rules

Edit `prometheus/alerts.yml`:

```yaml
- alert: HighErrorRate
  expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
  for: 5m
  labels:
    severity: critical
```

### Grafana Datasources

Automatically provisioned:
- Prometheus: http://prometheus:9090
- Loki: http://loki:3100

## Pre-configured Dashboards

### System Metrics
- CPU usage
- Memory usage
- Disk I/O
- Network traffic

### API Performance
- Request rate
- Response time (p50, p95, p99)
- Error rate
- Status code distribution

### LLM Metrics
- LLM request latency
- Token usage
- Cost tracking
- Model performance

## Custom Metrics

### FastAPI Example

```python
from prometheus_client import Counter, Histogram

# Request counter
requests_total = Counter(
    'api_requests_total',
    'Total API requests',
    ['method', 'endpoint', 'status']
)

# LLM latency
llm_duration = Histogram(
    'llm_request_duration_seconds',
    'LLM request duration',
    ['model', 'operation']
)

@app.post("/query")
async def query(request: QueryRequest):
    with llm_duration.labels(model="gpt-4", operation="query").time():
        result = await process_query(request)

    requests_total.labels(
        method="POST",
        endpoint="/query",
        status=200
    ).inc()

    return result
```

### Custom Metrics

```python
from prometheus_client import Gauge, Summary

# Active connections
active_connections = Gauge(
    'active_connections',
    'Number of active connections'
)

# Vector search latency
vector_search_duration = Summary(
    'vector_search_duration_seconds',
    'Vector search duration'
)
```

## Log Queries

### Grafana Explore

```logql
# All logs from API service
{container="api"}

# Error logs
{container="api"} |= "error"

# LLM requests
{container="api"} | json | model="gpt-4"

# Rate of errors
rate({container="api"} |= "error" [5m])
```

## Alerting

### Configured Alerts

1. **HighErrorRate**: Error rate > 5% for 5 minutes
2. **SlowResponseTime**: P95 latency > 2s for 5 minutes
3. **HighMemoryUsage**: Memory usage > 90% for 5 minutes
4. **HighLLMLatency**: LLM P95 latency > 30s for 5 minutes

### Alert Notifications

Configure in Grafana:
1. Go to Alerting → Contact points
2. Add Slack, Email, or Webhook
3. Create notification policies

## Composability

Combine with other archetypes:

```bash
# RAG with monitoring
./create-project.sh rag-system \
  --archetypes rag-project,monitoring

# Full AI stack
./create-project.sh ai-platform \
  --archetypes rag-project,agentic-workflows,monitoring
```

## Production Tips

1. **Retention**: Configure Prometheus retention period
2. **Storage**: Use persistent volumes for data
3. **Security**: Change default Grafana password
4. **Backup**: Regular backups of Grafana dashboards
5. **Scaling**: Consider Thanos for long-term storage

## Troubleshooting

### Prometheus Not Scraping

```bash
# Check targets
curl http://localhost:9090/api/v1/targets

# Verify service is exposing metrics
curl http://localhost:8000/metrics
```

### Grafana Can't Connect to Datasources

```bash
# Check network connectivity
docker exec grafana ping prometheus
docker exec grafana ping loki
```

### Missing Logs in Loki

```bash
# Check Promtail logs
docker logs promtail

# Verify Loki is receiving data
curl http://localhost:3100/ready
```

## References

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [PromQL Guide](https://prometheus.io/docs/prometheus/latest/querying/basics/)

## License

Part of dev-environment-template project.
