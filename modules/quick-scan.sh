#!/usr/bin/env bash
# ARCHPULSE - Quick Scan Script
# Usage: ./quick-scan.sh <target>
# One-shot full reconnaissance + enumeration + vulnerability scan

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

# Check target
TARGET="$1"
[ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target IP/Domain: "${N})" TARGET
[ -z "$TARGET" ] && { error "No target specified!"; exit 1; }

REPORT_DIR="$HOME/archpulse/reports/quick_scan_${TARGET}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

# Banner
clear
echo -e "${R}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║              ⚡ QUICK SCAN - ARCHPULSE ⚡              ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${N}"
echo -e "  ${C}Target:${N}    ${Y}${TARGET}${N}"
echo -e "  ${C}Date:${N}     ${Y}$(date)${N}"
echo -e "  ${C}Reports:${N}  ${G}${REPORT_DIR}/${N}"
echo ""

# ============================================
# PHASE 1: RECONNAISSANCE
# ============================================
header "PHASE 1: RECONNAISSANCE" $R

echo -e "${R}[${Y}●${R}]${N} ${G}Ping sweep...${N}"
ping -c 1 -W 2 "$TARGET" > /dev/null 2>&1 && \
    echo -e "  ${G}✓${N} Host is alive" || \
    echo -e "  ${Y}⚠${N} Host may be down (no ping response)"

echo -e "${R}[${Y}●${R}]${N} ${G}DNS resolution...${N}"
host "$TARGET" 2>/dev/null | tee "$REPORT_DIR/dns.txt"
[ $? -ne 0 ] && dig +short "$TARGET" 2>/dev/null | tee -a "$REPORT_DIR/dns.txt"

# ============================================
# PHASE 2: PORT SCANNING
# ============================================
header "PHASE 2: PORT SCANNING" $Y

echo -e "${R}[${Y}●${R}]${N} ${G}Nmap - Common ports...${N}"
nmap -sC -sV -O -T4 "$TARGET" -oN "$REPORT_DIR/nmap_common.txt" 2>/dev/null
echo -e "  ${G}✓${N} Common ports scanned"

echo -e "${R}[${Y}●${R}]${N} ${G}Nmap - Full port scan...${N}"
nmap -p- --min-rate=1000 -T4 "$TARGET" -oN "$REPORT_DIR/nmap_allports.txt" 2>/dev/null
echo -e "  ${G}✓${N} All ports scanned"

# ============================================
# PHASE 3: ENUMERATION
# ============================================
header "PHASE 3: ENUMERATION" $B

echo -e "${R}[${Y}●${R}]${N} ${B}Service enumeration...${N}"

# Extract open ports
PORTS=$(grep -E '^[0-9]+/tcp' "$REPORT_DIR/nmap_common.txt" 2>/dev/null | cut -d/ -f1 | tr '\n' ',' | sed 's/,$//' 2>/dev/null)
[ -z "$PORTS" ] && PORTS=$(grep -oP '\d+(?=/tcp)' "$REPORT_DIR/nmap_allports.txt" 2>/dev/null | tr '\n' ',' | sed 's/,$//')

# SMB
if echo "$PORTS" | grep -q '445\|139'; then
    echo -e "  ${G}→ SMB (445/139) found. Running enum4linux...${N}"
    enum4linux -a "$TARGET" > "$REPORT_DIR/enum4linux.txt" 2>/dev/null
    echo -e "    ${G}✓${N} Saved"
fi

# HTTP/HTTPS
if echo "$PORTS" | grep -q '80\|443\|8080\|8443'; then
    echo -e "  ${G}→ Web services found. Running whatweb...${N}"
    whatweb "http://$TARGET" -v > "$REPORT_DIR/whatweb.txt" 2>/dev/null
    
    # Try HTTPS as well
    whatweb "https://$TARGET" -v >> "$REPORT_DIR/whatweb.txt" 2>/dev/null
    echo -e "    ${G}✓${N} Technology detection saved"
fi

# DNS
echo -e "  ${G}→ DNS enumeration...${N}"
dnsrecon -d "$TARGET" > "$REPORT_DIR/dnsrecon.txt" 2>/dev/null
echo -e "    ${G}✓${N} DNS recon saved"

# ============================================
# PHASE 4: VULNERABILITY SCANNING
# ============================================
header "PHASE 4: VULNERABILITY SCANNING" $G

echo -e "${R}[${Y}●${R}]${N} ${G}Nmap vulnerability scripts...${N}"
nmap -sV --script vuln "$TARGET" -oN "$REPORT_DIR/nmap_vuln.txt" 2>/dev/null
echo -e "  ${G}✓${N} Vuln scripts run"

# Nikto for web services
if echo "$PORTS" | grep -q '80\|443\|8080\|8443'; then
    echo -e "${R}[${Y}●${R}]${N} ${G}Nikto web scan...${N}"
    nikto -h "http://$TARGET" -o "$REPORT_DIR/nikto_http.txt" 2>/dev/null
    nikto -h "https://$TARGET" -o "$REPORT_DIR/nikto_https.txt" 2>/dev/null
    echo -e "  ${G}✓${N} Nikto scan complete"
fi

# Nuclei
echo -e "${R}[${Y}●${R}]${N} ${G}Nuclei vulnerability templates...${N}"
nuclei -u "http://$TARGET" -severity low,medium,high,critical -o "$REPORT_DIR/nuclei.txt" 2>/dev/null || \
nuclei -u "https://$TARGET" -severity low,medium,high,critical -o "$REPORT_DIR/nuclei.txt" 2>/dev/null || \
echo -e "  ${Y}⚠${N} Nuclei scan skipped (no web service or Nuclei not installed)"
echo -e "  ${G}✓${N} Nuclei scan complete"

# ============================================
# COMPLETE
# ============================================
echo ""
echo -e "${G}╔══════════════════════════════════════════════════════════╗${N}"
echo -e "${G}║${N}              ${Y}⚡ QUICK SCAN COMPLETE ⚡${N}              ${G}║${N}"
echo -e "${G}╚══════════════════════════════════════════════════════════╝${N}"
echo ""
echo -e "  ${C}Target:${N}      ${Y}${TARGET}${N}"
echo -e "  ${C}Reports:${N}     ${G}${REPORT_DIR}/${N}"
echo -e "  ${C}Duration:${N}    ${Y}$(date)${N}"
echo ""
echo -e "${C}Files generated:${N}"
ls -1 "$REPORT_DIR/" 2>/dev/null | while read f; do
    echo -e "  ${G}→${N} ${Y}${f}${N}"
done
echo ""
echo -e "${Y}Happy hacking! Remember - authorized testing only.${N}"
