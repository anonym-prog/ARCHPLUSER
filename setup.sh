#!/usr/bin/env bash
# ARCHPULSE - Quick Setup (One-liner friendly)

set -e

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║        ⚡ ARCHPULSE - Quick Setup for ArchLinux        ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Clone
if [ ! -d "ARCHPULSE" ]; then
    echo "[→] Cloning ARCHPULSE..."
    git clone https://github.com/[username]/ARCHPULSE.git
    cd ARCHPULSE
else
    cd ARCHPULSE
    echo "[✓] Already cloned"
fi

# Permissions
chmod +x install.sh colors.sh archpulse.sh modules/*.sh scripts/*.sh 2>/dev/null

# Run installer
./install.sh
