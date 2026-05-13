#!/usr/bin/env bash
# ARCHPULSE - Main Launcher / Interactive Menu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colors.sh"

# ============================================
# SHOW BANNER
# ============================================
show_banner() {
    clear
    cat "${SCRIPT_DIR}/.banner.txt" 2>/dev/null
    echo ""
}

# ============================================
# MAIN MENU
# ============================================
main_menu() {
    show_banner
    
    echo -e "${R}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${R}║${N}              ${Y}${BD}⚡ ARCHPULSE MAIN MENU ⚡${N}               ${R}║${N}"
    echo -e "${R}╚══════════════════════════════════════════════════════════╝${N}"
    echo ""
    
    echo -e "  ${R}[${Y}01${R}]${N} ${R}${BD}RECON${N}         ${C}→${N} ${D}Nmap, RustScan, Amass, Subfinder...${N}"
    echo -e "  ${R}[${Y}02${R}]${N} ${Y}${BD}SCANNER${N}       ${C}→${N} ${D}Nikto, Wfuzz, Ffuf, Gobuster...${N}"
    echo -e "  ${R}[${Y}03${R}]${N} ${G}${BD}EXPLOIT${N}       ${C}→${N} ${D}Metasploit, SQLMap, BeEF, Commix...${N}"
    echo -e "  ${R}[${Y}04${R}]${N} ${B}${BD}ENUMERATION${N}   ${C}→${N} ${D}Enum4linux, DNSEnum, LinEnum...${N}"
    echo -e "  ${R}[${Y}05${R}]${N} ${P}${BD}PASSWORD${N}      ${C}→${N} ${D}Hydra, John, Hashcat, Crunch...${N}"
    echo -e "  ${R}[${Y}06${R}]${N} ${C}${BD}BETTERCAP${N}     ${C}→${N} ${D}MITM, ARP Spoof, Sniffer, DNS Spoof...${N}"
    echo -e "  ${R}[${Y}07${R}]${N} ${Y}${BD}BURPSUITE${N}     ${C}→${N} ${D}Proxy, Intruder, Scanner, Repeater...${N}"
    echo -e "  ${R}[${Y}08${R}]${N} ${G}${BD}SQL TOOLS${N}     ${C}→${N} ${D}SQLMap, NoSQLMap, BBQSQL, SQLNinja...${N}"
    echo ""
    echo -e "  ${R}[${Y}09${R}]${N} ${R}${BD}⚡ QUICK SCAN${N}  ${C}→${N} ${D}Automated full scan (target required)${N}"
    echo -e "  ${R}[${Y}10${R}]${N} ${C}${BD}🌐 WEB SCAN${N}    ${C}→${N} ${D}Full web application scan (URL required)${N}"
    echo -e "  ${R}[${Y}11${R}]${N} ${Y}${BD}📊 REPORTS${N}     ${C}→${N} ${D}View/Run report generator${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${R}${BD}❌ EXIT${N}        ${C}→${N} ${D}Exit ARCHPULSE${N}"
    echo ""
    echo -e "${R}┌─────────────────────────────────────────────────────────┐${N}"
    echo -e "${R}│${N} ${Y}${BD}Type a number (01-11) or a command directly:${N}          ${R}│${N}"
    echo -e "${R}│${N} ${D}e.g.: 'nmap -A 192.168.1.1', 'sqlmap -u http://...'${N} ${R}│${N}"
    echo -e "${R}└─────────────────────────────────────────────────────────┘${N}"
    echo ""
    read -p "$(echo -e ${R}"[${Y}ARCHPULSE${R}]${N} > ")" choice
    
    case $choice in
        01|1|recon)   module_recon ;;
        02|2|scanner) module_scanner ;;
        03|3|exploit) module_exploit ;;
        04|4|enum)    module_enumeration ;;
        05|5|password|crack) module_password ;;
        06|6|bettercap|mitm) module_bettercap ;;
        07|7|burp|burpsuite) module_burpsuite ;;
        08|8|sql|sqltools) module_sql ;;
        09|9|quick|quick-scan)
            read -p "$(echo -e ${Y}"[?] Target IP/Domain: "${N})" target
            [ -n "$target" ] && quick_scan "$target" || warning "Target required!"
            ;;
        10|web|web-scan)
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" url
            [ -n "$url" ] && web_scan "$url" || warning "URL required!"
            ;;
        11|reports)  module_reports ;;
        00|0|exit|quit) 
            echo -e "\n${R}☠ Exiting ARCHPULSE... Stay sharp.${N}"
            exit 0
            ;;
        *)
            # Try to execute as a shell command
            if [ -n "$choice" ]; then
                echo -e "\n${C}[${ARROW}]${N} Executing: ${Y}${choice}${N}\n"
                eval "$choice"
                echo ""
                read -p "$(echo -e ${D}"Press Enter to continue..."${N)"
            fi
            ;;
    esac
    
    # Return to menu after action
    read -p "$(echo -e ${D}"Press Enter to return to menu..."${N)" 
    main_menu
}

# ============================================
# MODULE FUNCTIONS
# ============================================

module_recon() {
    show_banner
    header "🔴 RECONNAISSANCE MODULE" $R
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}nmap${N}        ${D}- Full port scan${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}rustscan${N}     ${D}- Fast port scan${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}masscan${N}      ${D}- Mass IP scan${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}subfinder${N}    ${D}- Subdomain enumeration${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}amass${N}        ${D}- Deep subdomain discovery${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}assetfinder${N}  ${D}- Find assets${N}"
    echo -e "  ${R}[${Y}7${R}]${N} ${G}httpx${N}        ${D}- HTTP probe${N}"
    echo -e "  ${R}[${Y}8${R}]${N} ${G}nuclei${N}       ${D}- Vulnerability scanner${N}"
    echo -e "  ${R}[${Y}9${R}]${N} ${G}findomain${N}    ${D}- Subdomain via API${N}"
    echo -e "  ${R}[${Y}10${R}]${N} ${G}dnsx${N}        ${D}- DNS resolver${N}"
    echo -e "  ${R}[${Y}11${R}]${N} ${G}gau${N}         ${D}- Get all URLs${N}"
    echo -e "  ${R}[${Y}12${R}]${N} ${G}waybackurls${N} ${D}- Wayback Machine URLs${N}"
    echo -e "  ${R}[${Y}13${R}]${N} ${G}naabu${N}       ${D}- ProjectDiscovery portscan${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${R}"[${Y}RECON${R}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|nmap) 
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            [ -n "$t" ] && tool_banner "NMAP" "Recon" $R && \
            echo -e "${G}Running: nmap -sC -sV -O -A ${t}${N}\n" && \
            nmap -sC -sV -O -A "$t" | tee "$HOME/archpulse/reports/nmap_$(date +%Y%m%d_%H%M).txt"
            ;;
        2|rustscan)
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            [ -n "$t" ] && tool_banner "RUSTSCAN" "Recon" $R && \
            rustscan -a "$t" --ulimit 5000
            ;;
        3|masscan)
            read -p "$(echo -e ${Y}"[?] Range (e.g. 192.168.1.0/24): "${N})" t
            read -p "$(echo -e ${Y}"[?] Ports (e.g. 80,443,22): "${N})" p
            [ -n "$t" ] && tool_banner "MASSCAN" "Recon" $R && \
            masscan "$t" -p${p:-80,443,22,8080,3306} --rate=1000
            ;;
        4|subfinder)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "SUBFINDER" "Recon" $R && \
            subfinder -d "$t" -all -o "$HOME/archpulse/reports/subfinder_$(date +%Y%m%d).txt" && \
            success "Results saved to reports/"
            ;;
        5|amass)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "AMASS" "Recon" $R && \
            amass enum -d "$t" -o "$HOME/archpulse/reports/amass_$(date +%Y%m%d).txt"
            ;;
        6|assetfinder)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "ASSETFINDER" "Recon" $R && \
            assetfinder --subs-only "$t"
            ;;
        7|httpx)
            tool_banner "HTTPX" "Recon" $R
            read -p "$(echo -e ${Y}"[?] File with URLs/domains (or just target): "${N})" t
            [ -n "$t" ] && [ -f "$t" ] && httpx -l "$t" -status-code -title -tech-detect || httpx -u "$t" -status-code -title -tech-detect
            ;;
        8|nuclei)
            tool_banner "NUCLEI" "Recon" $R
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            [ -n "$t" ] && nuclei -u "$t" -severity low,medium,high,critical
            ;;
        9|findomain)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "FINDOMAIN" "Recon" $R && findomain -t "$t"
            ;;
        10|dnsx)
            read -p "$(echo -e ${Y}"[?] File with domains or single domain: "${N})" t
            [ -n "$t" ] && tool_banner "DNSX" "Recon" $R && \
            [ -f "$t" ] && dnsx -l "$t" -a -aaaa -cname -resp || echo "$t" | dnsx -a -aaaa -cname -resp
            ;;
        11|gau)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "GAU" "Recon" $R && gau --subs "$t"
            ;;
        12|waybackurls)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "WAYBACKURLS" "Recon" $R && waybackurls "$t"
            ;;
        13|naabu)
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            [ -n "$t" ] && tool_banner "NAABU" "Recon" $R && naabu -host "$t"
            ;;
        00|0|back) return ;;
        *) 
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""; read -p "$(echo -e ${D}"Press Enter..."${N)"
    module_recon
}

# --- SCANNER MODULE ---
module_scanner() {
    show_banner
    header "🟡 SCANNER MODULE" $Y
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}nikto${N}       ${D}- Web server scanner${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}whatweb${N}     ${D}- Technology detection${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}wfuzz${N}       ${D}- Web fuzzer${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}ffuf${N}        ${D}- Fast web fuzzer${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}dirsearch${N}   ${D}- Directory brute-force${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}gobuster${N}    ${D}- Directory/DNS brute${N}"
    echo -e "  ${R}[${Y}7${R}]${N} ${G}gospider${N}    ${D}- Web crawler${N}"
    echo -e "  ${R}[${Y}8${R}]${N} ${G}hakrawler${N}   ${D}- Lightweight crawler${N}"
    echo -e "  ${R}[${Y}9${R}]${N} ${G}skipfish${N}    ${D}- Web app scanner${N}"
    echo -e "  ${R}[${Y}10${R}]${N} ${G}wapiti${N}     ${D}- Vuln scanner${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${Y}"[${Y}SCANNER${R}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|nikto)
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            [ -n "$t" ] && tool_banner "NIKTO" "Scanner" $Y && \
            nikto -h "$t" -o "$HOME/archpulse/reports/nikto_$(date +%Y%m%d).html"
            ;;
        2|whatweb)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            [ -n "$t" ] && tool_banner "WHATWEB" "Scanner" $Y && whatweb "$t" -v
            ;;
        3|wfuzz)
            read -p "$(echo -e ${Y}"[?] URL (use FUZZ keyword): "${N})" t
            read -p "$(echo -e ${Y}"[?] Wordlist path: "${N})" w
            [ -n "$t" ] && tool_banner "WFUZZ" "Scanner" $Y && \
            wfuzz -w "${w:-/usr/share/wordlists/dirb/common.txt}" "$t"
            ;;
        4|ffuf)
            read -p "$(echo -e ${Y}"[?] URL (use FUZZ): "${N})" t
            read -p "$(echo -e ${Y}"[?] Wordlist: "${N})" w
            [ -n "$t" ] && tool_banner "FFUF" "Scanner" $Y && \
            ffuf -u "$t" -w "${w:-~/archpulse/wordlists/common.txt}"
            ;;
        5|dirsearch)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            [ -n "$t" ] && tool_banner "DIRSEARCH" "Scanner" $Y && dirsearch -u "$t" --format=plain -o "$HOME/archpulse/reports/dirsearch_$(date +%Y%m%d).txt"
            ;;
        6|gobuster)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            read -p "$(echo -e ${Y}"[?] Mode (dir/dns/vhost): "${N})" mode
            read -p "$(echo -e ${Y}"[?] Wordlist: "${N})" w
            [ -n "$t" ] && tool_banner "GOBUSTER" "Scanner" $Y && \
            gobuster "${mode:-dir}" -u "$t" -w "${w:-~/archpulse/wordlists/common.txt}"
            ;;
        7|gospider)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            [ -n "$t" ] && tool_banner "GOSPIDER" "Scanner" $Y && gospider -s "$t"
            ;;
        8|hakrawler)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            [ -n "$t" ] && tool_banner "HAKRAWLER" "Scanner" $Y && echo "$t" | hakrawler
            ;;
        9|skipfish)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            [ -n "$t" ] && tool_banner "SKIPFISH" "Scanner" $Y && \
            mkdir -p /tmp/skipfish_out && skipfish -o /tmp/skipfish_out "$t"
            ;;
        10|wapiti)
            read -p "$(echo -e ${Y}"[?] URL: "${N})" t
            [ -n "$t" ] && tool_banner "WAPITI" "Scanner" $Y && wapiti -u "$t" -o "$HOME/archpulse/reports/wapiti_$(date +%Y%m%d)"
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""; read -p "$(echo -e ${D}"Press Enter..."${N)"
    module_scanner
}

# --- EXPLOIT MODULE ---
module_exploit() {
    show_banner
    header "🟢 EXPLOIT MODULE" $G
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}msfconsole${N}  ${D}- Metasploit Framework${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}sqlmap${N}      ${D}- SQL Injection automation${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}commix${N}      ${D}- Command injection${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}beef-xss${N}    ${D}- Browser Exploit Framework${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}routersploit${N} ${D}- Router exploit framework${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}searchsploit${N} ${D}- Exploit-DB search${N}"
    echo -e "  ${R}[${Y}7${R}]${N} ${G}xsstrike${N}    ${D}- XSS vulnerability scanner${N}"
    echo -e "  ${R}[${Y}8${R}]${N} ${G}shellnoob${N}   ${D}- Shellcode generation${N}"
    echo -e "  ${R}[${Y}9${R}]${N} ${G}exploitdb${N}   ${D}- Browse Exploit Database${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${G}"[${Y}EXPLOIT${G}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|msf|metasploit)
            tool_banner "METASPLOIT" "Exploit" $G
            info "Starting Metasploit... (use 'exit' to return)"
            msfconsole -q -x "banner; echo 'ARCHPULSE Metasploit Loaded';"
            ;;
        2|sqlmap)
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            [ -n "$t" ] && tool_banner "SQLMAP" "Exploit" $G && \
            sqlmap -u "$t" --batch --random-agent --output-dir="$HOME/archpulse/reports/sqlmap"
            ;;
        3|commix)
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            [ -n "$t" ] && tool_banner "COMMIX" "Exploit" $G && commix --url="$t"
            ;;
        4|beef)
            tool_banner "BEEF" "Exploit" $G
            info "Starting BeEF... Access http://localhost:3000/ui/panel"
            beef-xss
            ;;
        5|routersploit)
            tool_banner "ROUTERSPLOIT" "Exploit" $G
            rsf.py
            ;;
        6|searchsploit)
            read -p "$(echo -e ${Y}"[?] Search term: "${N})" t
            [ -n "$t" ] && tool_banner "SEARCHSPLOIT" "Exploit" $G && searchsploit "$t"
            ;;
        7|xsstrike)
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            [ -n "$t" ] && tool_banner "XSSTRIKE" "Exploit" $G && xsstrike -u "$t"
            ;;
        8|shellnoob)
            tool_banner "SHELLNOOB" "Exploit" $G
            read -p "$(echo -e ${Y}"[?] Shellcode type (e.g. --from-raw): "${N})" args
            shellnoob $args
            ;;
        9|exploitdb)
            tool_banner "EXPLOITDB" "Exploit" $G
            ls -la /usr/share/exploitdb/ | head -20
            info "Path: /usr/share/exploitdb/"
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""; read -p "$(echo -e ${D}"Press Enter..."${N)"
    module_exploit
}

# --- ENUMERATION MODULE ---
module_enumeration() {
    show_banner
    header "🔵 ENUMERATION MODULE" $B
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}enum4linux${N}  ${D}- Windows/Samba enumeration${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}smbclient${N}   ${D}- SMB share access${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}snmpwalk${N}    ${D}- SNMP MIB enumeration${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}dnsenum${N}     ${D}- DNS enumeration${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}dnsrecon${N}    ${D}- DNS reconnaissance${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}ldapsearch${N}  ${D}- LDAP directory query${N}"
    echo -e "  ${R}[${Y}7${R}]${N} ${G}LinEnum${N}     ${D}- Linux priv esc enum${N}"
    echo -e "  ${R}[${Y}8${R}]${N} ${G}linpeas${N}     ${D}- Privilege Escalation Awesome${N}"
    echo -e "  ${R}[${Y}9${R}]${N} ${G}nbtscan${N}     ${D}- NetBIOS name scanner${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${B}"[${Y}ENUM${B}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|enum4linux)
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            [ -n "$t" ] && tool_banner "ENUM4LINUX" "Enumeration" $B && enum4linux -a "$t"
            ;;
        2|smbclient)
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            [ -n "$t" ] && tool_banner "SMBCLIENT" "Enumeration" $B && smbclient -L "//$t" -N
            ;;
        3|snmpwalk)
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            read -p "$(echo -e ${Y}"[?] Community string [public]: "${N})" c
            [ -n "$t" ] && tool_banner "SNMPWALK" "Enumeration" $B && \
            snmpwalk -v2c -c "${c:-public}" "$t"
            ;;
        4|dnsenum)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "DNSENUM" "Enumeration" $B && dnsenum "$t"
            ;;
        5|dnsrecon)
            read -p "$(echo -e ${Y}"[?] Domain: "${N})" t
            [ -n "$t" ] && tool_banner "DNSRECON" "Enumeration" $B && dnsrecon -d "$t"
            ;;
        6|ldapsearch)
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            [ -n "$t" ] && tool_banner "LDAPSEARCH" "Enumeration" $B && ldapsearch -x -h "$t" -b "dc=$(echo $t|cut -d. -f1),dc=$(echo $t|cut -d. -f2)"
            ;;
        7|linenum)
            tool_banner "LINENUM" "Enumeration" $B
            LINENUM_URL="https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh"
            curl -s "$LINENUM_URL" | bash
            ;;
        8|linpeas)
            tool_banner "LINPEAS" "Enumeration" $B
            PEAS_URL="https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh"
            curl -sL "$PEAS_URL" | bash
            ;;
        9|nbtscan)
            read -p "$(echo -e ${Y}"[?] Range (e.g. 192.168.1.0/24): "${N})" t
            [ -n "$t" ] && tool_banner "NBTSCAN" "Enumeration" $B && nbtscan "$t"
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""; read -p "$(echo -e ${D}"Press Enter..."${N)"
    module_enumeration
}

# --- PASSWORD MODULE ---
module_password() {
    show_banner
    header "🟣 PASSWORD CRACKING MODULE" $P
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}hydra${N}       ${D}- Network login brute-force${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}john${N}        ${D}- John the Ripper${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}hashcat${N}     ${D}- GPU-accelerated cracking${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}medusa${N}      ${D}- Parallel brute-forcer${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}crunch${N}      ${D}- Wordlist generator${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}cewl${N}        ${D}- Custom wordlist from URL${N}"
    echo -e "  ${R}[${Y}7${R}]${N} ${G}hash-id${N}     ${D}- Hash type identifier${N}"
    echo -e "  ${R}[${Y}8${R}]${N} ${G}rsmangler${N}   ${D}- Wordlist mutation${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${P}"[${Y}PASSWORD${P}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|hydra)
            echo -e "${Y}[?] Service (ssh/ftp/http-get/http-post-form/mysql/postgres):${N}"
            read -p "> " service
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            read -p "$(echo -e ${Y}"[?] Username/File: "${N})" u
            read -p "$(echo -e ${Y}"[?] Password file: "${N})" p
            [ -n "$t" ] && tool_banner "HYDRA" "Password" $P && \
            hydra -l "$u" -P "${p:-~/archpulse/wordlists/rockyou.txt}" "$service://$t"
            ;;
        2|john)
            read -p "$(echo -e ${Y}"[?] Hash file path: "${N})" t
            [ -n "$t" ] && tool_banner "JOHN THE RIPPER" "Password" $P && \
            john "$t" --wordlist=~/archpulse/wordlists/rockyou.txt
            ;;
        3|hashcat)
            read -p "$(echo -e ${Y}"[?] Hash file: "${N})" t
            read -p "$(echo -e ${Y}"[?] Hash mode (e.g. 0=MD5, 1000=NTLM): "${N})" m
            [ -n "$t" ] && tool_banner "HASHCAT" "Password" $P && \
            hashcat -m "${m:-0}" "$t" ~/archpulse/wordlists/rockyou.txt --force
            ;;
        4|medusa)
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            read -p "$(echo -e ${Y}"[?] Service (ssh/ftp/telnet/mysql): "${N})" s
            read -p "$(echo -e ${Y}"[?] Username: "${N})" u
            [ -n "$t" ] && tool_banner "MEDUSA" "Password" $P && \
            medusa -h "$t" -u "$u" -P ~/archpulse/wordlists/rockyou.txt -M "${s:-ssh}"
            ;;
        5|crunch)
            read -p "$(echo -e ${Y}"[?] Min length: "${N})" min
            read -p "$(echo -e ${Y}"[?] Max length: "${N})" max
            read -p "$(echo -e ${Y}"[?] Charset (e.g. abcdef123): "${N})" c
            [ -n "$min" ] && tool_banner "CRUNCH" "Password" $P && \
            crunch "$min" "$max" "${c:-abcdefghijklmnopqrstuvwxyz0123456789}" -o ~/archpulse/wordlists/crunch_$(date +%Y%m%d).txt
            ;;
        6|cewl)
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            [ -n "$t" ] && tool_banner "CEWL" "Password" $P && \
            cewl "$t" -w ~/archpulse/wordlists/cewl_$(date +%Y%m%d).txt -m 6
            ;;
        7|hash-id|hash-identifier)
            tool_banner "HASH IDENTIFIER" "Password" $P && hash-identifier
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""; read -p "$(echo -e ${D}"Press Enter..."${N)"
    module_password
}

# --- BETTERCAP MODULE ---
module_bettercap() {
    show_banner
    header "🟠 BETTERCAP - MITM FRAMEWORK" $C
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}Full MITM${N}     ${D}- ARP spoof + sniff all traffic${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}ARP Spoof${N}     ${D}- Basic ARP cache poisoning${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}DNS Spoof${N}     ${D}- DNS response manipulation${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}SSL Strip${N}     ${D}- HTTPS → HTTP downgrade${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}Sniffer${N}       ${D}- Capture credentials & traffic${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}Interactive${N}   ${D}- Launch Bettercap CLI${N}"
    echo -e "  ${R}[${Y}7${R}]${N} ${G}Web UI${N}        ${D}- Launch Bettercap web interface${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${C}"[${Y}BETTERCAP${C}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|full|mitm)
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            read -p "$(echo -e ${Y}"[?] Interface (e.g. eth0/wlan0): "${N})" iface
            [ -n "$t" ] && tool_banner "BETTERCAP - FULL MITM" "Bettercap" $C && \
            sudo bettercap -eval "set arp.spoof.targets $t; set arp.spoof.interface ${iface:-eth0}; arp.spoof on; net.sniff on"
            ;;
        2|arp)
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            read -p "$(echo -e ${Y}"[?] Interface: "${N})" iface
            [ -n "$t" ] && sudo bettercap -eval "set arp.spoof.targets $t; set arp.spoof.interface ${iface:-eth0}; arp.spoof on"
            ;;
        3|dns)
            read -p "$(echo -e ${Y}"[?] Interface: "${N})" iface
            [ -n "$iface" ] && sudo bettercap -eval "set arp.spoof.interface $iface; set dns.spoof.all true; arp.spoof on; dns.spoof on"
            ;;
        4|sslstrip)
            read -p "$(echo -e ${Y}"[?] Interface: "${N})" iface
            [ -n "$iface" ] && sudo bettercap -eval "set arp.spoof.interface $iface; set http.proxy.sslstrip true; http.proxy on; arp.spoof on"
            ;;
        5|sniff)
            read -p "$(echo -e ${Y}"[?] Interface: "${N})" iface
            [ -n "$iface" ] && sudo bettercap -eval "set arp.spoof.interface $iface; set net.sniff.local true; net.sniff on; arp.spoof on"
            ;;
        6|cli)
            tool_banner "BETTERCAP CLI" "Bettercap" $C
            sudo bettercap
            ;;
        7|web|ui)
            tool_banner "BETTERCAP WEB UI" "Bettercap" $C
            info "Starting Bettercap with Web UI..."
            info "Access at: http://127.0.0.1:80"
            sudo bettercap -eval "set api.rest.username admin; set api.rest.password admin; api.rest on; http-ui on"
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""; read -p "$(echo -e ${D}"Press Enter..."${N)"
    module_bettercap
}

# ===== BURPSUITE MODULE (continued) =====
module_burpsuite() {
    show_banner
    header "🔶 BURPSUITE - WEB APP TESTING" $Y
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}Launch BurpSuite${N} ${D}- Start BurpSuite Community${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}Setup Proxy${N}     ${D}- Configure 127.0.0.1:8080 proxy${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}FoxyProxy${N}      ${D}- Get FoxyProxy Firefox addon info${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}CA Certificate${N}  ${D}- Download Burp CA cert${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}Check Java${N}      ${D}- Check Java version for Burp${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${Y}"[${Y}BURPSUITE${Y}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|launch|start)
            tool_banner "BURPSUITE" "BurpSuite" $Y
            info "Starting BurpSuite Community Edition..."
            burpsuite &
            sleep 2
            info "BurpSuite launched in background. Check your window."
            ;;
        2|proxy)
            tool_banner "BURPSUITE PROXY SETUP" "BurpSuite" $Y
            echo -e "${C}┌─────────────────────────────────────────────────────────┐${N}"
            echo -e "${C}│${N} ${Y}Burp Proxy Configuration:${N}                              ${C}│${N}"
            echo -e "${C}│${N}                                                       ${C}│${N}"
            echo -e "${C}│${N} ${G}1.${N} Open BurpSuite → Proxy → Proxy Settings        ${C}│${N}"
            echo -e "${C}│${N} ${G}2.${N} Add listener: ${Y}127.0.0.1:8080${N}                    ${C}│${N}"
            echo -e "${C}│${N} ${G}3.${N} Check 'Running'                                 ${C}│${N}"
            echo -e "${C}│${N} ${G}4.${N} Set browser proxy to ${Y}127.0.0.1:8080${N}            ${C}│${N}"
            echo -e "${C}│${N}                                                       ${C}│${N}"
            echo -e "${C}│${N} ${Y}Firefox proxy set:${N}                                  ${C}│${N}"
            echo -e "${C}│${N}   Settings → Network → Connection Settings            ${C}│${N}"
            echo -e "${C}│${N}   → Manual proxy: ${G}127.0.0.1${N} Port: ${G}8080${N}          ${C}│${N}"
            echo -e "${C}│${N}   → Check 'Also use this proxy for HTTPS'             ${C}│${N}"
            echo -e "${C}└─────────────────────────────────────────────────────────┘${N}"
            ;;
        3|foxyproxy)
            tool_banner "FOXYPROXY" "BurpSuite" $Y
            echo -e "${G}FoxyProxy Standard (Firefox):${N}"
            echo -e "  ${C}→${N} https://addons.mozilla.org/firefox/addon/foxyproxy-standard/"
            echo ""
            echo -e "${G}Quick config:${N}"
            echo -e "  ${Y}Proxy Type:${N} HTTP"
            echo -e "  ${Y}IP:${N} 127.0.0.1"
            echo -e "  ${Y}Port:${N} 8080"
            echo -e "  ${Y}Pattern:${N} Enable for all URLs"
            ;;
        4|cert|ca)
            tool_banner "BURPSUITE CA CERTIFICATE" "BurpSuite" $Y
            info "To install Burp's CA certificate for HTTPS inspection:"
            echo -e "  ${G}1.${N} Ensure Burp proxy is running on 127.0.0.1:8080"
            echo -e "  ${G}2.${N} Browse to: ${Y}http://127.0.0.1:8080/${N}"
            echo -e "  ${G}3.${N} Click 'CA Certificate' (top-right)"
            echo -e "  ${G}4.${N} Save ${Y}cacert.der${N}"
            echo -e "  ${G}5.${N} Firefox → Settings → Certificates → Import"
            echo -e "  ${G}6.${N} Check 'Trust this CA to identify websites'"
            ;;
        5|java)
            tool_banner "JAVA CHECK" "BurpSuite" $Y
            echo -e "${C}Java Version (Burp requires Java 17+):${N}"
            java_version=$(java -version 2>&1 | head -1)
            echo -e "  ${G}${java_version}${N}"
            echo ""
            echo -e "${C}Available Java versions:${N}"
            archlinux-java status 2>/dev/null || echo -e "  ${Y}Run: archlinux-java status${N}"
            echo ""
            echo -e "${C}If Burp fails with 'illegal-access=permit':${N}"
            echo -e "  ${Y}sudo archlinux-java set java-17-openjdk${N}"
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""
    read -p "$(echo -e ${D}"Press Enter to return..."${N)"
    module_burpsuite
}

# --- SQL TOOLS MODULE ---
module_sql() {
    show_banner
    header "⚪ SQL TOOLS MODULE" $G
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}sqlmap${N}       ${D}- SQL Injection automation${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}sqlninja${N}     ${D}- MS SQL Server injection${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}nosqlmap${N}     ${D}- NoSQL injection (MongoDB)${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}bbqsql${N}       ${D}- Blind SQL injection framework${N}"
    echo -e "  ${R}[${Y}5${R}]${N} ${G}sqlbrute${N}     ${D}- SQL Server brute-force${N}"
    echo -e "  ${R}[${Y}6${R}]${N} ${G}hqlmap${N}       ${D}- HQL injection${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${G}"[${Y}SQL${G}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|sqlmap)
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            echo -e "${Y}[?] Additional options (e.g. --data=\"id=1\" --cookie=\"...\"):${N}"
            read -p "> " opt
            [ -n "$t" ] && tool_banner "SQLMAP" "SQL Tools" $G && \
            sqlmap -u "$t" $opt --batch --random-agent --level=3 --risk=2 \
                --output-dir="$HOME/archpulse/reports/sqlmap" \
                --tamper=space2comment
            ;;
        2|sqlninja)
            tool_banner "SQLNINJA" "SQL Tools" $G
            read -p "$(echo -e ${Y}"[?] Config file path (or target IP): "${N})" t
            [ -n "$t" ] && sqlninja -f "$t" 2>/dev/null || \
                info "Usage: sqlninja -f <config.conf> | See /usr/share/doc/sqlninja/"
            ;;
        3|nosqlmap)
            tool_banner "NOSQLMAP" "SQL Tools" $G
            read -p "$(echo -e ${Y}"[?] Target URL: "${N})" t
            [ -n "$t" ] && nosqlmap --url "$t"
            ;;
        4|bbqsql)
            tool_banner "BBQSQL" "SQL Tools" $G
            info "Launching BBQSQL interactive..."
            bbqsql 2>/dev/null || echo -e "${Y}BBQSQL requires config. Run: bbqsql${N}"
            ;;
        5|sqlbrute)
            tool_banner "SQLBRUTE" "SQL Tools" $G
            read -p "$(echo -e ${Y}"[?] Target IP: "${N})" t
            read -p "$(echo -e ${Y}"[?] Username [sa]: "${N})" u
            [ -n "$t" ] && sqlbrute -h "$t" -u "${u:-sa}" -w ~/archpulse/wordlists/rockyou.txt
            ;;
        6|hqlmap)
            tool_banner "HQLMAP" "SQL Tools" $G
            info "Launching HQLMap..."
            hqlmap 2>/dev/null || info "HQLMap: python hqlmap.py -u <url>"
            ;;
        00|0|back) return ;;
        *)
            [ -n "$tool_choice" ] && eval "$tool_choice"
            ;;
    esac
    echo ""
    read -p "$(echo -e ${D}"Press Enter to return..."${N)"
    module_sql
}

# --- QUICK SCAN ---
quick_scan() {
    local target="$1"
    local report_dir="$HOME/archpulse/reports"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report="$report_dir/quick_scan_${target}_${timestamp}"
    
    show_banner
    header "⚡ QUICK SCAN: ${target}" $R
    
    mkdir -p "$report"
    
    echo -e "${Y}[${ARROW}]${N} Starting comprehensive scan of ${G}${target}${N}"
    echo -e "${D}Reports will be saved to: ${report}/${N}"
    echo ""
    
    # Step 1: Nmap port scan
    echo -e "${R}[${Y}1/5${R}]${N} ${G}NMAP${N} - Port scanning..."
    nmap -sC -sV -O -T4 -p- --min-rate=1000 "$target" -oN "$report/nmap_full.txt" 2>/dev/null
    echo -e "  ${G}✓${N} Saved: nmap_full.txt"
    
    # Step 2: Nmap common ports
    echo -e "${R}[${Y}2/5${R}]${N} ${G}NMAP${N} - Service detection..."
    nmap -sC -sV -O -A "$target" -oN "$report/nmap_services.txt" 2>/dev/null
    echo -e "  ${G}✓${N} Saved: nmap_services.txt"
    
    # Step 3: Enumeration
    echo -e "${R}[${Y}3/5${R}]${N} ${B}ENUM${N} - Service enumeration..."
    enum4linux -a "$target" > "$report/enum4linux.txt" 2>/dev/null
    echo -e "  ${G}✓${N} Saved: enum4linux.txt"
    
    # Step 4: Web scan if HTTP ports open
    echo -e "${R}[${Y}4/5${R}]${N} ${Y}WEB${N} - Web server detection..."
    whatweb "$target" > "$report/whatweb.txt" 2>/dev/null
    echo -e "  ${G}✓${N} Saved: whatweb.txt"
    
    # Step 5: Vuln scan
    echo -e "${R}[${Y}5/5${R}]${N} ${G}NUCLEI${N} - Vulnerability scanning..."
    nuclei -u "http://$target" -severity low,medium,high,critical -o "$report/nuclei.txt" 2>/dev/null || \
    nuclei -u "https://$target" -severity low,medium,high,critical -o "$report/nuclei.txt" 2>/dev/null
    echo -e "  ${G}✓${N} Saved: nuclei.txt"
    
    echo ""
    echo -e "${G}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${G}║${N}              ${Y}⚡ QUICK SCAN COMPLETE ⚡${N}              ${G}║${N}"
    echo -e "${G}╚══════════════════════════════════════════════════════════╝${N}"
    echo -e "  ${C}Target:${N}      ${Y}${target}${N}"
    echo -e "  ${C}Reports:${N}     ${G}${report}/${N}"
    echo -e "  ${C}Time:${N}       ${Y}$(date)${N}"
    echo ""
    ls -la "$report/"
}

# --- WEB SCAN ---
web_scan() {
    local url="$1"
    local report_dir="$HOME/archpulse/reports"
    local domain=$(echo "$url" | sed 's|https\?://||' | sed 's|/.*||')
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local report="$report_dir/web_scan_${domain}_${timestamp}"
    
    show_banner
    header "🌐 WEB SCAN: ${url}" $Y
    
    mkdir -p "$report"
    
    echo -e "${C}[1/8]${N} ${G}WhatWeb${N} - Technology detection..."
    whatweb -v "$url" > "$report/whatweb.txt" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[2/8]${N} ${G}Nikto${N} - Web server scan..."
    nikto -h "$url" -o "$report/nikto.txt" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[3/8]${N} ${G}Wapiti${N} - Vulnerability scanner..."
    wapiti -u "$url" -o "$report/wapiti/" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[4/8]${N} ${G}Gobuster${N} - Directory enumeration..."
    gobuster dir -u "$url" -w ~/archpulse/wordlists/common.txt -o "$report/gobuster.txt" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[5/8]${N} ${G}SQLMap${N} - SQL injection test..."
    sqlmap -u "$url" --batch --crawl=2 --level=1 --risk=1 -o "$report/sqlmap/" --output-dir="$report/sqlmap" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[6/8]${N} ${G}XSStrike${N} - XSS scan..."
    xsstrike -u "$url" --timeout=10 2>/dev/null > "$report/xsstrike.txt" && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[7/8]${N} ${G}GoSpider${N} - Web crawling..."
    gospider -s "$url" -o "$report/gospider/" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo -e "${C}[8/8]${N} ${G}Nuclei${N} - Vulnerability template scan..."
    nuclei -u "$url" -severity low,medium,high,critical -o "$report/nuclei.txt" 2>/dev/null && echo -e "  ${G}✓${N}" || echo -e "  ${Y}⚠${N}"
    
    echo ""
    echo -e "${Y}╔══════════════════════════════════════════════════════════╗${N}"
    echo -e "${Y}║${N}           ${G}🌐 WEB APPLICATION SCAN COMPLETE 🌐${N}          ${Y}║${N}"
    echo -e "${Y}╚══════════════════════════════════════════════════════════╝${N}"
    echo -e "  ${C}URL:${N}         ${Y}${url}${N}"
    echo -e "  ${C}Reports:${N}     ${G}${report}/${N}"
    echo ""
}

# --- REPORTS MODULE ---
module_reports() {
    show_banner
    header "📊 REPORT CENTER" $C
    
    local report_dir="$HOME/archpulse/reports"
    mkdir -p "$report_dir"
    
    echo -e "  ${R}[${Y}1${R}]${N} ${G}List Reports${N}    ${D}- Show all saved reports${N}"
    echo -e "  ${R}[${Y}2${R}]${N} ${G}View Report${N}     ${D}- View a specific report${N}"
    echo -e "  ${R}[${Y}3${R}]${N} ${G}Generate Summary${N}${D}- Create markdown summary${N}"
    echo -e "  ${R}[${Y}4${R}]${N} ${G}Clean Reports${N}   ${D}- Delete old reports${N}"
    echo -e "  ${R}[${Y}00${R}]${N} ${Y}Back to Main Menu${N}"
    echo ""
    
    read -p "$(echo -e ${C}"[${Y}REPORTS${C}]${N} > ")" tool_choice
    
    case $tool_choice in
        1|list)
            tool_banner "LIST REPORTS" "Reports" $C
            echo -e "${C}Reports directory: ${G}${report_dir}${N}"
            echo ""
            if [ -d "$report_dir" ]; then
                find "$report_dir" -type f -name "*.txt" -o -name "*.html" -o -name "*.md" 2>/dev/null | \
                while read f; do
                    size=$(du -h "$f" 2>/dev/null | cut -f1)
                    date=$(stat -c "%y" "$f" 2>/dev/null | cut -d. -f1)
                    echo -e "  ${Y}[${size}]${N} ${G}$(basename $f)${N} ${D}(${date})${N}"
                done | sort -t'(' -k2
            else
                echo -e "  ${Y}No reports found.${N}"
            fi
            ;;
        2|view)
            tool_banner "VIEW REPORT" "Reports" $C
            echo -e "${C}Available reports:${N}"
            select f in "$report_dir"/*; do
                if [ -f "$f" ]; then
                    echo -e "${G}--- $(basename "$f") ---${N}"
                    head -50 "$f"
                    echo ""
                    echo -e "${D}... (showing first 50 lines)${N}"
                fi
                break
            done
            ;;
        3|summary)
            tool_banner "GENERATE SUMMARY" "Reports" $C
            local summary="$report_dir/summary_$(date +%Y%m%d).md"
            {
                echo "# ARCHPULSE Pentest Summary"
                echo "**Date:** $(date)"
                echo "**Host:** $(hostname)"
                echo ""
                echo "## Reports Generated"
                echo ""
                find "$report_dir" -type f -name "*.txt" -newer "$report_dir" -mmin -1440 2>/dev/null | \
                while read f; do
                    echo "- $(basename $f): $(wc -l < "$f") lines"
                done
                echo ""
                echo "## Tools Used"
                echo ""
                for tool in nmap sqlmap hydra john metasploit bettercap; do
                    if command -v "$tool" &>/dev/null; then
                        echo "- $tool: $(which $tool)"
                    fi
                done
            } > "$summary"
            success "Summary saved: $summary"
            cat "$summary"
            ;;
        4|clean)
            if confirm "Delete all reports older than 7 days?"; then
                find "$report_dir" -type f -mtime +7 -delete 2>/dev/null
                success "Old reports cleaned!"
            fi
            ;;
        00|0|back) return ;;
    esac
    echo ""
    read -p "$(echo -e ${D}"Press Enter to return..."${N)"
    module_reports
}

# ============================================
# MAIN ENTRY POINT
# ============================================
case "${1,,}" in
    recon|1)      module_recon ;;
    scanner|2)    module_scanner ;;
    exploit|3)    module_exploit ;;
    enum|4|enumeration) module_enumeration ;;
    password|5|crack) module_password ;;
    bettercap|6|mitm) module_bettercap ;;
    burp|7|burpsuite) module_burpsuite ;;
    sql|8|sqltools) module_sql ;;
    quick-scan|9)
        [ -n "$2" ] && quick_scan "$2" || {
            read -p "$(echo -e ${Y}"[?] Target: "${N})" t
            [ -n "$t" ] && quick_scan "$t"
        }
        ;;
    web-scan|10)
        [ -n "$2" ] && web_scan "$2" || {
            read -p "$(echo -e ${Y}"[?] URL: "${N})" u
            [ -n "$u" ] && web_scan "$u"
        }
        ;;
    reports|11)   module_reports ;;
    --setup)      
        echo -e "${C}[${ARROW}]${N} Setting up ARCHPULSE environment..."
        mkdir -p "$HOME/archpulse"/{reports,wordlists,logs,configs}
        success "Environment ready at ~/archpulse/"
        ;;
    --help|-h)
        echo "ARCHPULSE v2.0 - ArchLinux Pentesting Arsenal"
        echo "Usage: archpulse [module] [target]"
        echo ""
        echo "Modules:"
        echo "  recon         - Reconnaissance tools"
        echo "  scanner       - Scanning tools"
        echo "  exploit       - Exploitation tools"
        echo "  enum          - Enumeration tools"
        echo "  password      - Password cracking tools"
        echo "  bettercap     - Bettercap MITM framework"
        echo "  burp          - BurpSuite web testing"
        echo "  sql           - SQL injection tools"
        echo "  quick-scan    - Quick full scan"
        echo "  web-scan      - Full web scan"
        echo "  reports       - Report center"
        echo ""
        echo "Examples:"
        echo "  archpulse                          - Interactive menu"
        echo "  archpulse recon                    - Open recon module"
        echo "  archpulse quick-scan 192.168.1.1   - Quick scan target"
        echo "  archpulse web-scan https://site.com - Web scan"
        ;;
    *)
        # Default: show interactive menu
        main_menu
        ;;
esac
