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
> **Author:** [adalah pokok nya]
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

## 📊 50 TOOLS OVERVIEW

### 🔴 Reconnaissance (10)
`nmap` `rustscan` `masscan` `subfinder` `amass` `httpx` `nuclei` `assetfinder` `findomain` `dnsx/naabu`

### 🟡 Scanner (10)
`nikto` `whatweb` `wfuzz` `ffuf` `dirsearch` `gobuster` `gospider` `hakrawler` `wapiti` `skipfish`

### 🟢 Exploit (10)
`metasploit` `sqlmap` `commix` `beef-xss` `routersploit` `searchsploit` `xsstrike` `shellnoob` `exploitdb` `hydra`

### 🔵 Enumeration (7)
`enum4linux` `smbclient` `snmpwalk` `dnsenum` `dnsrecon` `ldapsearch` `linpeas/linenum`

### 🟣 Password Cracking (6)
`hydra` `john` `hashcat` `crunch` `cewl` `medusa`

### 🟠 Network/MITM (4)
`bettercap` `aircrack-ng` `mdk4` `pixiewps`

### 🔶 Web App/SQL (3)
`burpsuite` `nosqlmap` `bbqsql`
