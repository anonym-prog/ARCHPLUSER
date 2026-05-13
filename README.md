# ⚡ ARCHPULSE — ArchLinux Pentesting Arsenal v2.0

╔══════════════════════════════════════════════════════════════════╗
║    █████╗ ██████╗  ██████╗██╗  ██╗██████╗ ██╗   ██╗██╗     ██╗  ║
║   ██╔══██╗██╔══██╗██╔════╝██║  ██║██╔══██╗██║   ██║██║     ██║  ║
║   ███████║██████╔╝██║     ███████║██████╔╝██║   ██║██║     ██║  ║
║   ██╔══██║██╔══██╗██║     ██╔══██║██╔══██╗██║   ██║██║     ██║  ║
║   ██║  ██║██║  ██║╚██████╗██║  ██║██████╔╝╚██████╔╝███████╗███████╗
║   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝╚══════╝
║                                                                      ║
║   🔴 RECON    🟡 SCANNER    🟢 EXPLOIT    🔵 ENUM    🟣 PASSWORD   ║
║   ⚡ Bettercap • SQLMap • Metasploit • BurpSuite • Hydra • Nmap ⚡  ║
╚══════════════════════════════════════════════════════════════════════╝

> **Authorized Pentesting Framework — Arch Linux / BlackArch**
> **Author:** [Your Username]
> **Version:** 2.0 | **Distro:** Arch Linux + BlackArch Repo

---

## 🔥 CORE FEATURES

| Modul | Tools Included | Total |
|-------|---------------|-------|
| 🔴 **Recon** | Nmap, RustScan, Masscan, Subfinder, Amass, Assetfinder, Findomain, DNSx, Naabu, Httpx, Nuclei, Gau, Waybackurls | **13** |
| 🟡 **Scanner** | Nikto, WhatWeb, Wfuzz, Ffuf, Dirsearch, Gobuster, Gospider, Hakrawler, Skipfish, Arachni, Wapiti, OpenVAS | **12** |
| 🟢 **Exploit** | Metasploit, SQLMap, Commix, BeEF, RouterSploit, Searchsploit, XSStrike, Shellnoob, ExploitDB, CVE-Search | **10** |
| 🔵 **Enumeration** | Enum4linux, SMBClient, SNMPWalk, DNSEnum, Dnsrecon, LDAPSearch, NBTScan, OSRFScanner, WFuzz-Enums, LinEnum, PEAS | **11** |
| 🟣 **Password** | Hydra, John, Hashcat, Medusa, Crunch, Hash-Identifier, RSMangler, CeWL, Statsgen, Kwprocessor | **10** |
| 🟠 **Bettercap** | MITM, ARP Spoof, DNS Spoof, HTTP Proxy, HTTPS Proxy, Sniffer, Credential Harvest | **7 modules** |
| 🔶 **BurpSuite** | Proxy, Repeater, Intruder, Decoder, Sequencer, Scanner, Extender | **7 modules** |
| ⚪ **SQL Tools** | SQLMap, SQLNinja, SQLBrute, BBQSQL, NoSQLMap, HQLMap | **6** |

**Total: 60+ Tools • 8 Module Categories**

---

## ⚡ INSTALLATION

### 📥 Method 1: Automatic (Recommended)

```bash
# Clone
git clone https://github.com/[username]/ARCHPULSE.git
cd ARCHPULSE

# Make executable
chmod +x install.sh setup.sh modules/*.sh scripts/*.sh

# Run installer
./install.sh
