#!/usr/bin/env bash
# ARCHPULSE - Advanced Reconnaissance Module

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "🔴 ADVANCED RECONNAISSANCE" $R

TARGET="$2"
OUTPUT_DIR="$HOME/archpulse/reports/recon_$(date +%Y%m%d_%H%M%S)"

case "${1,,}" in
    subdomain|subs)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Domain: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Domain required!"; exit 1; }
        
        tool_banner "SUBDOMAIN ENUMERATION: ${TARGET}" "Recon" $R
        mkdir -p "$OUTPUT_DIR"
        
        echo -e "${C}[1/5]${N} ${G}Subfinder${N}..."
        subfinder -d "$TARGET" -all -o "$OUTPUT_DIR/subfinder.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Found: $(wc -l < "$OUTPUT_DIR/subfinder.txt" 2>/dev/null || echo 0) subdomains"
        
        echo -e "${C}[2/5]${N} ${G}Assetfinder${N}..."
        assetfinder --subs-only "$TARGET" > "$OUTPUT_DIR/assetfinder.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Found: $(wc -l < "$OUTPUT_DIR/assetfinder.txt" 2>/dev/null || echo 0) subdomains"
        
        echo -e "${C}[3/5]${N} ${G}Amass${N}..."
        amass enum -d "$TARGET" -o "$OUTPUT_DIR/amass.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Found: $(wc -l < "$OUTPUT_DIR/amass.txt" 2>/dev/null || echo 0) subdomains"
        
        echo -e "${C}[4/5]${N} ${G}Findomain${N}..."
        findomain -t "$TARGET" -u "$OUTPUT_DIR/findomain.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Found: $(wc -l < "$OUTPUT_DIR/findomain.txt" 2>/dev/null || echo 0) subdomains"
        
        # Merge and deduplicate
        echo -e "${C}[5/5]${N} ${G}Merging results...${N}"
        cat "$OUTPUT_DIR"/*.txt 2>/dev/null | sort -u > "$OUTPUT_DIR/all_subdomains.txt"
        total=$(wc -l < "$OUTPUT_DIR/all_subdomains.txt" 2>/dev/null || echo 0)
        echo -e "  ${G}✓${N} Total unique subdomains: ${Y}${total}${N}"
        
        # HTTP probing
        if [ "$total" -gt 0 ]; then
            echo -e "${C}[+]${N} ${G}Probing HTTP services...${N}"
            httpx -l "$OUTPUT_DIR/all_subdomains.txt" -status-code -title -tech-detect -o "$OUTPUT_DIR/live_hosts.txt" 2>/dev/null
            echo -e "  ${G}✓${N} Live hosts: $(wc -l < "$OUTPUT_DIR/live_hosts.txt" 2>/dev/null || echo 0)"
        fi
        
        success "Recon complete! Results in: $OUTPUT_DIR"
        ;;
    
    port|full-scan)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "FULL PORT SCAN: ${TARGET}" "Recon" $R
        mkdir -p "$OUTPUT_DIR"
        
        # Quick port discovery
        echo -e "${C}[1/4]${N} ${G}RustScan${N} - Fast port discovery..."
        rustscan -a "$TARGET" --ulimit 5000 -g 2>/dev/null | tee "$OUTPUT_DIR/rustscan_ports.txt"
        
        # Extract open ports
        ports=$(grep -oP '\d+' "$OUTPUT_DIR/rustscan_ports.txt" 2>/dev/null | tr '\n' ',')
        [ -z "$ports" ] && ports="80,443,22,8080,3306,21,23,445,139,3389"
        
        # Detailed scan
        echo -e "${C}[2/4]${N} ${G}Nmap${N} - Service/version detection..."
        nmap -sC -sV -O -p"$ports" "$TARGET" -oN "$OUTPUT_DIR/nmap_services.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Saved"
        
        # Full port scan (if not too many ports)
        echo -e "${C}[3/4]${N} ${G}Nmap${N} - Full port scan..."
        nmap -p- --min-rate=1000 "$TARGET" -oN "$OUTPUT_DIR/nmap_allports.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Saved"
        
        # Script scan
        echo -e "${C}[4/4]${N} ${G}Nmap${N} - Vulnerability scripts..."
        nmap -sV --script vuln "$TARGET" -oN "$OUTPUT_DIR/nmap_vuln.txt" 2>/dev/null
        echo -e "  ${G}✓${N} Saved"
        
        success "Port scan complete! Results in: $OUTPUT_DIR"
        ;;
    
    tech|technology)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] URL: "${N})" TARGET
        [ -z "$TARGET" ] && { error "URL required!"; exit 1; }
        
        tool_banner "TECHNOLOGY DETECTION: ${TARGET}" "Recon" $R
        
        echo -e "${C}[1/3]${N} ${G}WhatWeb${N}..."
        whatweb -v "$TARGET" 2>/dev/null
        
        echo ""
        echo -e "${C}[2/3]${N} ${G}HTTPx${N}..."
        httpx -u "$TARGET" -status-code -title -tech-detect -follow-host-redirects 2>/dev/null
        
        echo ""
        echo -e "${C}[3/3]${N} ${G}Wappalyzer (via curl)${N}..."
        curl -sI "$TARGET" 2>/dev/null | grep -iE '(server|x-powered-by|set-cookie|content-type)'
        ;;
    
    url|endpoints)
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Domain: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Domain required!"; exit 1; }
        
        tool_banner "URL COLLECTION: ${TARGET}" "Recon" $R
        mkdir -p "$OUTPUT_DIR"
        
        echo -e "${C}[1/3]${N} ${G}GAU${N} - Get all URLs..."
        gau --subs "$TARGET" 2>/dev/null | sort -u > "$OUTPUT_DIR/gau_urls.txt"
        echo -e "  ${G}✓${N} Collected: $(wc -l < "$OUTPUT_DIR/gau_urls.txt" 2>/dev/null || echo 0) URLs"
        
        echo -e "${C}[2/3]${N} ${G}WaybackURLs${N}..."
        waybackurls "$TARGET" 2>/dev/null | sort -u > "$OUTPUT_DIR/wayback_urls.txt"
        echo -e "  ${G}✓${N} Collected: $(wc -l < "$OUTPUT_DIR/wayback_urls.txt" 2>/dev/null || echo 0) URLs"
        
        # Merge
        echo -e "${C}[3/3]${N} ${G}Merging & filtering interesting endpoints...${N}"
        cat "$OUTPUT_DIR"/*.txt 2>/dev/null | sort -u > "$OUTPUT_DIR/all_urls.txt"
        
        # Interesting endpoints
        grep -iE '(api|admin|login|signin|auth|token|key|secret|config|debug|test|backup|sql|php\?|\.env|\.git)' \
            "$OUTPUT_DIR/all_urls.txt" > "$OUTPUT_DIR/interesting_urls.txt" 2>/dev/null
        
        echo -e "  ${G}✓${N} Total unique URLs: $(wc -l < "$OUTPUT_DIR/all_urls.txt" 2>/dev/null || echo 0)"
        echo -e "  ${R}⚠${N} Interesting endpoints: $(wc -l < "$OUTPUT_DIR/interesting_urls.txt" 2>/dev/null || echo 0)"
        
        success "URL collection complete! Results in: $OUTPUT_DIR"
        ;;
    
    *)
        echo "Usage: $0 <module> [target]"
        echo ""
        echo "Modules:"
        echo "  subdomain <domain>  - Aggressive subdomain enumeration"
        echo "  port <target>       - Full port scanning (RustScan + Nmap)"
        echo "  tech <url>          - Technology stack detection"
        echo "  url <domain>        - URL/endpoint collection"
        echo ""
        echo "Examples:"
        echo "  $0 subdomain example.com"
        echo "  $0 port 192.168.1.1"
        echo "  $0 tech https://example.com"
        echo "  $0 url example.com"
        ;;
esac
