#!/usr/bin/env bash
# setup-linux.sh
# Run inside WSL2 Ubuntu after first login
# Installs dependencies and OpenClaw

set -e

CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

header() { echo -e "\n${CYAN}========================================${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}========================================${NC}\n"; }
ok()     { echo -e "${GREEN}✔ $1${NC}"; }
info()   { echo -e "${YELLOW}→ $1${NC}"; }
err()    { echo -e "${RED}✘ $1${NC}"; }

header "Fred Upgrade: Linux Setup"

# ── 1. System update ──────────────────────────────────────────────
info "Updating package lists..."
sudo apt-get update -qq

info "Installing base dependencies (git, curl, python3, pip)..."
sudo apt-get install -y -qq git curl python3 python3-pip python3-venv unzip
ok "Base dependencies installed"

# ── 2. Node.js (required by OpenClaw) ────────────────────────────
if command -v node &>/dev/null; then
    ok "Node.js already installed: $(node --version)"
else
    info "Installing Node.js (LTS via nvm)..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    nvm install --lts
    nvm use --lts
    ok "Node.js installed: $(node --version)"
fi

# ── 3. OpenClaw ───────────────────────────────────────────────────
header "Installing OpenClaw"

if command -v openclaw &>/dev/null; then
    ok "OpenClaw already installed: $(openclaw --version 2>/dev/null || echo 'version unknown')"
else
    info "Installing OpenClaw via npm..."
    # Ensure nvm node is in PATH
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
    npm install -g openclaw
    ok "OpenClaw installed"
fi

# ── 4. Shell config ───────────────────────────────────────────────
info "Ensuring NVM and OpenClaw are in PATH on future logins..."
BASHRC="$HOME/.bashrc"
if ! grep -q "NVM_DIR" "$BASHRC"; then
    cat >> "$BASHRC" << 'EOF'

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
EOF
fi
ok "Shell config updated"

# ── Done ─────────────────────────────────────────────────────────
header "Setup Complete!"
echo -e "OpenClaw is installed. Next steps:"
echo ""
echo -e "  ${CYAN}1. Run OpenClaw:${NC}"
echo -e "     openclaw start"
echo ""
echo -e "  ${CYAN}2. If you had OpenClaw on Windows and want to migrate:${NC}"
echo -e "     curl -fsSL https://raw.githubusercontent.com/buster-chachi/fred-upgrade/main/migrate.sh | bash"
echo ""
echo -e "  ${CYAN}3. Otherwise, start fresh:${NC}"
echo -e "     openclaw setup"
echo ""
