#!/usr/bin/env bash
# ARCHPULSE - Enumeration Module

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "🔵 ENUMERATION TOOLKIT" $B

TARGET="$2"

# If no target provided as arg, prompt
[ -z "$TARGET" ] && [ -n "$1" ] && [ "$1" != "local" ] && TARGET="$1"

case "${1,,}" in
    smb|windows)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "SMB/WINDOWS ENUMERATION" "Enumeration" $B
        info "Target: $TARGET"
        echo ""
        
        echo -e "${C}[▶] Running enum4linux...${N}"
        enum4linux -a "$TARGET" 2>/dev/null
        
        echo ""
        echo -e "${C}[▶] SMB shares...${N}"
        smbclient -L "//$TARGET" -N 2>/dev/null
        ;;
    
    dns)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Domain: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Domain required!"; exit 1; }
        
        tool_banner "DNS ENUMERATION" "Enumeration" $B
        info "Domain: $TARGET"
        echo ""
        
        echo -e "${C}[▶] DNSRecon...${N}"
        dnsrecon -d "$TARGET" -a 2>/dev/null
        
        echo ""
        echo -e "${C}[▶] DNSEnum...${N}"
        dnsenum "$TARGET" 2>/dev/null
        
        echo ""
        echo -e "${C}[▶] Zone transfer test...${N}"
        for ns in $(dig +short NS "$TARGET" 2>/dev/null); do
            echo -e "  ${Y}Trying ${ns}...${N}"
            dig axfr "@$ns" "$TARGET" 2>/dev/null
        done
        ;;
    
    snmp)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "SNMP ENUMERATION" "Enumeration" $B
        
        for community in public private manager; do
            echo -e "${C}[▶] Trying community '${community}'...${N}"
            snmpwalk -v2c -c "$community" "$TARGET" system 2>/dev/null && \
            echo -e "  ${G}✓${N} Community '${community}' works!" && \
            echo "" && \
            snmpwalk -v2c -c "$community" "$TARGET" 2>/dev/null | head -30
            echo ""
        done
        ;;
    
    ldap)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "LDAP ENUMERATION" "Enumeration" $B
        
        # Try anonymous bind
        echo -e "${C}[▶] Anonymous LDAP query...${N}"
        ldapsearch -x -h "$TARGET" -b "" -s base namingcontexts 2>/dev/null
        
        echo ""
        echo -e "${C}[▶] Querying naming contexts...${N}"
        ldapsearch -x -h "$TARGET" -b "dc=$(echo $TARGET|cut -d. -f1),dc=$(echo $TARGET|cut -d. -f2)" 2>/dev/null | head -50
        ;;
    
    local|linux|priv-esc)
        tool_banner "LOCAL ENUMERATION" "Enumeration" $B
        info "Gathering system information for privilege escalation..."
        echo ""
        
        echo -e "${C}[▶] System info...${N}"
        uname -a
        cat /etc/os-release 2>/dev/null | head -3
        echo ""
        
        echo -e "${C}[▶] Users...${N}"
        cat /etc/passwd 2>/dev/null | grep -E "/(home|root|bin/bash)" | cut -d: -f1,3,7
        echo ""
        
        echo -e "${C}[▶] Sudo privileges...${N}"
        sudo -l 2>/dev/null
        echo ""
        
        echo -e "${C}[▶] SUID binaries...${N}"
        find / -perm -4000 -type f 2>/dev/null | head -20
        echo ""
        
        echo -e "${C}[▶] Open ports...${N}"
        ss -tlnp 2>/dev/null | head -20
        echo ""
        
        echo -e "${C}[▶] Running processes...${N}"
        ps aux --sort=-%mem 2>/dev/null | head -15
        echo ""
        
        info "For full enumeration, run linpeas or linenum:"
        echo "  curl -sL https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh | bash"
        ;;
    
    range)
        RANGE="${2:-$(read -p 'CIDR range (e.g. 192.168.1.0/24): ' r && echo $r)}"
        [ -z "$RANGE" ] && { error "Range required!"; exit 1; }
        
        tool_banner "RANGE ENUMERATION: ${RANGE}" "Enumeration" $B
        
        echo -e "${C}[▶] NetBIOS scan...${N}"
        nbtscan "$RANGE" 2>/dev/null
        
        echo ""
        echo -e "${C}[▶] SNMP scan...${N}"
        snmp-check "$RANGE" 2>/dev/null | head -20
        ;;
    
    all|full)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target/Domain: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "FULL ENUMERATION: ${TARGET}" "Enumeration" $B
        
        echo -e "${R}[1/4]${N} ${B}DNS Enumeration...${N}"
        dnsrecon -d "$TARGET" 2>/dev/null | head -20
        echo ""
        
        echo -e "${R}[2/4]${N} ${B}SMB Enumeration...${N}"
        enum4linux -a "$TARGET" 2>/dev/null | head -30
        echo ""
        
        echo -e "${R}[3/4]${N} ${B}LDAP Enumeration...${N}"
        ldapsearch -x -h "$TARGET" -b "" -s base namingcontexts 2>/dev/null
        echo ""
        
        echo -e "${R}[4/4]${N} ${B}SNMP Enumeration...${N}"
        snmpwalk -v2c -c public "$TARGET" system 2>/dev/null | head -20
        ;;
    
    *)
        echo "Usage: $0 <module> [target]"
        echo ""
        echo "Modules:"
        echo "  smb <target>      - SMB/Windows enumeration (enum4linux)"
        echo "  dns <domain>      - DNS enumeration"
        echo "  snmp <target>     - SNMP enumeration"
        echo "  ldap <target>     - LDAP enumeration"
        echo "  local             - Local privilege escalation enum"
        echo "  range <CIDR>      - Network range enumeration"
        echo "  all <target>      - Full enumeration (all modules)"
        echo ""
        echo "Examples:"
        echo "  $0 smb 192.168.1.10
