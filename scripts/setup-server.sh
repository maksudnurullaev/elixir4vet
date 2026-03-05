#!/bin/bash

# Server setup script for Elixir4vet
# Run this once on the production server to set everything up

set -e

# Configuration
PROJECT_DIR="/opt/elixir4vet"
USER="elixir4vet"
GROUP="elixir4vet"
OTP_VERSION="28.1"
ELIXIR_VERSION="1.16.5"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    exit 1
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    log_error "This script must be run as root"
fi

log_info "Starting server setup..."

# Step 1: Update system
log_info "Updating system packages..."
apt-get update
apt-get upgrade -y
log_success "System packages updated"

# Step 2: Install system dependencies
log_info "Installing system dependencies..."
apt-get install -y \
    build-essential \
    curl \
    git \
    wget \
    nginx \
    certbot \
    python3-certbot-nginx \
    supervisor \
    postgresql-client \
    sqlite3 \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    autoconf \
    automake \
    libtool \
    pkg-config \
    npm \
    nodejs
log_success "System dependencies installed"

# Step 3: Install Erlang and Elixir using asdf
log_info "Installing asdf..."
if ! command -v asdf &> /dev/null; then
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
    echo '. "$HOME/.asdf/asdf.sh"' >> /root/.bashrc
    echo '. "$HOME/.asdf/completions/asdf.bash"' >> /root/.bashrc
    source /root/.bashrc
fi
log_success "asdf installed"

log_info "Installing Erlang $OTP_VERSION..."
asdf plugin add erlang || true
asdf install erlang $OTP_VERSION
asdf global erlang $OTP_VERSION
log_success "Erlang $OTP_VERSION installed"

log_info "Installing Elixir $ELIXIR_VERSION..."
asdf plugin add elixir || true
asdf install elixir $ELIXIR_VERSION
asdf global elixir $ELIXIR_VERSION
log_success "Elixir $ELIXIR_VERSION installed"

# Step 4: Create application user
log_info "Creating application user..."
if id "$USER" &>/dev/null; then
    log_warning "User $USER already exists"
else
    useradd -m -s /bin/bash $USER
    usermod -aG sudo $USER
    log_success "User $USER created"
fi

# Step 5: Create project directory
log_info "Creating project directory..."
mkdir -p $PROJECT_DIR
mkdir -p $PROJECT_DIR/data
mkdir -p $PROJECT_DIR/releases/backup
chown -R $USER:$GROUP $PROJECT_DIR
chmod 755 $PROJECT_DIR
log_success "Project directory created"

# Step 6: Create environment file template
log_info "Creating environment file template..."
mkdir -p /etc/elixir4vet
cat > /etc/elixir4vet/.env.prod.template << 'EOF'
# Elixir4vet Production Environment Variables

# Phoenix configuration
PHX_SERVER=true
PHX_HOST=elixir4vet.example.com
PORT=4000

# Database
DATABASE_PATH=/opt/elixir4vet/data/elixir4vet_prod.db
POOL_SIZE=10

# Security
SECRET_KEY_BASE=$(mix phx.gen.secret)

# Email configuration (Swoosh)
MAIL_FROM=noreply@elixir4vet.example.com

# Logging
LOG_LEVEL=info

# Application configuration
MIX_ENV=prod
EOF
chown root:$GROUP /etc/elixir4vet/.env.prod.template
chmod 640 /etc/elixir4vet/.env.prod.template
log_success "Environment template created at /etc/elixir4vet/.env.prod.template"
log_warning "IMPORTANT: Edit /etc/elixir4vet/.env.prod.template and save as /etc/elixir4vet/.env.prod"

# Step 7: Set up systemd service
log_info "Setting up systemd service..."
cp $PROJECT_DIR/systemd/elixir4vet.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable elixir4vet
log_success "Systemd service configured"

# Step 8: Configure Nginx
log_info "Configuring Nginx..."
cp $PROJECT_DIR/nginx.conf /etc/nginx/sites-available/elixir4vet
ln -sf /etc/nginx/sites-available/elixir4vet /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
log_success "Nginx configured"

# Step 9: Set up SSL with Let's Encrypt (optional)
log_warning "To set up SSL, run: certbot certonly --nginx -d elixir4vet.example.com"
log_warning "Then update nginx.conf with SSL certificate paths"

# Step 10: Create systemd override for environment variables
log_info "Creating systemd environment override..."
mkdir -p /etc/systemd/system/elixir4vet.service.d
cat > /etc/systemd/system/elixir4vet.service.d/env.conf << 'EOF'
[Service]
EnvironmentFile=/etc/elixir4vet/.env.prod
EOF
systemctl daemon-reload
log_success "Systemd override created"

# Step 11: Set up log rotation
log_info "Setting up log rotation..."
cat > /etc/logrotate.d/elixir4vet << 'EOF'
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

# Step 12: Set up deployment permissions
log_info "Setting up deployment permissions..."
mkdir -p /opt/elixir4vet/scripts
cp $PROJECT_DIR/scripts/deploy.sh /opt/elixir4vet/scripts/
chmod +x /opt/elixir4vet/scripts/deploy.sh
chown root:$GROUP /opt/elixir4vet/scripts/deploy.sh
chmod u+s /opt/elixir4vet/scripts/deploy.sh # Allow sudo without password for specific script
log_success "Deployment scripts configured"

# Step 13: Create sudoers configuration for CI/CD
log_info "Configuring sudoers for CI/CD..."
cat >> /etc/sudoers.d/elixir4vet << EOF
$USER ALL=(ALL) NOPASSWD: /opt/elixir4vet/scripts/deploy.sh
$USER ALL=(ALL) NOPASSWD: /bin/systemctl start elixir4vet
$USER ALL=(ALL) NOPASSWD: /bin/systemctl stop elixir4vet
$USER ALL=(ALL) NOPASSWD: /bin/systemctl restart elixir4vet
$USER ALL=(ALL) NOPASSWD: /bin/systemctl status elixir4vet
EOF
chmod 440 /etc/sudoers.d/elixir4vet
log_success "Sudoers configuration created"

log_success "Server setup completed!"
log_info ""
log_warning "NEXT STEPS:"
log_warning "1. Edit /etc/elixir4vet/.env.prod.template with your configuration"
log_warning "2. Copy to /etc/elixir4vet/.env.prod: cp /etc/elixir4vet/.env.prod.template /etc/elixir4vet/.env.prod"
log_warning "3. Change permissions: chmod 640 /etc/elixir4vet/.env.prod"
log_warning "4. Set up SSL with: certbot certonly --nginx -d elixir4vet.example.com"
log_warning "5. Update nginx.conf with your domain and SSL paths"
log_warning "6. Run initial clone of repo: sudo -u $USER git clone <repo-url> $PROJECT_DIR"
log_warning "7. Run deployment: sudo /opt/elixir4vet/scripts/deploy.sh"
