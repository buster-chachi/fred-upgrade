# Fred Upgrade 🐧

Migrate from OpenClaw on Windows to OpenClaw on WSL2 (Ubuntu).

## What This Does

1. Installs WSL2 + Ubuntu on Windows
2. Walks you through first-time Linux setup
3. Installs OpenClaw on Linux
4. Migrates your existing OpenClaw workspace, memory, and skills from Windows

## Prerequisites

- Windows 10 (version 2004+) or Windows 11
- Administrator access
- Your existing OpenClaw install on Windows (optional — migration step is skippable)

## Steps

### Step 1 — Install WSL2 (Windows, run as Administrator)

Open **PowerShell as Administrator** and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
irm https://raw.githubusercontent.com/buster-chachi/fred-upgrade/main/install-wsl.ps1 | iex
```

This will:
- Enable WSL2
- Install Ubuntu
- Reboot if required
- On next login, Ubuntu will finish setting up automatically

### Step 2 — Configure Linux + Install OpenClaw (inside Ubuntu)

Once Ubuntu is running, paste this:

```bash
curl -fsSL https://raw.githubusercontent.com/buster-chachi/fred-upgrade/main/setup-linux.sh | bash
```

### Step 3 — Migrate from Windows OpenClaw (optional)

If you had OpenClaw configured on Windows, run this to carry over your workspace:

```bash
curl -fsSL https://raw.githubusercontent.com/buster-chachi/fred-upgrade/main/migrate.sh | bash
```

> **Your Windows OpenClaw install is never touched.** Migration only copies files — nothing is moved, deleted, or modified on the Windows side. Run both versions side by side until you're satisfied, then uninstall Windows OpenClaw whenever you're ready.

## What Gets Migrated

| Item | Migrated? | Notes |
|------|-----------|-------|
| Workspace files (MEMORY.md, SOUL.md, etc.) | ✅ | Copied from Windows |
| Skills | ✅ | Copied + reinstalled via openclaw |
| `.env` config | ✅ | Copied |
| Windows-only integrations (iMessage, Apple Notes) | ❌ | macOS only — skipped |

## Design Notes

**Why Node.js 24?** Node 24 is the current LTS release (as of October 2025) and satisfies OpenClaw's `>=22.16.0` requirement.

**Why not a single PowerShell script?** Once WSL2 is running, you're in Linux — that's the environment OpenClaw lives in. Keeping the Linux setup in bash means the scripts work correctly and get Fred comfortable with the tools he'll use going forward. The handoff from PowerShell → bash is intentional.

## Troubleshooting

**WSL won't install** — make sure virtualization is enabled in BIOS and you're running PowerShell as Administrator.

**Can't find Windows files** — your Windows drive is at `/mnt/c` inside WSL. Check `ls /mnt/c/Users/` to find your Windows username.

**OpenClaw not found after install** — run `source ~/.bashrc` or open a new terminal tab.
