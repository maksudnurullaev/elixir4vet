# 🔧 Troubleshooting Guide

## Частые ошибки и их решения

### 1. "SSH Permission denied (publickey)"

**Симптом:**
```
error: Permission denied (publickey)
fatal: Could not read from remote repository
```

**Решение:**

```bash
# На сервере, проверьте authorized_keys
cat /home/elixir4vet/.ssh/authorized_keys

# Убедитесь что ключ правильный
# Скопируйте публичный ключ еще раз
echo "ssh-ed25519 .... github-actions" >> /home/elixir4vet/.ssh/authorized_keys

# Установите правильные права
chmod 600 /home/elixir4vet/.ssh/authorized_keys
chmod 700 /home/elixir4vet/.ssh

# На локальной машине, проверьте подключение
ssh -i ~/.ssh/github_deploy -vvv elixir4vet@your-server-ip
```

### 2. "SECRET_KEY_BASE is missing"

**Симптом:**
```
(RuntimeError) environment variable SECRET_KEY_BASE is missing.
You can generate one by calling: mix phx.gen.secret
```

**Решение:**

```bash
# Генерируем secret на локальной машине или сервере
mix phx.gen.secret

# Скопируем значение и добавим в /etc/elixir4vet/.env.prod
sudo nano /etc/elixir4vet/.env.prod

# SECRET_KEY_BASE=<вставьте значение>

# Перезагружаем сервис
sudo systemctl restart elixir4vet
```

### 3. "Database connection timeout"

**Симптом:**
```
DBConnection.ConnectionError: tcp connect (localhost:5432): timeout
```

**Решение:**

```bash
# Проверьте переменные БД
sudo cat /etc/elixir4vet/.env.prod | grep DATABASE

# Проверьте что БД доступна
ls -la /opt/elixir4vet/data/
du -sh /opt/elixir4vet/data/elixir4vet_prod.db

# Проверьте права доступа
sudo chown elixir4vet:elixir4vet /opt/elixir4vet/data/
sudo chmod 755 /opt/elixir4vet/data/

# Перезагружаем сервис
sudo systemctl restart elixir4vet
```

### 4. "Eaddrinuse: address already in use"

**Симптом:**
```
eaddrinuse: address already in use :::4000
```

**Решение:**

```bash
# Проверьте какой процесс использует порт 4000
sudo netstat -tlnp | grep 4000
sudo lsof -i :4000

# Убейте процесс если нужно
sudo kill -9 <PID>

# Или используйте другой порт
# PORT=4001 ./bin/elixir4vet start
```

### 5. "Connection refused при подключении Nginx"

**Симптом:**
```
[error] 1234#1234: *1 connect() failed (111: Connection refused)
```

**Решение:**

```bash
# Проверьте что приложение запущено
sudo systemctl status elixir4vet

# Проверьте логи приложения
sudo journalctl -u elixir4vet -n 50

# Проверьте на каком порту слушает
sudo netstat -tlnp | grep elixir

# Проверьте Nginx конфиг
sudo nginx -t

# Если ошибка в конфиге, исправьте и перезагрузите
sudo systemctl reload nginx
```

### 6. "Health check failed"

**Симптом:**
```
Health check attempt 1/10 failed, retrying in 2 seconds...
```

**Решение:**

```bash
# Провертите что приложение запущено
sudo systemctl status elixir4vet

# Проверьте логи
sudo journalctl -u elixir4vet -n 100

# Проверьте вручную на localhost
curl -v http://localhost:4000/health

# Проверьте переменные окружения
sudo cat /etc/elixir4vet/.env.prod

# Проверьте что порт правильный
sudo netstat -tlnp | grep 4000
```

### 7. "Migrations failed"

**Симптом:**
```
** (Ecto.MigrationError) migrations failed when trying to run
```

**Решение:**

```bash
# Запустите миграции вручную с логами
sudo -u elixir4vet /opt/elixir4vet/_build/prod/rel/elixir4vet/bin/elixir4vet eval \
  "Elixir4vet.Release.migrate()" 2>&1 | tee /tmp/migrations.log

# Проверьте логи
cat /tmp/migrations.log

# Если БД повреждена, попробуйте откатить и пересоздать
rm /opt/elixir4vet/data/elixir4vet_prod.db
sudo systemctl restart elixir4vet
```

### 8. "Out of memory"

**Симптом:**
```
Memory usage above 1GB
```

**Решение:**

```bash
# Проверьте размер процесса
ps aux | grep elixir4vet

# Проверьте размер БД
du -sh /opt/elixir4vet/data/elixir4vet_prod.db

# Если БД большая, очистите неиспользуемые данные
# Или настройте сборку мусора

# Проверьте pool size в конфиге
sudo cat /etc/elixir4vet/.env.prod | grep POOL_SIZE

# Уменьшите если нужно
sudo nano /etc/elixir4vet/.env.prod
# POOL_SIZE=5

# Перезагружаем
sudo systemctl restart elixir4vet

# Мониторьте потребление памяти
watch -n 1 'ps aux | grep [e]rlang'
```

### 9. "Nginx 502 Bad Gateway"

**Симптом:**
```
502 Bad Gateway
upstream timed out while connecting to upstream
```

**Решение:**

```bash
# Проверьте что приложение запущено
sudo systemctl status elixir4vet

# Проверьте логи приложения
sudo journalctl -u elixir4vet -f

# Проверьте logи Nginx
sudo tail -f /var/log/nginx/error.log

# Встряхните Nginx
sudo nginx -t && sudo systemctl reload nginx

# Проверьте переменные окружения
sudo cat /etc/elixir4vet/.env.prod

# Убедитесь что приложение слушает правильный порт
curl -v http://localhost:4000/
```

### 10. "GitHub Actions SSH timeout"

**Симптом:**
```
timeout waiting for ssh
```

**Решение:**

```bash
# Проверьте что сервер доступен
ping your-server-ip

# SSH логин с правильными параметрами
ssh -i /path/to/key -p 22 elixir4vet@your-server-ip

# Увелильте timeout в workflow if needed:
# timeout-minutes: 30

# Проверьте firewall на сервере
sudo ufw status
sudo ufw allow 22/tcp

# Проверьте SSH daemon
sudo systemctl status ssh
sudo journalctl -u ssh -n 20
```

---

## Debug команды

### Проверка статуса сервиса

```bash
# Основной статус
sudo systemctl status elixir4vet

# Детальный статус с логами
sudo systemctl status elixir4vet -n 100 --no-pager

# Перезагрузка
sudo systemctl restart elixir4vet

# Остановка
sudo systemctl stop elixir4vet

# Запуск
sudo systemctl start elixir4vet

# Дефиниция сервиса
sudo cat /etc/systemd/system/elixir4vet.service
```

### Проверка логов

```bash
# Последние 100 строк
sudo journalctl -u elixir4vet -n 100

# В реальном времени
sudo journalctl -u elixir4vet -f

# За последний час
sudo journalctl -u elixir4vet --since "1 hour ago"

# Только ошибки
sudo journalctl -u elixir4vet -p err

# С подробностью (с имена функций)
sudo journalctl -u elixir4vet -o verbose

# Export в файл
sudo journalctl -u elixir4vet > /tmp/elixir4vet.log
```

### Проверка процессов

```bash
# Все processes Erlang/Elixir
ps aux | grep [e]rlang

# Specific приложения
ps aux | grep [b]in/elixir4vet

# Память и CPU
top -p $(pgrep -f "bin/elixir4vet")

# Файловые дескрипторы
lsof -p $(pgrep -f "[b]in/elixir4vet" | head -1)

# Сетевые подключения
netstat -antp | grep elixir
```

### Проверка портов

```bash
# Кто слушает на 4000
sudo netstat -tlnp | grep 4000

# Все открытые порты
sudo netstat -tlnp

# Все IPv4 процессы
sudo ss -tlnp | grep LISTEN

# Проверить доступност порта снаружи
curl http://localhost:4000/
curl -v http://localhost:4000/health
```

### Проверка файловой системы

```bash
# Свободное место
df -h

# Использование в /opt
du -sh /opt/elixir4vet*

# Использование БД
du -sh /opt/elixir4vet/data/

# Права доступа
ls -la /opt/elixir4vet/
sudo ls -la /opt/elixir4vet/data/

# Inode использование
df -i
```

### Проверка сети

```bash
# Ping сервера
ping your-server-ip

# SSH подключение
ssh -vvv elixir4vet@your-server-ip

# Curl с verbose
curl -vvv http://localhost:4000/health

# NC проверка порта
nc -zv localhost 4000

# Netstat все подключения
netstat -an | grep ESTABLISHED
```

### Проверка БД

```bash
# Запуск iex с БД
sudo -u elixir4vet /opt/elixir4vet/_build/prod/rel/elixir4vet/bin/elixir4vet remote

# Queries (если есть IEx доступ)
iex(1)> alias Elixir4vet.Repo
iex(2)> Repo.query("SELECT COUNT(*) FROM users")

# Sqlite check
sqlite3 /opt/elixir4vet/data/elixir4vet_prod.db ".tables"
sqlite3 /opt/elixir4vet/data/elixir4vet_prod.db ".schema"
```

---

## Сбор информации для отчета об ошибке

Если нужно создать issue, соберите:

```bash
#!/bin/bash
# Создает файл с диагностической информацией

mkdir -p /tmp/elixir4vet_debug
cd /tmp/elixir4vet_debug

# Версии
echo "=== System Info ===" > system_info.txt
hostnamectl >> system_info.txt
uname -a >> system_info.txt
df -h >> system_info.txt

# Статус сервиса
echo "=== Service Status ===" > service_status.txt
sudo systemctl status elixir4vet >> service_status.txt 2>&1

# Логи
echo "=== Recent Logs ===" > recent_logs.txt
sudo journalctl -u elixir4vet -n 200 >> recent_logs.txt 2>&1

# Конфиг (без sensitive данных)
echo "=== Config ===" > config.txt
sudo grep -v "SECRET\|PASSWORD\|API_KEY" /etc/elixir4vet/.env.prod >> config.txt 2>&1

# Процессы
echo "=== Processes ===" > processes.txt
ps aux | grep -E "erl|elixir|beam" >> processes.txt

# Сеть
echo "=== Network ===" > network.txt
sudo netstat -tlnp >> network.txt 2>&1

# Диск
echo "=== Disk Usage ===" > disk.txt
sudo du -sh /opt/elixir4vet/* >> disk.txt 2>&1

# Архиватор
tar czf elixir4vet_debug.tar.gz *.txt

echo "Debug info saved to /tmp/elixir4vet_debug/elixir4vet_debug.tar.gz"
```

Запустите скрипт и прикрепите архив к issue.

---

## Восстановление после критического сбоя

```bash
# 1. Остановите сервис
sudo systemctl stop elixir4vet

# 2. Создайте backup текущего состояния
sudo cp -r /opt/elixir4vet /opt/elixir4vet.backup

# 3. Очистите и пересоберите
sudo -u elixir4vet bash -c 'cd /opt/elixir4vet && rm -rf _build && mix deps.clean --all'

# 4. Переустановие зависимостей
sudo -u elixir4vet bash -c 'cd /opt/elixir4vet && mix deps.get --only prod'

# 5. Пересборка
sudo -u elixir4vet bash -c 'cd /opt/elixir4vet && mix assets.deploy && MIX_ENV=prod mix release'

# 6. Запуск миграций
sudo -u elixir4vet /opt/elixir4vet/_build/prod/rel/elixir4vet/bin/elixir4vet eval \
  "Elixir4vet.Release.migrate()"

# 7. Запуск сервиса
sudo systemctl start elixir4vet

# 8. Проверка
sudo systemctl status elixir4vet
curl http://localhost:4000/health
```
