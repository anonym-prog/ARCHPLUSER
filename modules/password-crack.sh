#!/usr/bin/env bash
# ARCHPULSE - Password Cracking Module
# Hydra, John, Hashcat, Medusa, Crunch, CeWL

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

PASSWORD_WORDLIST="$HOME/archpulse/wordlists/rockyou.txt"
[ ! -f "$PASSWORD_WORDLIST" ] && PASSWORD_WORDLIST="/usr/share/wordlists/rockyou.txt"

header "🟣 PASSWORD CRACKING TOOLKIT" $P

case "${1,,}" in
    hydra|brute-force)
        SERVICE="${2:-ssh}"
        TARGET="${3}"
        USER="${4:-root}"
        WORDLIST="${5:-$PASSWORD_WORDLIST}"
        
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "HYDRA - ${SERVICE} Brute Force" "Password" $P
        info "Service: $SERVICE | Target: $TARGET | User: $USER"
        info "Wordlist: $WORDLIST"
        echo ""
        hydra -l "$USER" -P "$WORDLIST" "$SERVICE://$TARGET" -t 4 -V
        ;;
    
    john|john-the-ripper)
        HASHFILE="${2}"
        WORDLIST="${3:-$PASSWORD_WORDLIST}"
        
        [ -z "$HASHFILE" ] && read -p "$(echo -e ${Y}"[?] Hash file: "${N})" HASHFILE
        [ -z "$HASHFILE" ] && { error "Hash file required!"; exit 1; }
        
        tool_banner "JOHN THE RIPPER" "Password" $P
        info "Hash file: $HASHFILE"
        info "Wordlist: $WORDLIST"
        echo ""
        
        # Identify hash type
        echo -e "${C}[${ARROW}]${N} Identifying hash type..."
        hash-identifier -f "$HASHFILE" 2>/dev/null || info "Run: hash-identifier"
        
        # Crack
        john "$HASHFILE" --wordlist="$WORDLIST" --format=auto
        echo ""
        john --show "$HASHFILE"
        ;;
    
    hashcat)
        HASHFILE="${2}"
        MODE="${3:-0}"  # 0=MD5, 100=NTLM, 1000=NTLMv2, 1400=SHA256
        WORDLIST="${4:-$PASSWORD_WORDLIST}"
        
        [ -z "$HASHFILE" ] && read -p "$(echo -e ${Y}"[?] Hash file: "${N})" HASHFILE
        [ -z "$HASHFILE" ] && { error "Hash file required!"; exit 1; }
        
        tool_banner "HASHCAT - GPU Accelerated" "Password" $P
        info "Hash file: $HASHFILE | Mode: $MODE"
        info "Wordlist: $WORDLIST"
        echo -e "${Y}Common modes: 0=MD5, 100=SHA1, 1400=SHA256, 1000=NTLM, 5500=NetNTLMv2${N}"
        echo ""
        hashcat -m "$MODE" "$HASHFILE" "$WORDLIST" --force -O -w 4
        echo ""
        hashcat -m "$MODE" "$HASHFILE" --show
        ;;
    
    medusa)
        SERVICE="${2:-ssh}"
        TARGET="${3}"
        USER="${4:-root}"
        WORDLIST="${5:-$PASSWORD_WORDLIST}"
        
        [ -z "$TARGET" ] && read -p "$(echo -e ${Y}"[?] Target: "${N})" TARGET
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        
        tool_banner "MEDUSA - Parallel Brute Forcer" "Password" $P
        medusa -h "$TARGET" -u "$USER" -P "$WORDLIST" -M "$SERVICE" -t 5 -f
        ;;
    
    crunch|wordlist-gen)
        MIN="${2:-8}"
        MAX="${3:-12}"
        CHARSET="${4:-abcdefghijklmnopqrstuvwxyz0123456789}"
        OUTPUT="${5:-$HOME/archpulse/wordlists/crunch_$(date +%Y%m%d).txt}"
        
        tool_banner "CRUNCH - Wordlist Generator" "Password" $P
        info "Min: $MIN | Max: $MAX | Charset: ${CHARSET:0:20}..."
        info "Output: $OUTPUT"
        echo ""
        crunch "$MIN" "$MAX" "$CHARSET" -o "$OUTPUT"
        success "Wordlist generated: $OUTPUT ($(wc -l < "$OUTPUT") words)"
        ;;
    
    cewl|url-wordlist)
        URL="${2}"
        MIN_WORD="${3:-6}"
        OUTPUT="${4:-$HOME/archpulse/wordlists/cewl_$(date +%Y%m%d).txt}"
        
        [ -z "$URL" ] && read -p "$(echo -e ${Y}"[?] Target URL: "${N})" URL
        [ -z "$URL" ] && { error "URL required!"; exit 1; }
        
        tool_banner "CEWL - Custom Wordlist from URL" "Password" $P
        cewl "$URL" -m "$MIN_WORD" -w "$OUTPUT"
        success "Wordlist generated: $OUTPUT ($(wc -l < "$OUTPUT") words)"
        ;;
    
    *)
        echo "Usage: $0 <module> [options]"
        echo ""
        echo "Modules:"
        echo "  hydra <service> <target> [user] [wordlist]     - Network brute-force"
        echo "  john <hashfile> [wordlist]                     - John the Ripper"
        echo "  hashcat <hashfile> [mode] [wordlist]           - GPU hash cracking"
        echo "  medusa <service> <target> [user] [wordlist]    - Medusa brute-force"
        echo "  crunch <min> <max> <charset> [output]          - Wordlist generator"
        echo "  cewl <url> [min_word] [output]                 - URL-based wordlist"
        echo ""
        echo "Examples:"
        echo "  $0 hydra ssh 192.168.1.1 root"
        echo "  $0 john hashes.txt"
        echo "  $0 hashcat hashes.txt 1000"
        echo "  $0 crunch 8 12 abc123"
        echo "  $0 cewl https://example.com"
        ;;
esac
