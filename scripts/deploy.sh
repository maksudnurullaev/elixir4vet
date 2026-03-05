#!/bin/bash

# Deployment script for Elixir4vet
# This script should be run on the production server

set -e

# Configuration
PROJECT_DIR="/opt/elixir4vet"
USER="elixir4vet"
GROUP="elixir4vet"
SERVICE_NAME="elixir4vet"

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

log_info "Starting deployment..."

# Step 1: Stop the service
log_info "Stopping service..."
systemctl stop $SERVICE_NAME || log_warning "Service was not running"
sleep 2
log_success "Service stopped"

# Step 2: Backup current release
if [ -d "$PROJECT_DIR/bin" ]; then
    BACKUP_DIR="$PROJECT_DIR/releases/backup-$(date +%Y%m%d-%H%M%S)"
    log_info "Creating backup at $BACKUP_DIR"
    mkdir -p $BACKUP_DIR
    cp -r $PROJECT_DIR/bin $BACKUP_DIR/ || true
    cp -r $PROJECT_DIR/_build $BACKUP_DIR/ || true
    log_success "Backup created"
fi

# Step 3: Pull latest code
log_info "Pulling latest code..."
cd $PROJECT_DIR
git fetch origin
git checkout main
git pull origin main
log_success "Code updated"

# Step 4: Load environment variables
log_info "Loading environment variables..."
if [ ! -f "/etc/elixir4vet/.env.prod" ]; then
    log_error "Environment file not found: /etc/elixir4vet/.env.prod"
fi
source /etc/elixir4vet/.env.prod
log_success "Environment variables loaded"

# Step 5: Install dependencies
log_info "Installing dependencies..."
su - $USER -c "cd $PROJECT_DIR && mix deps.get --only prod" || log_error "Failed to install dependencies"
log_success "Dependencies installed"

# Step 6: Compile assets
log_info "Compiling assets..."
su - $USER -c "cd $PROJECT_DIR && mix assets.deploy" || log_error "Failed to compile assets"
log_success "Assets compiled"

# Step 7: Build release
log_info "Building release..."
su - $USER -c "cd $PROJECT_DIR && MIX_ENV=prod mix release" || log_error "Failed to build release"
log_success "Release built"

# Step 8: Run migrations
log_info "Running database migrations..."
su - $USER -c "cd $PROJECT_DIR && MIX_ENV=prod _build/prod/rel/elixir4vet/bin/elixir4vet eval 'Elixir4vet.Release.migrate()'" || log_error "Failed to run migrations"
log_success "Migrations completed"

# Step 9: Start the service
log_info "Starting service..."
systemctl start $SERVICE_NAME || log_error "Failed to start service"
sleep 3
log_success "Service started"

# Step 10: Check service status
log_info "Checking service status..."
if systemctl is-active --quiet $SERVICE_NAME; then
    log_success "Service is running"
else
    log_error "Service failed to start. Check logs: journalctl -u $SERVICE_NAME -n 50"
fi

# Step 11: Health check
log_info "Running health check..."
max_attempts=10
attempt=1
while [ $attempt -le $max_attempts ]; do
    if curl -sf http://localhost:4000/health > /dev/null 2>&1; then
        log_success "Health check passed"
        break
    fi
    
    if [ $attempt -eq $max_attempts ]; then
        log_error "Health check failed after $max_attempts attempts"
    fi
    
    log_warning "Health check attempt $attempt/$max_attempts failed, retrying in 2 seconds..."
    sleep 2
    attempt=$((attempt + 1))
done

log_success "Deployment completed successfully!"
log_info "Deployment time: $(date)"
