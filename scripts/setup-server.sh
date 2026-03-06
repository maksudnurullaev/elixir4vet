#!/bin/bash

# Server setup script for Elixir4vet
# Must be run as root: sudo bash scripts/setup-server.sh
# Prerequisites: asdf with erlang and elixir plugins must be installed and configured

set -e

# Configuration
PROJECT_DIR="/opt/elixir4vet"
APP_USER="elixir4vet"
APP_GROUP="elixir4vet"
OTP_VERSION="28.4"
ELIXIR_VERSION="1.19.5"
RUN2INSTALL="curl -fsSO https://elixir-lang.org/install.sh && sh install.sh elixir@$ELIXIR_VERSION otp@$OTP_VERSION"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }
log_skip()    { echo -e "${YELLOW}[~]${NC} $1 — already installed, skipping"; }

command_exists() { command -v "$1"; }

# ─── Preflight checks ─────────────────────────────────────────────────────────
log_info "Checking prerequisites..."

command_exists erl \
    || log_error "Erlang $OTP_VERSION not found. Run: $RUN2INSTALL"

command_exists iex \
    || log_error "Elixir $ELIXIR_VERSION not found. Run: $RUN2INSTALL"

log_success "Prerequisites OK (erlang $OTP_VERSION, elixir $ELIXIR_VERSION)"

# ─── Step 1: Update system ────────────────────────────────────────────────────
log_info "Updating system packages..."
sudo apt-get update -qq
sudo apt-get upgrade -y -qq
log_success "System packages updated"

# ─── Step 2: Install system dependencies ─────────────────────────────────────
log_info "Installing system dependencies..."

APT_PACKAGES=(
    build-essential curl git wget
    nginx certbot python3-certbot-nginx
    supervisor postgresql-client sqlite3
    libssl-dev libreadline-dev zlib1g-dev
    autoconf automake libtool pkg-config
    nodejs npm
)

MISSING_APT=()
for pkg in "${APT_PACKAGES[@]}"; do
    if ! dpkg -s "$pkg" &>/dev/null; then
        MISSING_APT+=("$pkg")
    fi
done

if [ ${#MISSING_APT[@]} -eq 0 ]; then
    log_skip "System dependencies"
else
    sudo apt-get install -y -qq "${MISSING_APT[@]}"
    log_success "System dependencies installed: ${MISSING_APT[*]}"
fi

# ─── Step 3: Create application user ─────────────────────────────────────────
log_info "Checking application user..."
if id "$APP_USER" &>/dev/null; then
    log_skip "User $APP_USER"
else
    sudo useradd -m -s /bin/bash "$APP_USER"
    sudo usermod -aG sudo "$APP_USER"
    log_success "User $APP_USER created"
fi

# ─── Step 4: Create project directory ────────────────────────────────────────
log_info "Setting up project directory..."
sudo mkdir -p "$PROJECT_DIR"/{data,releases/backup,scripts,logs}
sudo chown -R "$APP_USER:$APP_GROUP" "$PROJECT_DIR"
sudo chmod 755 "$PROJECT_DIR"
log_success "Project directory ready at $PROJECT_DIR"

# ─── Step 5: Create environment file template ────────────────────────────────
ENV_TEMPLATE="/etc/elixir4vet/.env.prod.template"
log_info "Checking environment template..."
if [ -f "$ENV_TEMPLATE" ]; then
    log_skip "Environment template"
else
    sudo mkdir -p /etc/elixir4vet
    sudo tee "$ENV_TEMPLATE" > /dev/null << 'EOF'
# Elixir4vet Production Environment Variables

PHX_SERVER=true
PHX_HOST=vetvision.uz
PORT=4000

DATABASE_PATH=/opt/elixir4vet/data/elixir4vet_prod.db
POOL_SIZE=10

SECRET_KEY_BASE=REPLACE_WITH_OUTPUT_OF_mix_phx_gen_secret

MAIL_FROM=noreply@vetvision.uz

LOG_LEVEL=info
MIX_ENV=prod
EOF
    sudo chown "root:$APP_GROUP" "$ENV_TEMPLATE"
    sudo chmod 640 "$ENV_TEMPLATE"
    log_success "Environment template created at $ENV_TEMPLATE"
    log_warning "Edit $ENV_TEMPLATE and save as /etc/elixir4vet/.env.prod"
fi

# ─── Step 6: Set up systemd service ──────────────────────────────────────────
log_info "Checking systemd service..."
if systemctl list-unit-files 2>/dev/null | grep -q "elixir4vet.service"; then
    log_skip "Systemd service"
else
    if [ -f "$PROJECT_DIR/systemd/elixir4vet.service" ]; then
        cp "$PROJECT_DIR/systemd/elixir4vet.service" /etc/systemd/system/
        systemctl daemon-reload
        systemctl enable elixir4vet
        log_success "Systemd service configured"
    else
        log_warning "systemd/elixir4vet.service not found — skipping"
    fi
fi

# Systemd env override
OVERRIDE_DIR="/etc/systemd/system/elixir4vet.service.d"
if [ ! -f "$OVERRIDE_DIR/env.conf" ]; then
    sudo mkdir -p "$OVERRIDE_DIR"
    sudo tee "$OVERRIDE_DIR/env.conf" > /dev/null << 'EOF'
[Service]
EnvironmentFile=/etc/elixir4vet/.env.prod
EOF
    sudo systemctl daemon-reload
    log_success "Systemd environment override created"
fi

# ─── Step 7: Configure Nginx ──────────────────────────────────────────────────
log_info "Checking Nginx configuration..."
if [ -f "/etc/nginx/sites-enabled/elixir4vet" ]; then
    log_skip "Nginx config"
else
    if [ -f "$PROJECT_DIR/nginx.conf" ]; then
        cp "$PROJECT_DIR/nginx.conf" /etc/nginx/sites-available/elixir4vet
        ln -sf /etc/nginx/sites-available/elixir4vet /etc/nginx/sites-enabled/
        rm -f /etc/nginx/sites-enabled/default
        nginx -t && systemctl restart nginx
        log_success "Nginx configured"
    else
        log_warning "nginx.conf not found in $PROJECT_DIR — skipping"
    fi
fi

# ─── Step 8: Set up log rotation ─────────────────────────────────────────────
LOGROTATE_CONF="/etc/logrotate.d/elixir4vet"
log_info "Checking log rotation..."
if [ -f "$LOGROTATE_CONF" ]; then
    log_skip "Log rotation"
else
    sudo tee "$LOGROTATE_CONF" > /dev/null << 'EOF'
/opt/elixir4vet/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 elixir4vet elixir4vet
    sharedscripts
    postrotate
        systemctl reload elixir4vet > /dev/null 2>&1 || true
    endscript
}
EOF
    log_success "Log rotation configured"
fi

# ─── Step 9: Set up deployment script ────────────────────────────────────────
log_info "Checking deployment script..."
DEPLOY_DEST="/opt/elixir4vet/scripts/deploy.sh"
if [ -f "$DEPLOY_DEST" ]; then
    log_skip "Deployment script"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$SCRIPT_DIR/deploy.sh" ]; then
        cp "$SCRIPT_DIR/deploy.sh" "$DEPLOY_DEST"
        sudo chmod +x "$DEPLOY_DEST"
        sudo chown "root:$APP_GROUP" "$DEPLOY_DEST"
        log_success "Deployment script installed"
    else
        log_warning "deploy.sh not found — skipping"
    fi
fi

# ─── Step 10: Sudoers for CI/CD ──────────────────────────────────────────────
SUDOERS_FILE="/etc/sudoers.d/elixir4vet"
log_info "Checking sudoers configuration..."
if [ -f "$SUDOERS_FILE" ]; then
    log_skip "Sudoers config"
else
    sudo tee "$SUDOERS_FILE" > /dev/null << EOF
$APP_USER ALL=(ALL) NOPASSWD: /opt/elixir4vet/scripts/deploy.sh
$APP_USER ALL=(ALL) NOPASSWD: /bin/systemctl start elixir4vet
$APP_USER ALL=(ALL) NOPASSWD: /bin/systemctl stop elixir4vet
$APP_USER ALL=(ALL) NOPASSWD: /bin/systemctl restart elixir4vet
$APP_USER ALL=(ALL) NOPASSWD: /bin/systemctl status elixir4vet
EOF
    sudo chmod 440 "$SUDOERS_FILE"
    log_success "Sudoers configuration created"
fi

# ─── Done ─────────────────────────────────────────────────────────────────────
echo ""
log_success "Server setup completed!"
echo ""
log_warning "NEXT STEPS:"
log_warning "1. Edit $ENV_TEMPLATE with your configuration"
log_warning "2. Copy to /etc/elixir4vet/.env.prod: cp $ENV_TEMPLATE /etc/elixir4vet/.env.prod"
log_warning "3. Set correct permissions: chmod 640 /etc/elixir4vet/.env.prod"
log_warning "4. Generate SECRET_KEY_BASE: mix phx.gen.secret"
log_warning "5. Set up SSL: certbot certonly --nginx -d vetvision.uz"
log_warning "6. Clone repo: git clone <repo-url> $PROJECT_DIR"
log_warning "7. Run deploy: /opt/elixir4vet/scripts/deploy.sh"
