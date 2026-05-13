#!/usr/bin/env bash
# ARCHPULSE - Web Application Scan
# Usage: ./web-scan.sh <url>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

URL="$1"
[ -z "$URL" ] && read -p "$(echo -e ${Y}"[?] Target URL: "${N})" URL
[ -z "$URL" ] && { error "No URL specified!"; exit 1; }

DOMAIN=$(echo "$URL" | sed 's|https\?://||' | sed 's|/.*$||')
REPORT_DIR="$HOME/archpulse/reports/web_scan_${DOMAIN}_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$REPORT_DIR"

clear
echo -e "${Y}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║          🌐 WEB APPLICATION SCAN - ARCHPULSE          ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${N}"
echo -e "  ${C}URL:${N}       ${Y}${URL}${N}"
echo -e "  ${C}Domain:${N}    ${Y}${DOMAIN}${N}"
echo -e "  ${C}Date:${N}     ${Y}$(date)${N}"
echo ""

# ============================================
# 1. TECHNOLOGY DETECTION
# ============================================
echo -e "${R}[${Y}1/8${R}]${N} ${G}WhatWeb${N} - Technology detection..."
whatweb -v "$URL" > "$REPORT_DIR/01_whatweb.txt" 2>/dev/null
echo -e "  ${G}✓${N} Detected technologies saved"
echo ""

# ============================================
# 2. NIKTO SCAN
# ============================================
echo -e "${R}[${Y}2/8${R}]${N} ${G}Nikto${N} - Web server scanner..."
nikto -h "$URL" -o "$REPORT_DIR/02_nikto.txt" 2>/dev/null
echo -e "  ${G}✓${N} Server vulnerability scan saved"
echo ""

# ============================================
# 3. DIRECTORY ENUMERATION
# ============================================
echo -e "${R}[${Y}3/8${R}]${N} ${G}Dirsearch${N} - Directory enumeration..."
dirsearch -u "$URL" --format=plain -o "$REPORT_DIR/03_dirsearch.txt" 2>/dev/null || {
    # Fallback to gobuster
    gobuster dir -u "$URL" -w ~/archpulse/wordlists/common.txt -o "$REPORT_DIR/03_dirsearch.txt" 2>/dev/null
}
echo -e "  ${G}✓${N} Directory enumeration saved"
echo ""

# ============================================
# 4. CRAWLING
# ============================================
echo -e "${R}[${Y}4/8${R}]${N} ${G}GoSpider${N} - Web crawling..."
gospider -s "$URL" --js -d 2 | tee "$REPORT_DIR/04_gospider.txt" 2>/dev/null
echo -e "  ${G}✓${N} Crawler results saved"
echo ""

# ============================================
# 5. SQL INJECTION
# ============================================
echo -e "${R}[${Y}5/8${R}]${N} ${G}SQLMap${N} - SQL injection test..."
sqlmap -u "$URL" --batch --crawl=2 --level=1 --risk=1 \
    --output-dir="$REPORT_DIR/05_sqlmap" 2>/dev/null
echo -e "  ${G}✓${N} SQL injection scan saved"
echo ""

# ============================================
# 6. XSS SCAN
# ============================================
echo -e "${R}[${Y}6/8${R}]${N} ${G}XSStrike${N} - XSS vulnerability scanner..."
xsstrike -u "$URL" --timeout=10 > "$REPORT_DIR/06_xsstrike.txt" 2>/dev/null
echo -e "  ${G}✓${N} XSS scan saved"
echo ""

# ============================================
# 7. WAPITI VULN SCAN
# ============================================
echo -e "${R}[${Y}7/8${R}]${N} ${G}Wapiti${N} - Web vulnerability scanner..."
wapiti -u "$URL" -o "$REPORT_DIR/07_wapiti" 2>/dev/null
echo -e "  ${G}✓${N} Wapiti scan saved"
echo ""

# ============================================
# 8. NUCLEI
# ============================================
echo -e "${R}[${Y}8/8${R}]${N} ${G}Nuclei${N} - Vulnerability template scanner..."
nuclei -u "$URL" -severity low,medium,high,critical -o "$REPORT_DIR/08_nuclei.txt" 2>/dev/null
echo -e "  ${G}✓${N} Nuclei scan saved"
echo ""

# ============================================
# SUMMARY
# ============================================
echo ""
echo -e "${G}╔══════════════════════════════════════════════════════════╗${N}"
echo -e "${G}║${N}        ${Y}🌐 WEB APPLICATION SCAN COMPLETE 🌐${N}        ${G}║${N}"
echo -e "${G}╚══════════════════════════════════════════════════════════╝${N}"
echo ""
echo -e "  ${C}URL:${N}         ${Y}${URL}${N}"
echo -e "  ${C}Reports:${N}     ${G}${REPORT_DIR}/${N}"
echo ""

# Show findings summary
echo -e "${C}Scan Results Summary:${N}"
echo ""

# Check findings
for f in "$REPORT_DIR"/*; do
    basename=$(basename "$f")
    if [ -f "$f" ]; then
        lines=$(wc -l < "$f")
        issues=$(grep -ciE '(vulnerability|critical|high|error|found)' "$f" 2>/dev/null)
        echo -e "  ${Y}$basename${N}${D}: ${lines} lines, ${issues} issues${N}"
    fi
done

echo ""
echo -e "${D}Reports saved to: ${REPORT_DIR}${N}"
echo ""
echo -e "${Y}For deeper analysis:${N}"
echo -e "  ${G}archpulse exploit${N}    - Open exploit modules"
echo -e "  ${G}archpulse burp${N}       - Launch BurpSuite for manual testing"
