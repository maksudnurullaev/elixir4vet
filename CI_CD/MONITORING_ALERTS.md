# 📊 Мониторинг и Алерты

## Встроенный Health Check

Приложение имеет встроенный health check endpoint:

```bash
# Простой health check
GET /health
Response: {
  "status": "ok",
  "timestamp": "2024-02-05T12:00:00Z",
  "app": "elixir4vet",
  "version": "0.1.0"
}

# Extended health check (включая БД)
GET /health/extended
Response: {
  "status": "ok",
  "timestamp": "2024-02-05T12:00:00Z",
  "app": "elixir4vet",
  "version": "0.1.0",
  "database": {
    "status": "ok",
    "checked_at": "2024-02-05T12:00:00Z"
  }
}
```

---

## Мониторинг с помощью Prometheus

### Установка Prometheus

```bash
# На сервер мониторинга
docker run -d \
  --name prometheus \
  -p 9090:9090 \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

### Конфиг Prometheus (prometheus.yml)

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'elixir4vet'
    static_configs:
      - targets: ['your-server-ip:4000']
    metrics_path: '/metrics'
    scrape_interval: 30s
    scrape_timeout: 10s
```

### Добавление метрик в приложение

```elixir
# lib/elixir4vet/application.ex

defmodule Elixir4vet.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # ... другие сервисы
      
      # Telemetry для Prometheus
      {Telemetry.Metrics.ConsoleReporter,
       metrics: metrics(),
       options: [io: :stderr]}
    ]

    opts = [strategy: :one_for_one, name: Elixir4vet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config(key, default) do
    Application.get_env(:elixir4vet, key, default)
  end

  defp metrics do
    [
      # Phoenix metrics
      summary("phoenix.router_dispatch.stop.duration",
        unit: {:microsecond, :millisecond},
        description: "The time it takes to dispatch the router"
      ),
      
      # VM metrics
      summary("vm.memory.total",
        unit: :byte,
        description: "Total memory available"
      ),
      
      # HTTP metrics
      counter("http.requests.total",
        description: "Total HTTP requests"
      ),
      
      # Database metrics
      summary("db.query.total_time",
        unit: {:microsecond, :millisecond},
        description: "Database query time"
      )
    ]
  end
end
```

---

## Мониторинг с помощью New Relic

### Установка

```elixir
# mix.exs
defp deps do
  [
    # ... другие зависимости
    {:new_relic_agent, "~> 1.0"}
  ]
end
```

### Конфигурация

```elixir
# config/prod.exs

config :new_relic_agent,
  app_name: "Elixir4vet",
  license_key: System.get_env("NEW_RELIC_LICENSE_KEY"),
  harvest_cycle: 60_000,
  log_level: :info
```

---

## Сбор логов с Elasticsearch/Logstash/Kibana (ELK Stack)

### Конфигурация Logstash

```bash
# /etc/logstash/conf.d/elixir4vet.conf

input {
  file {
    path => "/var/log/elixir4vet/*.log"
    start_position => "beginning"
    codec => multiline {
      pattern => "^%d"
      negate => true
      what => "previous"
    }
  }
}

filter {
  grok {
    match => { "message" => "%{TIMESTAMP_ISO8601:timestamp} \[%{LOGLEVEL:level}\] %{GREEDYDATA:message}" }
  }
  
  mutate {
    add_field => { "application" => "elixir4vet" }
    add_field => { "environment" => "production" }
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "elixir4vet-%{+YYYY.MM.dd}"
  }
}
```

### Запуск стека

```bash
docker-compose -f docker-compose.elk.yml up -d
```

### Kibana dashboard

```bash
# Откройте http://localhost:5601
# Создайте index pattern: elixir4vet-*
# Создайте dashboard для просмотра логов
```

---

## Алерты через Slack

### GitHub Actions Slack интеграция

Уже настроена в `.github/workflows/deploy.yml`:

```yaml
- name: Notify deployment
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: |
      Deployment to production ${{ job.status }}
      Commit: ${{ github.sha }}
      Author: ${{ github.actor }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

### Получение Slack webhook

1. Перейдите на https://api.slack.com/apps
2. Создайте новое приложение
3. Активируйте "Incoming Webhooks"
4. Скопируйте webhook URL
5. Добавьте в GitHub Secrets как `SLACK_WEBHOOK`

---

## Сбор метрик в Datadog

### Установка

```elixir
# mix.exs
defp deps do
  [
    {:datadog, git: "https://github.com/DataDog/dd-trace-rb", sparse: "contrib/elixir"}
  ]
end
```

### Конфигурация

```elixir
# config/prod.exs

config :datadog_trace,
  enabled: true,
  api_endpoint: "https://api.datadoghq.eu",
  service_name: "elixir4vet"
```

---

## Сбор логов в Datadog

### Конфиг Agent

```yaml
# /etc/datadog-agent/conf.d/elixir4vet.d/conf.yaml

logs:
  - type: file
    path: /var/log/elixir4vet/*.log
    source: elixir
    service: elixir4vet
    tags:
      - env:production
```

---

## Uptime мониторинг

### Использование uptimerobot.com

```bash
# Создайте monitor для health check
GET https://your-domain.com/health
Interval: 5 minutes
Timeout: 30 seconds
```

### Использование Healthchecks.io

```bash
# Создайте проект и получите UUID
# Добавьте в cronjob
0 * * * * curl -fsS -m 10 https://hc-ping.com/<uuid>/elixir4vet

# Приложение пингует каждый час
# Если пинг не приходит > периода, срабатывает алерт
```

---

## Сбор метрик с помощью Telegraf

### Конфигурация

```toml
# /etc/telegraf/telegraf.conf

[[inputs.http_response]]
  urls = ["http://localhost:4000/health"]
  response_timeout = "5s"
  method = "GET"

[[inputs.exec]]
  commands = [
    "ps aux | grep -E 'bin/elixir4vet|erl' | wc -l"
  ]
  name_override = "elixir_process_count"

[[inputs.disk]]
  paths = ["/opt/elixir4vet/data"]
  ignore_file_systems = ["tmpfs", "devtmpfs"]

[[outputs.influxdb]]
  urls = ["http://influxdb:8086"]
  database = "telegraf"
```

---

## Dashboard примеры

### Grafana Dashboard для Phoenix

```json
{
  "dashboard": {
    "title": "Elixir4vet Production",
    "panels": [
      {
        "title": "HTTP Requests",
        "targets": [
          {
            "expr": "rate(phoenix_router_dispatch_stop_duration_microseconds_total[5m])"
          }
        ]
      },
      {
        "title": "Database Queries",
        "targets": [
          {
            "expr": "rate(ecto_query_duration_microseconds_total[5m])"
          }
        ]
      },
      {
        "title": "Memory Usage",
        "targets": [
          {
            "expr": "vm_memory_total_bytes"
          }
        ]
      },
      {
        "title": "Error Rate",
        "targets": [
          {
            "expr": "rate(phoenix_router_dispatch_exception_total[5m])"
          }
        ]
      }
    ]
  }
}
```

---

## Настройка алертов

### Prometheus Alert Rules

```yaml
# /etc/prometheus/alert.rules.yml

groups:
  - name: elixir4vet
    interval: 30s
    rules:
      - alert: ApplicationDown
        expr: up{job="elixir4vet"} == 0
        for: 2m
        annotations:
          summary: "Elixir4vet application is down"

      - alert: HighErrorRate
        expr: rate(phoenix_errors_total[5m]) > 0.1
        for: 5m
        annotations:
          summary: "High error rate detected"

      - alert: HighMemoryUsage
        expr: vm_memory_total_bytes > 1073741824  # 1GB
        for: 5m
        annotations:
          summary: "Memory usage above 1GB"

      - alert: DatabaseSlow
        expr: histogram_quantile(0.95, ecto_query_duration_microseconds) > 1000000
        for: 10m
        annotations:
          summary: "Database queries are slow"
```

### Отправка алертов в Slack

```yaml
# /etc/prometheus/alertmanager.yml

global:
  slack_api_url: '$SLACK_WEBHOOK_URL'

route:
  receiver: 'slack'
  repeat_interval: 4h

receivers:
  - name: 'slack'
    slack_configs:
      - channel: '#devops'
        title: 'Elixir4vet Alert'
        text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

---

## Контрольный список мониторинга

- [ ] Health check endpoint работает
- [ ] Prometheus или другой мониторинг настроен
- [ ] Логи собираются и индексируются
- [ ] Slack интеграция для алертов
- [ ] Uptime мониторинг настроен
- [ ] Dashboards созданы
- [ ] Alert rules настроены
- [ ] Backup БД автоматизирован
- [ ] Rotation логов настроена
- [ ] Есть способ проверить производительность БД
