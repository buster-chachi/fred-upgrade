#!/usr/bin/env bash
# migrate.sh
# Migrates OpenClaw workspace from Windows to WSL2 Linux
# Run inside WSL2 after setup-linux.sh completes

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
ask()    { echo -e "${CYAN}? $1${NC}"; }

header "Fred Upgrade: Windows → Linux Migration"

LINUX_OPENCLAW="$HOME/.openclaw"
LINUX_WORKSPACE="$LINUX_OPENCLAW/workspace"

# ── 1. Find Windows username ──────────────────────────────────────
WINDOWS_USERS=$(ls /mnt/c/Users/ 2>/dev/null | grep -v -E "^(Public|Default|All Users|desktop.ini)$" || true)

if [ -z "$WINDOWS_USERS" ]; then
    err "Could not find Windows user directories at /mnt/c/Users/"
    err "Make sure your Windows drive is mounted. Try: ls /mnt/c/Users/"
    exit 1
fi

USER_COUNT=$(echo "$WINDOWS_USERS" | wc -l)
if [ "$USER_COUNT" -eq 1 ]; then
    WIN_USER="$WINDOWS_USERS"
    ok "Detected Windows user: $WIN_USER"
else
    echo "Multiple Windows users found:"
    echo "$WINDOWS_USERS" | nl
    ask "Enter your Windows username:"
    read -r WIN_USER
fi

WIN_OPENCLAW="/mnt/c/Users/$WIN_USER/.openclaw"

if [ ! -d "$WIN_OPENCLAW" ]; then
    err "No OpenClaw install found at $WIN_OPENCLAW"
    err "Either OpenClaw wasn't installed on Windows, or the path is different."
    ask "Enter the full path to your Windows .openclaw folder (or press Enter to skip migration):"
    read -r WIN_OPENCLAW
    if [ -z "$WIN_OPENCLAW" ] || [ ! -d "$WIN_OPENCLAW" ]; then
        info "Skipping migration. Run 'openclaw setup' to start fresh."
        exit 0
    fi
fi

ok "Found Windows OpenClaw at: $WIN_OPENCLAW"
WIN_WORKSPACE="$WIN_OPENCLAW/workspace"

# ── 2. Backup existing Linux config if any ───────────────────────
if [ -d "$LINUX_OPENCLAW" ] && [ "$(ls -A $LINUX_OPENCLAW)" ]; then
    BACKUP="$HOME/.openclaw-backup-$(date +%Y%m%d%H%M%S)"
    info "Existing Linux OpenClaw config found. Backing up to $BACKUP..."
    cp -r "$LINUX_OPENCLAW" "$BACKUP"
    ok "Backup saved"
fi

mkdir -p "$LINUX_OPENCLAW"

# ── 3. Copy workspace ─────────────────────────────────────────────
if [ -d "$WIN_WORKSPACE" ]; then
    header "Migrating Workspace"
    info "Copying workspace files..."
    rsync -a --exclude='.git' "$WIN_WORKSPACE/" "$LINUX_WORKSPACE/"
    ok "Workspace copied to $LINUX_WORKSPACE"
else
    info "No workspace directory found on Windows — skipping"
fi

# ── 4. Copy .env if present ───────────────────────────────────────
if [ -f "$WIN_OPENCLAW/.env" ]; then
    info "Copying .env config..."
    cp "$WIN_OPENCLAW/.env" "$LINUX_OPENCLAW/.env"
    ok ".env copied"
fi

# ── 5. Skills ─────────────────────────────────────────────────────
SKILLS_DIR="$LINUX_WORKSPACE/skills"
if [ -d "$SKILLS_DIR" ]; then
    header "Reinstalling Skills"
    info "Skills directory found. Attempting to reinstall Linux-compatible versions..."
    SKILL_LIST=$(ls "$SKILLS_DIR" 2>/dev/null | grep -v '\.' || true)
    if [ -n "$SKILL_LIST" ]; then
        echo "Skills found:"
        echo "$SKILL_LIST" | while read -r skill; do
            echo "  - $skill"
        done
        echo ""
        info "Skills have been copied as-is. They are Python/bash-based and should work on Linux."
        info "If any skill has Windows-specific dependencies, reinstall manually from:"
        info "  https://github.com/buster-chachi/openclaw-skills"
    fi
fi

# ── 6. Skip Windows-only integrations ────────────────────────────
header "Skipped (Windows/macOS Only)"
echo "The following integrations are not available on Linux:"
echo "  ✗ iMessage (macOS only)"
echo "  ✗ Apple Notes (macOS only)"
echo "  ✗ Apple Reminders (macOS only)"
echo ""
echo "Everything else (web search, GitHub, coding agents, memory, heartbeat) works on Linux."

# ── Done ─────────────────────────────────────────────────────────
header "Migration Complete!"
echo -e "Your OpenClaw workspace is ready at: ${CYAN}$LINUX_WORKSPACE${NC}"
echo ""
echo "Next step — start OpenClaw:"
echo "  openclaw start"
echo ""
echo "Your agent identity, memory, and skills have been carried over."
echo "You may want to review SOUL.md and USER.md to make sure everything looks right."
echo ""
