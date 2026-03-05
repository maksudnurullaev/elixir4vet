# CI/CD Setup Guide для Elixir4vet

## 📋 Содержание
1. [Обзор архитектуры](#обзор-архитектуры)
2. [GitHub Actions CI](#github-actions-ci)
3. [GitHub Actions CD](#github-actions-cd)
4. [Развертывание на сервер](#развертывание-на-сервер)
5. [Docker развертывание](#docker-развертывание)
6. [Мониторинг и логирование](#мониторинг-и-логирование)
7. [Решение проблем](#решение-проблем)

---

## Обзор архитектуры

```
┌─────────────────────────────────────────────────────────┐
│              GitHub Repository (main branch)             │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────┐
        │   GitHub Actions CI    │
        │  (test & validation)   │
        └────┬───────────────────┘
             │
    ┌────────┴────────┐
    │                 │
   ✓ PASS         ✗ FAIL
    │                 │
    ▼                 └──► Build fails, notify
┌──────────────────┐
│   Build Stage    │      (only on main branch)
│  (Docker image)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   Deploy Stage   │      (only on main branch)
│ (SSH to server)  │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────┐
│  Production Server       │
│  - Ubuntu/Debian         │
│  - Elixir/OTP installed  │
│  - Systemd service       │
│  - Nginx reverse proxy   │
│  - SQLite database       │
└──────────────────────────┘
```

---

## GitHub Actions CI

### Автоматические проверки на каждый push

Файл: `.github/workflows/ci.yml`

**Что делается:**
- ✅ Тестирование кода (mix test)
- ✅ Проверка форматирования (mix format)
- ✅ Статический анализ (Credo)
- ✅ Компиляция проекта
- ✅ Генерация отчета о покрытии тестами

**Срабатывает на:**
- `push` в ветки `main` и `develop`
- `pull_request` в ветки `main` и `develop`

**Требования:**
Никаких дополнительных секретов не требуется для CI.

---

## GitHub Actions CD

### Автоматическое развертывание на production

Файл: `.github/workflows/deploy.yml`

**Что делается:**
1. Сборка Docker образа (после успешного CI)
2. Отправка образа в Docker Registry
3. SSH на production сервер
4. Обновление кода
5. Сборка релиза
6. Выполнение миграций БД
7. Перезапуск сервиса
8. Проверка здоровья приложения

**Срабатывает на:**
- `push` в ветку `main`
- Ручное триггирование через Actions UI

### Необходимые GitHub Secrets

Добавьте в GitHub (Settings → Secrets and variables → Actions):

```
DOCKER_USERNAME             # Docker Hub username
DOCKER_PASSWORD             # Docker Hub token
SERVER_HOST                 # IP или домен вашего сервера
SERVER_USER                 # SSH пользователь
SERVER_SSH_KEY              # SSH приватный ключ
SERVER_PORT                 # SSH порт (default: 22)
PROJECT_PATH                # Путь к проекту на сервере (/opt/elixir4vet)
SLACK_WEBHOOK              # (Optional) Slack webhook для уведомлений
```

### GitHub Variables (не чувствительные данные)

Добавьте в GitHub (Settings → Variables):

```
DOCKER_USERNAME             # Docker Hub username (можно публичный)
```

---

## Развертывание на сервер

### Подготовка сервера (первый раз)

#### 1. Запустите скрипт инициализации

На целевом сервере (Ubuntu/Debian):

```bash
# Скопируйте скрипт на сервер
scp scripts/setup-server.sh user@your-server:/tmp/

# Подключитесь по SSH
ssh user@your-server

# Запустите скрипт (требует sudo)
sudo bash /tmp/setup-server.sh
```

Этот скрипт:
- Обновляет систему
- Устанавливает Erlang и Elixir
- Создает пользователя `elixir4vet`
- Устанавливает Nginx
- Конфигурирует systemd сервис
- Готовит логирование и права доступа

#### 2. Настройте переменные окружения

```bash
# Отредактируйте шаблон
sudo nano /etc/elixir4vet/.env.prod.template

# Скопируйте в рабочий файл
sudo cp /etc/elixir4vet/.env.prod.template /etc/elixir4vet/.env.prod

# Установите правильные права
sudo chmod 640 /etc/elixir4vet/.env.prod
```

**Важные переменные:**

```env
PHX_HOST=ваш.домен.com
PORT=4000
SECRET_KEY_BASE=<сгенерируйте с: mix phx.gen.secret>
DATABASE_PATH=/opt/elixir4vet/data/elixir4vet_prod.db
```

#### 3. Настройте SSL сертификат

```bash
sudo certbot certonly --nginx -d ваш.домен.com

# Обновите nginx.conf с путями к сертификатам
sudo nano /etc/nginx/sites-available/elixir4vet
```

#### 4. Первоначальная развертывание

```bash
# Клонируйте репо
sudo -u elixir4vet git clone https://github.com/ваш/repo.git /opt/elixir4vet

# Запустите развертывание
sudo /opt/elixir4vet/scripts/deploy.sh
```

### Мониторинг развертывания

Проверьте все сработало:

```bash
# Статус сервиса
sudo systemctl status elixir4vet

# Логи приложения
sudo journalctl -u elixir4vet -f -n 100

# Проверка здоровья
curl http://localhost:4000/health
```

---

## Docker развертывание

### Локальное тестирование Docker образа

```bash
# Сборка образа
docker build -t elixir4vet:latest .

# Запуск контейнера
docker-compose -f docker-compose.prod.yml up -d

# Проверка логов
docker-compose -f docker-compose.prod.yml logs -f web

# Остановка
docker-compose -f docker-compose.prod.yml down
```

### Развертывание с Docker Swarm или Kubernetes

#### Docker Swarm

```bash
# Инициализация свома (на главном узле)
docker swarm init

# Развертывание стека
docker stack deploy -c docker-compose.prod.yml elixir4vet

# Просмотр сервисов
docker service ls

# Масштабирование
docker service scale elixir4vet_web=3
```

#### Kubernetes

Создайте `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elixir4vet
spec:
  replicas: 3
  selector:
    matchLabels:
      app: elixir4vet
  template:
    metadata:
      labels:
        app: elixir4vet
    spec:
      containers:
      - name: elixir4vet
        image: your-registry/elixir4vet:latest
        ports:
        - containerPort: 4000
        env:
        - name: PHX_HOST
          value: "your-domain.com"
        - name: SECRET_KEY_BASE
          valueFrom:
            secretKeyRef:
              name: elixir4vet-secrets
              key: secret-key-base
        livenessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /health
            port: 4000
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
      restartPolicy: Always
---
apiVersion: v1
kind: Service
metadata:
  name: elixir4vet-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 4000
  selector:
    app: elixir4vet
```

Развертывание:

```bash
kubectl apply -f k8s/deployment.yaml
kubectl get pods
kubectl logs -f <pod-name>
```

---

## Настройка SSH ключей для CI/CD

### Генерирование ключей на локальной машине

```bash
# Создайте новую пару ключей
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_deploy

# Отобразите приватный ключ (для GitHub Secrets)
cat ~/.ssh/github_deploy
```

### На сервере (authorized_keys)

```bash
# Скопируйте публичный ключ
cat ~/.ssh/github_deploy.pub | sudo tee -a /home/elixir4vet/.ssh/authorized_keys

# Установите права
sudo chown elixir4vet:elixir4vet /home/elixir4vet/.ssh/authorized_keys
sudo chmod 600 /home/elixir4vet/.ssh/authorized_keys
```

### В GitHub Repository

1. Перейдите **Settings → Secrets and variables → Actions**
2. Нажмите **New repository secret**
3. Назовите: `SERVER_SSH_KEY`
4. Вставьте содержимое приватного ключа
5. Нажмите **Add secret**

---

## Мониторинг и логирование

### Логи системд

```bash
# Последние 100 строк
sudo journalctl -u elixir4vet -n 100 --no-pager

# В реальном времени
sudo journalctl -u elixir4vet -f

# За последний час
sudo journalctl -u elixir4vet --since "1 hour ago"

# С уровнем ERROR
sudo journalctl -u elixir4vet -p err
```

### Проверка здоровья приложения

```bash
# Простая проверка
curl http://localhost:4000/health

# С подробным выводом
curl -v http://localhost:4000/health

# Проверка через Nginx
curl https://ваш.домен.com/health
```

### Мониторинг ресурсов

```bash
# Используемая память
ps aux | grep elixir4vet | grep -v grep

# Файловые дескрипторы
lsof -p $(pgrep -f "[bin/elixir4vet start]")

# Проверка диска БД
du -sh /opt/elixir4vet/data/
```

### Логирование через ELK Stack (опционально)

Для более продвинутого мониторинга интегрируйте с ELK:

```elixir
# config/prod.exs
config :logger, :default_handler,
  formatter: {LogstashFormatter, %{
    app: :elixir4vet,
    environment: :prod
  }}
```

---

## Решение проблем

### Проблема: Сервис не запускается

```bash
# Проверьте логи
sudo journalctl -u elixir4vet -n 50

# Проверьте конфиг окружения
sudo cat /etc/elixir4vet/.env.prod | grep -E "SECRET_KEY_BASE|PHX_HOST"

# Проверьте права на БД
ls -la /opt/elixir4vet/data/
```

### Проблема: Миграции не выполняются

```bash
# Проверьте, существует ли модуль Release
ls -la /opt/elixir4vet/_build/prod/rel/elixir4vet/lib/

# Запустите миграции вручную
sudo -u elixir4vet /opt/elixir4vet/_build/prod/rel/elixir4vet/bin/elixir4vet eval \
  "Elixir4vet.Release.migrate()"
```

### Проблема: Nginx не распространяет трафик

```bash
# Проверьте конфиг Nginx
sudo nginx -t

# Проверьте логи Nginx
sudo tail -f /var/log/nginx/error.log

# Проверьте, слушает ли Phoenix на порту
sudo netstat -tlnp | grep 4000
```

### Проблема: С GitHub Actions не может подключиться по SSH

1. Проверьте `SERVER_SSH_KEY` в GitHub Secrets
2. Проверьте `authorized_keys` на сервере
3. Проверьте `SERVER_HOST` и `SERVER_USER`
4. Проверьте firewall правила

```bash
# На сервере, проверьте SSH логи
sudo tail -f /var/log/auth.log
```

### Проблема: Высокое использование памяти

```bash
# Проверьте количество процессов Erlang
ps aux | grep erl

# Проверьте размер БД
du -sh /opt/elixir4vet/data/elixir4vet_prod.db

# Проверьте переменные окружения
sudo cat /etc/elixir4vet/.env.prod | grep POOL_SIZE
```

---

## Откат на предыдущую версию

```bash
# Перейти в директорию backup
cd /opt/elixir4vet/releases/backup

# Найти нужный backup
ls -la

# Восстановить
cp -r backup-20240205-120000/* /opt/elixir4vet/

# Перезапустить сервис
sudo systemctl restart elixir4vet

# Проверить статус
sudo systemctl status elixir4vet
```

---

## Автоматическое обновление SSL сертификата

```bash
# Проверьте, что Certbot настроен для автообновления
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Проверьте статус
sudo systemctl status certbot.timer

# Зарежьте cron task (проверяется ежедневно)
# Это обычно уже сделано при установке Certbot
```

---

## Bacup базы данных

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/opt/elixir4vet/backups"
DB_FILE="/opt/elixir4vet/data/elixir4vet_prod.db"
DATE=$(date +%Y%m%d-%H%M%S)

mkdir -p $BACKUP_DIR

# SQLite backup
cp $DB_FILE $BACKUP_DIR/elixir4vet_prod-$DATE.db

# Сжатие
gzip $BACKUP_DIR/elixir4vet_prod-$DATE.db

# Удалить старые backup'ы (старше 30 дней)
find $BACKUP_DIR -name "*.db.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_DIR/elixir4vet_prod-$DATE.db.gz"
```

Добавьте в crontab:

```bash
# Ежедневно в 2:00 AM
0 2 * * * /opt/elixir4vet/scripts/backup.sh
```

---

## Производительность и оптимизация

### Рекомендуемые настройки для production

**memory limit** (BEAM):
```bash
export ERL_MAX_PORTS=65536
export ERL_MAX_ETS_TABLES=40000
```

**Connection pool** (config/prod.exs):
```elixir
config :elixir4vet, Elixir4vet.Repo,
  pool_size: 25  # для более высокой нагрузки
```

**Nginx worker processes**:
```bash
# Количество CPU cores * 2 в nginx.conf
worker_processes auto;
worker_connections 1024;
```

---

## Контрольный список перед production

- [ ] SSLсертификат установлен и обновляется
- [ ] Environment переменные правильно настроены
- [ ] Backup база данных работает
- [ ] Мониторинг и алерты настроены
- [ ] SSH ключи добавлены в GitHub Secrets
- [ ] Systemd сервис автозагружается
- [ ] Health check endpoint работает
- [ ] Логирование настроено
- [ ] Firewall правила в порядке
- [ ] Откат к предыдущей версии задокументирован
