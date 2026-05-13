#!/usr/bin/env bash
# ARCHPULSE - BurpSuite Manager
# Install, configure and launch BurpSuite Community Edition

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$SCRIPT_DIR/colors.sh"

BURP_DIR="$HOME/archpulse/configs/burpsuite"
BURP_JAR="$BURP_DIR/burpsuite_community.jar"
BURP_LAUNCHER="/usr/local/bin/burpsuite"

header "🔶 BURPSUITE MANAGER" $Y

case "${1,,}" in
    install)
        tool_banner "INSTALLING BURPSUITE" "BurpSuite" $Y
        
        # Check Java
        if ! command -v java &>/dev/null; then
            info "Java not found. Installing..."
            sudo pacman -S --noconfirm jre17-openjdk 2>/dev/null || {
                error "Could not install Java. Install manually: sudo pacman -S jre17-openjdk"
                exit 1
            }
        fi
        
        java_ver=$(java -version 2>&1 | head -1 | grep -oP '\d+\.\d+\.\d+' | cut -d. -f1)
        if [ "$java_ver" -lt 17 ] 2>/dev/null; then
            warning "Java $java_ver detected. BurpSuite requires Java 17+"
            info "Install: sudo pacman -S jre17-openjdk"
            info "Then: sudo archlinux-java set java-17-openjdk"
            read -p "$(echo -e ${Y}"Continue anyway? (y/N): "${N})" cont
            [ "$cont" != "y" ] && exit 1
        fi
        
        mkdir -p "$BURP_DIR"
        
        # Download BurpSuite Community
        info "Downloading BurpSuite Community Edition..."
        
        # Get download page
        DOWNLOAD_URL=$(curl -s "https://portswigger.net/burp/releases" | \
            grep -oP 'https://portswigger.net/burp/releases/download[^"]*community[^"]*\.jar' | head -1)
        
        if [ -z "$DOWNLOAD_URL" ]; then
            # Fallback to direct URL
            DOWNLOAD_URL="https://portswigger.net/burp/releases/download?product=community&version=2025.1.1&type=jar"
            warning "Could not find latest version. Attempting fallback..."
        fi
        
        info "Downloading from: $DOWNLOAD_URL"
        curl -L -o "$BURP_JAR" "$DOWNLOAD_URL" --progress-bar
        
        if [ -f "$BURP_JAR" ] && [ -s "$BURP_JAR" ]; then
            success "Downloaded BurpSuite to $BURP_JAR"
            chmod +x "$BURP_JAR"
        else
            error "Download failed! Try manually from: https://portswigger.net/burp/communitydownload"
            exit 1
        fi
        
        # Create launcher script
        info "Creating launcher script..."
        sudo bash -c "cat > $BURP_LAUNCHER" << EOF
#!/bin/bash
java -jar "$BURP_JAR" "\$@"
EOF
        sudo chmod +x "$BURP_LAUNCHER"
        
        # Create desktop entry
        DESKTOP_FILE="$HOME/.local/share/applications/burpsuite.desktop"
        mkdir -p "$HOME/.local/share/applications"
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=BurpSuite Community
Comment=Web Application Security Testing
Exec=$BURP_LAUNCHER
Icon=$BURP_DIR/burp_icon.png
Terminal=false
Type=Application
Categories=Development;Security;
EOF
        
        success "BurpSuite installed successfully!"
        info "Launch: burpsuite"
        info "Or use: archpulse burp"
        ;;
    
    launch|start)
        if [ ! -f "$BURP_JAR" ]; then
            error "BurpSuite not installed! Run: $0 install"
            exit 1
        fi
        
        tool_banner "LAUNCHING BURPSUITE" "BurpSuite" $Y
        info "Starting in background..."
        nohup java -jar "$BURP_JAR" > /dev/null 2>&1 &
        BURP_PID=$!
        success "BurpSuite launched (PID: $BURP_PID)"
        info "Access proxy at: 127.0.0.1:8080"
        info "To stop: kill $BURP_PID"
        ;;
    
    proxy-setup)
        tool_banner "PROXY SETUP" "BurpSuite" $Y
        
        echo -e "${C}┌─────────────────────────────────────────────────────────┐${N}"
        echo -e "${C}│${N} ${Y}Firefox Proxy Configuration:${N}                           ${C}│${N}"
        echo -e "${C}│${N}                                                       ${C}│${N}"
        echo -e "${C}│${N} ${G}1.${N} Firefox → Settings → Network Settings            ${C}│${N}"
        echo -e "${C}│${N} ${G}2.${N} Select 'Manual proxy configuration'              ${C}│${N}"
        echo -e "${C}│${N} ${G}3.${N} HTTP Proxy: ${Y}127.0.0.1${N}  Port: ${Y}8080${N}              ${C}│${N}"
        echo -e "${C}│${N} ${G}4.${N} ✓ 'Also use this proxy for HTTPS'               ${C}│${N}"
        echo -e "${C}│${N} ${G}5.${N} ✓ 'Also proxy DNS requests when possible'        ${C}│${N}"
        echo -e "${C}│${N}                                                       ${C}│${N}"
        echo -e "${C}│${N} ${Y}BurpSuite Proxy Settings:${N}                              ${C}│${N}"
        echo -e "${C}│${N} ${G}1.${N} Proxy → Proxy Settings → Add                     ${C}│${N}"
        echo -e "${C}│${N} ${G}2.${N} Bind to: ${Y}127.0.0.1:8080${N}                         ${C}│${N}"
        echo -e "${C}│${N} ${G}3.${N} ✓ 'Support invisible proxying'                    ${C}│${N}"
        echo -e "${C}│${N}                                                       ${C}│${N}"
        echo -e "${C}│${N} ${Y}FoxyProxy Addon (recommended):${N}                         ${C}│${N}"
        echo -e "${C}│${N} ${G}→${N} https://addons.mozilla.org/firefox/addon/foxyproxy-standard/${N} ${C}"
        echo -e "${C}└─────────────────────────────────────────────────────────┘${N}"
        ;;
    
    cert|ca-cert)
        tool_banner "CA CERTIFICATE INSTALLATION" "BurpSuite" $Y
        
        echo -e "${C}To install Burp's CA certificate for HTTPS inspection:${N}"
        echo ""
        echo -e " ${G}1.${N} Ensure Burp proxy is running (${Y}127.0.0.1:8080${N})"
        echo -e " ${G}2.${N} Configure browser proxy to 127.0.0.1:8080"
        echo -e " ${G}3.${N} Browse to: ${Y}http://127.0.0.1:8080/${N}"
        echo -e " ${G}4.${N} Click ${Y}'CA Certificate'${N} (top-right corner)"
        echo -e " ${G}5.${N} Save the ${Y}cacert.der${N} file"
        echo -e " ${G}6.${N} Firefox → Settings → Privacy & Security → Certificates"
        echo -e " ${G}7.${N} Import → Select ${Y}cacert.der${N}"
        echo -e " ${G}8.${N} ✓ 'Trust this CA to identify websites'"
        echo -e " ${G}9.${N} ✓ 'Trust this CA to identify email users'"
        echo ""
        info "Certificate will be used for HTTPS interception"
        ;;
    
    update)
        tool_banner "UPDATE BURPSUITE" "BurpSuite" $Y
        info "Re-running installation to update..."
        "$0" install
        ;;
    
    check|status)
        tool_banner "BURPSUITE STATUS" "BurpSuite" $Y
        
        echo -e "${C}Java:${N}"
        java -version 2>&1 | head -1
        echo ""
        
        echo -e "${C}BurpSuite JAR:${N}"
        if [ -f "$BURP_JAR" ]; then
            echo -e "  ${G}✓${N} $BURP_JAR ($(du -h "$BURP_JAR" | cut -f1))"
        else
            echo -e "  ${R}✗${N} Not installed"
        fi
        echo ""
        
        echo -e "${C}Launcher:${N}"
        if [ -f "$BURP_LAUNCHER" ]; then
            echo -e "  ${G}✓${N} $BURP_LAUNCHER"
        else
            echo -e "  ${R}✗${N} Not configured"
        fi
        echo ""
        
        echo -e "${C}Running instances:${N}"
        pgrep -f burpsuite 2>/dev/null && \
        echo -e "  ${G}✓${N} BurpSuite is running (PID: $(pgrep -f 'burpsuite.*jar'))" || \
        echo -e "  ${Y}✗${N} Not running"
        ;;
    
    *)
        echo "Usage: $0 <action>"
        echo ""
        echo "Actions:"
        echo "  install       - Install/Download BurpSuite Community"
        echo "  launch|start  - Launch BurpSuite"
        echo "  proxy-setup   - Show browser proxy configuration"
        echo "  cert|ca-cert  - Show CA certificate installation steps"
        echo "  update        - Update to latest version"
        echo "  check|status  - Check installation status"
        echo ""
        echo "Examples:"
        echo "  $0 install       # Install BurpSuite"
        echo "  $0 launch        # Start BurpSuite"
        echo "  $0 proxy-setup   # Show proxy config"
        ;;
esac
