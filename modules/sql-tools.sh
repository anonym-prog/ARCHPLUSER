#!/usr/bin/env bash
# ARCHPULSE - SQL Tools Module

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

header "⚪ SQL INJECTION TOOLKIT" $G

case "${1,,}" in
    sqlmap)
        URL="${2}"
        [ -z "$URL" ] && read -p "$(echo -e ${Y}"[?] Target URL: "${N})" URL
        [ -z "$URL" ] && { error "URL required!"; exit 1; }
        
        tool_banner "SQLMAP - SQL Injection" "SQL" $G
        info "Available tamper scripts:"
        ls /usr/share/sqlmap/tamper/ 2>/dev/null | head -10
        echo ""
        
        read -p "$(echo -e ${Y}"[?] Additional options (--data, --cookie, etc): "${N})" opts
        echo ""
        
        sqlmap -u "$URL" $opts --batch --random-agent \
            --level=3 --risk=2 \
            --tamper=space2comment \
            --output-dir="$HOME/archpulse/reports/sqlmap_$(date +%Y%m%d)"
        ;;
    
    nosqlmap)
        URL="${2}"
        [ -z "$URL" ] && read -p "$(echo -e ${Y}"[?] Target URL: "${N})" URL
        [ -z "$URL" ] && { error "URL required!"; exit 1; }
        
        tool_banner "NOSQLMAP - NoSQL Injection" "SQL" $G
        nosqlmap --url "$URL" 2>/dev/null || \
        python3 /usr/share/nosqlmap/nosqlmap.py --url "$URL" 2>/dev/null || \
        error "NoSQLMap not properly installed"
        ;;
    
    bbqsql)
        tool_banner "BBQSQL - Blind SQL Injection" "SQL" $G
        bbqsql 2>/dev/null || python3 /usr/share/bbqsql/bbqsql.py 2>/dev/null || \
        error "BBQSQL not found"
        ;;
    
    *)
        echo "Usage: $0 <module> [target]"
        echo ""
        echo "Modules:"
        echo "  sqlmap <url> [opts]       - SQL injection automation"
        echo "  nosqlmap <url>            - NoSQL injection"
        echo "  bbqsql                    - Blind SQL injection framework"
        echo ""
        echo "Examples:"
        echo "  $0 sqlmap 'http://target.com/page?id=1'"
        echo "  $0 nosqlmap 'http://target.com/api/search'"
        ;;
esac
