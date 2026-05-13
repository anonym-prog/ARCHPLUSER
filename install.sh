#!/usr/bin/env bash
# ARCHPULSE - Main Installer for Arch Linux / BlackArch

set -e

# Source colors
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"

# Trap
trap 'echo -e "\n${R}[${CROSS}] Installation interrupted!${N}"; exit 1' SIGINT SIGTERM

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

# ============================================
# BANNER
# ============================================
clear
cat "${SCRIPT_DIR}/.banner.txt" 2>/dev/null || true
echo ""
header "ARCHPULSE INSTALLER v2.0"

# Check Arch
if ! grep -qi "arch" /etc/os-release 2>/dev/null; then
    warning "This installer is designed for Arch Linux-based systems"
    if ! confirm "Continue anyway?"; then
        exit 1
    fi
fi

# ============================================
# SYSTEM UPDATE
# ============================================
header "UPDATING SYSTEM"
info "Running system update..."
$SUDO pacman -Syu --noconfirm
success "System updated!"

# ============================================
# ADD BLACKARCH REPO
# ============================================
header "BLACKARCH REPOSITORY"

if ! pacman -Sl blackarch 2>/dev/null | grep -q .; then
    info "Adding BlackArch repository..."
    curl -s https://blackarch.org/strap.sh | $SUDO bash
    $SUDO pacman -Syyu --noconfirm
    success "BlackArch repository added!"
else
    info "BlackArch repository already configured"
fi

# ============================================
# INSTALL BASE DEPENDENCIES
# ============================================
header "INSTALLING BASE DEPENDENCIES"

BASE_DEPS=(
    git curl wget base-devel
    python python-pip python2
    go rust nodejs npm
    perl ruby php
    jq unzip zip tar
    tmux screen vim nano
    toilet figlet lolcat
)

info "Installing ${#BASE_DEPS[@]} base packages..."
$SUDO pacman -S --noconfirm --needed "${BASE_DEPS[@]}"
success "Base dependencies installed!"

# Install AUR helper if not present
if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd "$SCRIPT_DIR"
    success "yay installed!"
fi

# ============================================
# INSTALL TOOLS BY CATEGORY
# ============================================
install_category() {
    local name="$1"
    local pkgs=("${@:2}")
    header "INSTALLING ${name} TOOLS"
    
    local total=${#pkgs[@]}
    local count=0
    
    for pkg in "${pkgs[@]}"; do
        count=$((count + 1))
        echo -ne "\r${Y}[${count}/${total}]${N} Installing ${G}${pkg}${N}...         "
        if pacman -Qi "$pkg" &>/dev/null; then
            echo -ne "\r${G}[${CHECK}]${N} ${pkg} ${D}already installed${N}          \n"
        else
            if $SUDO pacman -S --noconfirm --needed "$pkg" 2>/dev/null; then
                echo -ne "\r${G}[${CHECK}]${N} ${pkg} installed!          \n"
            else
                yay -S --noconfirm "$pkg" 2>/dev/null && \
                    echo -ne "\r${G}[${CHECK}]${N} ${pkg} installed!          \n" || \
                    echo -ne "\r${Y}[${WARN}]${N} ${pkg} ${Y}failed${N}           \n"
            fi
        fi
    done
    success "${name} tools installed!"
}

# --- RECON TOOLS ---
install_category "RECON" \
    nmap masscan \
    metasploit amass \
    subfinder httpx \
    nuclei dnsx naabu \
    findomain assetfinder \
    gospider hakrawler \
    waybackpy

# --- SCANNER TOOLS ---
install_category "SCANNER" \
    nikto whatweb \
    wfuzz gobuster \
    dirsearch skipfish \
    wapiti arachni \
    openvas

# --- EXPLOIT TOOLS ---
install_category "EXPLOIT" \
    metasploit sqlmap \
    commix beef-project \
    routersploit \
    exploitdb \
    xsstrike shellnoob

# --- ENUMERATION TOOLS ---
install_category "ENUMERATION" \
    enum4linux smbclient \
    snmp++ dnsenum \
    dnsrecon ldap-server \
    nbtscan

# --- PASSWORD TOOLS ---
install_category "PASSWORD" \
    hydra john hashcat \
    medusa crunch \
    cewl

# --- BETTERCAP ---
install_category "BETTERCAP" \
    bettercap

# --- BURPSUITE ---
install_category "BURPSUITE" \
    burpsuite

# --- SQL TOOLS ---
install_category "SQL" \
    sqlmap sqlninja \
    nosqlmap bbqsql

# ============================================
# INSTALL PYTHON TOOLS
# ============================================
header "INSTALLING PYTHON PACKAGES"

PYTHON_PKGS=(
    requests beautifulsoup4
    scapy colorama termcolor
    pyfiglet python-nmap
    shodan censys
    paramiko pwn pwntools
    flask dnspython
    ipwhois phonenumbers folium
    mechanize httpx websocket-client
    impacket
)

for pkg in "${PYTHON_PKGS[@]}"; do
    pip install "$pkg" 2>/dev/null >/dev/null || true
done
success "Python packages installed!"

# ============================================
# INSTALL GO TOOLS
# ============================================
header "INSTALLING GO TOOLS"

export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

GO_TOOLS=(
    "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
    "github.com/projectdiscovery/httpx/cmd/httpx@latest"
    "github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest"
    "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
    "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
    "github.com/tomnomnom/waybackurls@latest"
    "github.com/lc/gau/v2/cmd/gau@latest"
    "github.com/tomnomnom/assetfinder@latest"
    "github.com/OJ/gobuster/v3@latest"
    "github.com/ffuf/ffuf@latest"
    "github.com/jaeles-project/gospider@latest"
    "github.com/hakluke/hakrawler@latest"
)

for tool in "${GO_TOOLS[@]}"; do
    name="$(basename "$tool" | sed 's/@latest//')"
    if ! command -v "$name" &>/dev/null; then
        echo -ne "${C}[${ARROW}]${N} Installing ${Y}${name}${N}... "
        go install -v "$tool" 2>/dev/null >/dev/null && \
            echo -e "${G}[${CHECK}]${N}" || \
            echo -e "${Y}[${WARN}]${N} ${D}failed${N}"
    fi
done
success "Go tools installed!"

# ============================================
# SETUP DIRECTORY STRUCTURE
# ============================================
header "SETTING UP DIRECTORIES"

ARCHPULSE_DIR="$HOME/archpulse"
mkdir -p "$ARCHPULSE_DIR"/{reports,wordlists,logs,configs}

# Copy configs
cp -r "${SCRIPT_DIR}/configs/"* "$ARCHPULSE_DIR/configs/" 2>/dev/null || true
success "Directories created at $ARCHPULSE_DIR"

# ============================================
# DOWNLOAD WORDLISTS
# ============================================
header "DOWNLOADING WORDLISTS"

WORDLIST_DIR="$ARCHPULSE_DIR/wordlists"

if [ ! -f "$WORDLIST_DIR/rockyou.txt" ]; then
    info "Downloading rockyou wordlist..."
    curl -L -o /tmp/rockyou.txt.gz https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt 2>/dev/null
    gunzip -f /tmp/rockyou.txt.gz 2>/dev/null
    mv /tmp/rockyou.txt "$WORDLIST_DIR/" 2>/dev/null
    success "rockyou.txt downloaded!"
else
    info "rockyou.txt already exists"
fi

# Common wordlists
for wl in "common.txt" "directory-list-2.3-medium.txt" "raft-large-words.txt"; do
    if [ ! -f "$WORDLIST_DIR/$wl" ]; then
        wget -q "https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/Web-Content/$wl" -O "$WORDLIST_DIR/$wl" 2>/dev/null &
    fi
done
wait
success "Wordlists downloaded!"

# ============================================
# INSTALL LAUNCHER
# ============================================
header "INSTALLING LAUNCHER"

# Copy archpulse.sh to bin
$SUDO cp "${SCRIPT_DIR}/archpulse.sh" /usr/local/bin/archpulse
$SUDO chmod +x /usr/local/bin/archpulse
success "Launcher installed! Type 'archpulse' to start"

# ============================================
# ADD TO PATH & ALIASES
# ============================================
header "CONFIGURING SHELL"

BASHRC="$HOME/.bashrc"
ZSH="$HOME/.zshrc"

# Add GOPATH
if ! grep -q "ARCHPULSE" "$BASHRC" 2>/dev/null; then
    cat >> "$BASHRC" << 'EOF'

# ===== ARCHPULSE CONFIGURATION =====
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/archpulse"

alias arp='archpulse'
alias arp-recon='archpulse recon'
alias arp-scan='archpulse scanner'
alias arp-exploit='archpulse exploit'
alias arp-enum='archpulse enum'
alias arp-crack='archpulse password'
alias arp-mitm='archpulse bettercap'
alias arp-burp='archpulse burp'
alias arp-sql='archpulse sql'
alias arp-quick='archpulse quick-scan'
alias arp-web='archpulse web-scan'

# Interactive shell prompt customization
export PS1='\[\e[0;31m\][\[\e[1;33m\]ARCHPULSE\[\e[0;31m\]\[\e[0;37m\]@\[\e[0;32m\]\u\[\e[0;37m\]:\[\e[0;34m\]\w\[\e[0;31m\]]\[\e[1;33m\]➤\[\e[0m\] '
EOF
    success "Aliases and PATH configured in .bashrc"
fi

# Source if zsh exists
if [ -f "$ZSH" ]; then
    if ! grep -q "ARCHPULSE" "$ZSH" 2>/dev/null; then
        cat >> "$ZSH" << 'EOF'

# ===== ARCHPULSE CONFIGURATION =====
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$HOME/archpulse"

alias arp='archpulse'
alias arp-recon='archpulse recon'
alias arp-scan='archpulse scanner'
alias arp-exploit='archpulse exploit'
alias arp-enum='archpulse enum'
alias arp-crack='archpulse password'
alias arp-mitm='archpulse bettercap'
alias arp-burp='archpulse burp'
alias arp-sql='archpulse sql'
EOF
        success "Aliases and PATH configured in .zshrc"
    fi
fi

# ============================================
# VERIFY INSTALLATION
# ============================================
header "VERIFYING INSTALLATION"

tools_to_check=(
    "nmap" "masscan" "nikto" "whatweb" "wfuzz" "gobuster"
    "sqlmap" "hydra" "john" "hashcat" "metasploit"
    "bettercap" "burpsuite" "dnsenum" "dnsrecon"
    "enum4linux" "smbclient" "gospider" "hakrawler"
    "commix" "crunch" "cewl" "dirsearch"
)

echo ""
echo -e "${C}┌─────────────┬──────────┐${N}"
echo -e "${C}│${N} ${Y}TOOL${N}           ${C}│${N} ${Y}STATUS${N}    ${C}│${N}"
echo -e "${C}├─────────────┼──────────┤${N}"

for tool in "${tools_to_check[@]}"; do
    if command -v "$tool" &>/dev/null || pacman -Qi "$tool" &>/dev/null; then
        printf "│ %-13s │ ${G}%-8s${N} │\n" "$tool" "✓ OK"
    else
        printf "│ %-13s │ ${Y}%-8s${N} │\n" "$tool" "✗ MISSING"
    fi
done

echo -e "${C}└─────────────┴──────────┘${N}"
echo ""

# ============================================
# COMPLETION BANNER
# ============================================
clear
echo -e "${R}"
echo "██████████████████████████████████████████████████████████████████"
echo "██                                                              ██"
echo "██            █████╗ ██████╗  ██████╗██╗  ██╗██████╗            ██"
echo "██           ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗           ██"
echo "██           ███████║██████╔╝██║     ███████║██████╔╝           ██"
echo "██           ██╔══██║██╔══██╗██║     ██╔══██║██╔══██╗           ██"
echo "██           ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝           ██"
echo "██           ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝            ██"
echo "██                                                              ██"
echo "██              ╔══════════════════════════════════╗             ██"
echo "██              ║   INSTALLATION COMPLETE! 🎯    ║             ██"
echo "██              ╚══════════════════════════════════╝             ██"
echo "██                                                              ██"
echo "██  ${G}⚡ LAUNCH${N}                        ${R}⚡ COMMANDS${N}               ██"
echo "██  ${G}━━━━━━━━━${N}                        ${R}━━━━━━━━━━${N}              ██"
echo "██  ${Y}archpulse${N}      - Main menu       ${Y}arp-quick <ip>${N}         ██"
echo "██  ${Y}arp-recon${N}      - Recon tools      ${Y}arp-web <url>${N}         ██"
echo "██  ${Y}arp-scan${N}       - Scanner tools    ${Y}arp-mitm <iface>${N}      ██"
echo "██  ${Y}arp-exploit${N}    - Exploit tools    ${Y}arp-burp${N}              ██"
echo "██  ${Y}arp-enum${N}       - Enumeration tools ${Y}arp-crack <hashfile>${N} ██"
echo "██                                                              ██"
echo "██  ${G}📁 Wordlists:${N} ~/archpulse/wordlists/                    ██"
echo "██  ${G}📁 Reports:${N}   ~/archpulse/reports/                       ██"
echo "██  ${G}📁 Configs:${N}   ~/archpulse/configs/                       ██"
echo "██                                                              ██"
echo "██  ${R}☠ AUTHORIZED PENTESTING ONLY ${N}                         ██"
echo "██                                                              ██"
echo "██████████████████████████████████████████████████████████████████"
echo -e "${N}"
echo ""
echo -e "  ${Y}Reboot terminal or run:${N} ${G}source ~/.bashrc${N}"
echo ""

# Source bashrc
source ~/.bashrc 2>/dev/null || true

exit 0
