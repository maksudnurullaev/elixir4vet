# 🚀 CI/CD Quick Start Guide

## За 10 минут до вашего первого автоматического развертывания

### Шаг 1: Инициализируем production сервер (5-7 минут)

На вашем production сервере (Ubuntu/Debian):

```bash
# Подключитесь по SSH
ssh root@your-server-ip

# Скачайте скрипт инициализации
curl -O https://raw.githubusercontent.com/ваш/repo/main/scripts/setup-server.sh

# Запустите скрипт
bash setup-server.sh

# Сценарий установит и настроит:
# ✓ Erlang + Elixir
# ✓ Nginx
# ✓ Systemd сервис
# ✓ Права доступа
```

**После завершения скрипта:**

```bash
# Отредактируйте переменные окружения
sudo nano /etc/elixir4vet/.env.prod

# Минимально требуется:
# PHX_HOST=ваш.домен.com
# SECRET_KEY_BASE=<сгенерируйте>

# Копируем в рабочий файл
sudo cp /etc/elixir4vet/.env.prod.template /etc/elixir4vet/.env.prod
sudo chmod 640 /etc/elixir4vet/.env.prod
```

### Шаг 2: Генерируем SSH ключ для CI/CD (2 минуты)

На локальной машине:

```bash
# Генерируем ключ
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_deploy

# Выводим приватный ключ
cat ~/.ssh/github_deploy
```

**На сервере** добавляем публичный ключ:

```bash
# На локальной машине скопируем публичный ключ
cat ~/.ssh/github_deploy.pub
```

```bash
# На сервере
sudo bash -c 'echo "<публичный ключ из выше>" >> /home/elixir4vet/.ssh/authorized_keys'
sudo chown elixir4vet:elixir4vet /home/elixir4vet/.ssh/authorized_keys
sudo chmod 600 /home/elixir4vet/.ssh/authorized_keys
```

### Шаг 3: Добавляем секреты в GitHub (3 минуты)

1. Перейдите в ваш репository на GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Нажмите **New repository secret** и добавьте:

```
SERVER_HOST         = IP или домен вашего сервера
SERVER_USER         = elixir4vet
SERVER_SSH_KEY      = <содержимое ~/.ssh/github_deploy>
SERVER_PORT         = 22 (или другой если используете)
PROJECT_PATH        = /opt/elixir4vet
DOCKER_USERNAME     = ваш Docker Hub username
DOCKER_PASSWORD     = ваш Docker Hub token
```

### Шаг 4: Первоначальное развертывание (2 минуты)

На сервере:

```bash
# Клонируем репозиторий
sudo -u elixir4vet git clone https://github.com/ваш/repo.git /opt/elixir4vet

# Запускаем развертывание
sudo /opt/elixir4vet/scripts/deploy.sh

# Проверяем статус
sudo systemctl status elixir4vet

# Проверяем здоровье
curl http://localhost:4000/health
```

---

## ✅ Готово!

Теперь при каждом `push` в `main` ветку:
1. ✅ Автоматически запускаются тесты
2. ✅ Собирается Docker образ
3. ✅ Развертывается на production
4. ✅ Выполняются миграции БД
5. ✅ Перезапускается сервис

### Проверьте развертывание

```bash
# Просмотр логов
sudo journalctl -u elixir4vet -f

# Проверка здоровья
curl https://ваш.домен.com/health
```

---

## 🐛 Выявление проблем

### Развертывание не сработало?

```bash
# Посмотрите логи GitHub Actions
# Repository → Actions → latest workflow

# Посмотрите логи на сервере
sudo journalctl -u elixir4vet -n 100
sudo tail -f /var/log/nginx/error.log
```

### SSH подключение отказано?

```bash
# На сервере проверьте authorized_keys
cat /home/elixir4vet/.ssh/authorized_keys

# Проверьте логи SSH
sudo tail -f /var/log/auth.log

# Убедитесь, что ключ правильный
ssh -i ~/.ssh/github_deploy elixir4vet@your-server-ip
```

### Приложение не запускается?

```bash
# Проверьте переменные окружения
sudo cat /etc/elixir4vet/.env.prod

# Проверьте, что релиз скомпилирован
ls -la /opt/elixir4vet/_build/prod/rel/elixir4vet/bin/

# Проверьте права на БД
ls -la /opt/elixir4vet/data/
```

---

## 💡 Полезные команды

```bash
# Просмотр статуса сервиса
sudo systemctl status elixir4vet

# Перезагрузка приложения
sudo systemctl restart elixir4vet

# Просмотр логов в реальном времени
sudo journalctl -u elixir4vet -f

# Проверка здоровья приложения
curl -v http://localhost:4000/health
curl -v https://ваш.домен.com/health

# Проверка портов
sudo netstat -tlnp | grep 4000
sudo netstat -tlnp | grep 443

# Проверка свободного места
df -h

# Размер БД
du -sh /opt/elixir4vet/data/

# SSH на сервер с ключом
ssh -i ~/.ssh/github_deploy elixir4vet@your-server-ip
```

---

## 📚 Дальнейшие действия

После успешного первого развертывания:

1. **Установите SSL сертификат**
   ```bash
   sudo certbot certonly --nginx -d ваш.домен.com
   # обновите nginx.conf с путями к сертификатам
   ```

2. **Настройте email** (production маилер)
   ```elixir
   # config/prod.exs
   config :elixir4vet, Elixir4vet.Mailer,
     adapter: Swoosh.Adapters.Mailgun,  # или другой
     api_key: System.get_env("MAILGUN_API_KEY"),
     domain: System.get_env("MAILGUN_DOMAIN")
   ```

3. **Установите мониторинг и логирование**
   - Настройте alerts в GitHub/Slack
   - Очистите sensitive данные из логов
   - Установите ELK Stack или аналог

4. **Автоматический backup БД**
   ```bash
   # Добавьте cron job
   0 2 * * * /opt/elixir4vet/scripts/backup.sh
   ```

5. **Обновление SSL сертификата**
   ```bash
   sudo systemctl enable certbot.timer
   sudo systemctl start certbot.timer
   ```

---

## 🔒 Требования безопасности (ВАЖНО!)

- [ ] Измените пароль root SSH
- [ ] Отключите SSH по паролю (только ключи)
- [ ] Установите firewall правила
- [ ] Используйте HTTPS везде
- [ ] Не логируйте sensitive данные
- [ ] Регулярно обновляйте систему
- [ ] Создавайте backup БД
- [ ] Используйте strong SECRET_KEY_BASE

---

## 📞 Поддержка

Если что-то не работает:

1. Проверьте логи: `sudo journalctl -u elixir4vet -n 100`
2. Проверьте переменные: `sudo cat /etc/elixir4vet/.env.prod`
3. Проверьте файлы скрипта: `bash -x /opt/elixir4vet/scripts/deploy.sh`
4. Проверьте GitHub Actions логи: Repository → Actions → latest run
