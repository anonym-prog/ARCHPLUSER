# Arch Linux base
sudo pacman -Syu
sudo pacman -S --noconfirm git curl wget base-devel

# AUR helper (yay)
git clone https://aur.archlinux.org/yay.git
cd yay && makepkg -si && cd ..

# BlackArch repo (for pentesting tools)
curl -s https://blackarch.org/strap.sh | sudo bash
sudo pacman -Syyu

---

### 2️⃣ **`colors.sh`**

```bash
#!/usr/bin/env bash
# ARCHPULSE - Color Configuration
# Theme: Red • Yellow • Green • Blue • Purple • Cyan

# ANSI Colors
R='\033[1;31m'    # Merah - Exploit/Danger
G='\033[1;32m'    # Hijau - Success/Recon
Y='\033[1;33m'    # Kuning - Warning/Scanner
B='\033[1;34m'    # Biru - Enumeration
P='\033[1;35m'    # Purple - Password/PrivEsc
C='\033[1;36m'    # Cyan - Info
W='\033[1;37m'    # Putih
N='\033[0m'       # Reset
D='\033[2m'       # Dim
BD='\033[1m'       # Bold
UL='\033[4m'       # Underline
BL='\033[5m'       # Blink

# Backgrounds
BG_R='\033[41m'
BG_G='\033[42m'
BG_Y='\033[43m'
BG_B='\033[44m'
BG_P='\033[45m'
BG_C='\033[46m'

# Icons (colored)
CHECK="${G}✓${N}"
CROSS="${R}✗${N}"
WARN="${Y}⚠${N}"
ARROW="${C}→${N}"
BOLT="${Y}⚡${N}"
SKULL="${R}☠${N}"
SHIELD="${G}🛡${N}"
EYE="${C}👁${N}"
FIRE="${R}🔥${N}"
LOCK="${Y}🔒${N}"
GLOBE="${C}🌐${N}"
TARGET="${R}🎯${N}"
GEAR="${G}⚙${N}"
STAR="${Y}★${N}"
KEY="${P}🔑${N}"
NET="${B}🌍${N}"
DB="${G}🗄${N}"
BUG="${R}🐛${N}"

# ============ FUNCTIONS ============

# Header dengan border
header() {
    local title="$1"
    local color="${2:-$R}"
    echo ""
    echo -e "${color}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${color}║${N}  ${Y}${BD}◆${N} ${W}${BD}${title}${N} ${Y}${BD}◆${N}"
    echo -e "${color}╚══════════════════════════════════════════════════════════╝${N}"
    echo ""
}

# Success message
success() {
    echo -e " ${G}[${CHECK}]${N} ${1}"
}

# Error message  
error() {
    echo -e " ${R}[${CROSS}]${N} ${1}"
}

# Warning message
warning() {
    echo -e " ${Y}[${WARN}]${N} ${1}"
}

# Info message
info() {
    echo -e " ${C}[${ARROW}]${N} ${1}"
}

# Section separator
separator() {
    local char="${1:-─}"
    echo -e "${D}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${char}${N}"
}

# Menu item
menu_item() {
    local num="$1"
    local name="$2"
    local desc="$3"
    local color="${4:-$G}"
    echo -e " ${R}[${Y}${num}${R}]${N} ${color}${name}${N} ${D}─${N} ${C}${desc}${N}"
}

# Sub menu item
submenu_item() {
    local num="$1"
    local name="$2"
    local desc="$3"
    echo -e "   ${Y}[${num}]${N} ${G}${name}${N} ${D}─${N} ${C}${desc}${N}"
}

# Tool banner
tool_banner() {
    local name="$1"
    local category="$2"
    local color="${3:-$R}"
    echo ""
    echo -e "${color}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${color}║${N} ${Y}${BOLT}${N} ${W}${BD}${name}${N}"
    echo -e "${color}║${N} ${C}Category:${N} ${Y}${category}${N}"
    echo -e "${color}╚══════════════════════════════════════════════════════════╝${N}"
    echo ""
}

# Progress bar
progress_bar() {
    local current="$1"
    local total="$2"
    local width=50
    local pct=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r${Y}[${N}"
    for ((i=0; i<filled; i++)); do printf "${G}█${N}"; done
    for ((i=0; i<empty; i++)); do printf "${R}░${N}"; done
    printf "${Y}]${N} ${G}%d%%${N} ${D}(%d/%d)${N}" "$pct" "$current" "$total"
}

# Loading spinner
spinner() {
    local pid=$1
    local msg="$2"
    local spin='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i+1) % 4 ))
        printf "\r${Y}[${spin:$i:1}]${N} ${msg} ... "
        sleep 0.1
    done
    printf "\r${G}[${CHECK}]${N} ${msg} ${G}Done!${N}   \n"
}

# Typewriter effect
typewrite() {
    local text="$1"
    local color="${2:-$G}"
    for ((i=0; i<${#text}; i++)); do
        echo -ne "${color}${text:$i:1}${N}"
        sleep 0.02
    done
    echo ""
}

# Confirm prompt
confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local yn
    read -p "$(echo -e ${Y}"[?] ${prompt} [y/N]: "${N})" yn
    case "$yn" in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

# Export all
export R G Y B P C W N D BD UL BL
export BG_R BG_G BG_Y BG_B BG_P BG_C
export CHECK CROSS WARN ARROW BOLT SKULL SHIELD EYE FIRE LOCK GLOBE TARGET GEAR STAR KEY NET DB BUG

┌─────────────────────────────────────────────────────────────┐
│                  ⚡ ARCHPULSE MAIN MENU ⚡                   │
│                                                             │
│  [1] 🔴 RECON      — Nmap, RustScan, Amass, Subfinder...   │
│  [2] 🟡 SCANNER    — Nikto, Wfuzz, Ffuf, Gobuster...      │
│  [3] 🟢 EXPLOIT    — Metasploit, SQLMap, BeEF...           │
│  [4] 🔵 ENUMERATION — Enum4linux, DNSEnum, LinEnum...     │
│  [5] 🟣 PASSWORD    — Hydra, John, Hashcat, Crunch...      │
│  [6] 🟠 BETTERCAP   — MITM, ARP Spoof, Sniffer...          │
│  [7] 🔶 BURPSUITE   — Proxy, Intruder, Scanner...          │
│  [8] ⚪ SQL TOOLS    — SQLMap, NoSQLMap, BBQSQL...         │
│  [9] ⚡ QUICK SCAN   — Automated full scan                  │
│  [0] ❌ EXIT                                              │
└─────────────────────────────────────────────────────────────┘
