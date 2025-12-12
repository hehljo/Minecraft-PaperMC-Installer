#!/bin/bash
###############################################################################
# Minecraft PaperMC + Crossplay Server Installation Script - DYNAMIC VERSION
# Für Debian basierte Systeme (Debian, Ubuntu)
# Version: 3.0 - Dynamische Systemerkennung + Interaktive Plugin-Auswahl
# Datum: 2025-12-05
###############################################################################

###############################################################################
# KONFIGURATION (Standardwerte, werden dynamisch überschrieben)
###############################################################################
MINECRAFT_USER="minecraft"
MINECRAFT_HOME="/opt/minecraft"
MINECRAFT_PORT="25565"
BEDROCK_PORT="19132"
MAX_PLAYERS="10"
VIEW_DISTANCE="8"
SIMULATION_DISTANCE="5"
PAPER_VERSION="1.21" # Lädt die neueste 1.21.x Version
LOG_FILE="/var/log/minecraft-install.log"

# Dynamisch ermittelte Werte
SERVER_IP=""
JAVA_MEMORY=""
CPU_CORES=""

###############################################################################
# FARBEN
###############################################################################
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

###############################################################################
# LOGGING
###############################################################################
log() {
    # Stellt sicher, dass die Log-Datei dem ausführenden User gehört (falls sudo verwendet wird)
    touch "$LOG_FILE"
    chown "$(logname)" "$LOG_FILE"
    echo -e "${CYAN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[i]${NC} $1" | tee -a "$LOG_FILE"
}

log_skip() {
    echo -e "${YELLOW}[⊘]${NC} $1 ${YELLOW}(übersprungen)${NC}" | tee -a "$LOG_FILE"
}

###############################################################################
# FEHLERBEHANDLUNG
###############################################################################
handle_error() {
    log_error "Ein Fehler ist in Zeile $1 aufgetreten. Das Skript wird abgebrochen."
    exit 1
}

trap 'handle_error $LINENO' ERR

###############################################################################
# DYNAMISCHE SYSTEMERKENNUNG
###############################################################################
detect_system_specs() {
    log "Ermittle System-Spezifikationen..."

    # IP-Adresse ermitteln
    SERVER_IP=$(hostname -I | awk '{print $1}')
    if [[ -z "$SERVER_IP" ]]; then
        log_warning "Konnte primäre IP-Adresse nicht automatisch ermitteln. Fällt zurück auf 127.0.0.1."
        log_warning "Bitte 'server-ip' in der server.properties manuell anpassen!"
        SERVER_IP="127.0.0.1"
    fi
    log_success "IP-Adresse erkannt: $SERVER_IP"

    # Verfügbaren RAM ermitteln und Java Heap Size berechnen
    local total_ram_mb
    total_ram_mb=$(free -m | awk '/^Mem:/{print $2}')
    
    if [[ "$total_ram_mb" -gt 2048 ]]; then
        # 1.5GB für das OS lassen
        JAVA_MEMORY=$((total_ram_mb - 1536))
    else
        # 512MB für das OS lassen
        JAVA_MEMORY=$((total_ram_mb - 512))
    fi

    if [[ "$JAVA_MEMORY" -lt 1024 ]]; then
        log_warning "Weniger als 1GB RAM für Minecraft verfügbar. Dies kann zu Problemen führen."
        JAVA_MEMORY=1024 # Mindestens 1GB zuweisen
    fi
    log_success "RAM für Java berechnet: ${JAVA_MEMORY}M"

    # CPU-Kerne ermitteln
    CPU_CORES=$(nproc)
    log_success "CPU-Kerne erkannt: $CPU_CORES"
}


###############################################################################
# BANNER
###############################################################################
banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   Minecraft PaperMC Server Installer v3.0 - Dynamische Edition  ║"
    echo "║        Erkennt automatisch System-Spezifikationen             ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    log_info "Installation gestartet..."
    log_info "Minecraft User: $MINECRAFT_USER"
    log_info "Installation Home: $MINECRAFT_HOME"
}

###############################################################################
# ROOT-CHECK
###############################################################################
check_root() {
    log "Prüfe Root-Rechte..."
    if [[ $EUID -ne 0 ]]; then
        log_error "Dieses Skript muss als Root ausgeführt werden!"
        log_info "Bitte ausführen mit: sudo bash $0"
        exit 1
    fi
    log_success "Root-Rechte vorhanden"
}

###############################################################################
# DEBIAN CHECK
###############################################################################
check_debian() {
    log "Prüfe Debian-basiertes System..."
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "debian" || "$ID_LIKE" == "debian" ]]; then
            log_success "System ist Debian-basiert ($PRETTY_NAME)"
            return 0
        fi
    fi
    log_error "Dieses Skript ist für Debian-basierte Systeme (Debian, Ubuntu, etc.) optimiert."
    exit 1
}

###############################################################################
# SCREEN FIX - KRITISCH!
###############################################################################
fix_screen_permissions() {
    log "Behebe Screen-Permissions Problem..."

    # Erstelle /run/screen mit korrekten Permissions
    if [[ ! -d /run/screen ]]; then
        mkdir -p /run/screen
    fi

    # Setze 777 (wie vom Script verlangt)
    chmod 777 /run/screen
    chown root:root /run/screen

    # Persistent machen
    cat > /etc/tmpfiles.d/screen.conf << EOF
d /run/screen 0777 root root -
EOF

    # Anwenden
    if command -v systemd-tmpfiles &>/dev/null; then
        systemd-tmpfiles --create /etc/tmpfiles.d/screen.conf 2>/dev/null || true
    fi

    # Verify
    if [[ -d /run/screen ]]; then
        local perms=$(stat -c "%a" /run/screen)
        if [[ "$perms" == "777" ]]; then
            log_success "Screen-Permissions korrekt gesetzt (777)"
        else
            log_warning "Screen-Permissions: $perms (erwartet: 777)"
        fi
    fi
}

###############################################################################
# SYSTEM UPDATE
###############################################################################
update_system() {
    log "System-Update durchführen..."

    # Deaktiviere Exit-bei-Fehler temporär
    set +e

    export DEBIAN_FRONTEND=noninteractive

    if apt-get update >> "$LOG_FILE" 2>&1; then
        log_success "APT Cache aktualisiert"
    else
        log_warning "APT Update hatte Warnungen (fahre fort)"
    fi

    log "Installiere System-Upgrades..."
    # apt-get -y dist-upgrade can be risky, so we use a safer upgrade.
    apt-get upgrade -y >> "$LOG_FILE" 2>&1
    log_success "System aktualisiert"

    # Reaktiviere Exit-bei-Fehler
    set -e
}

###############################################################################
# DEPENDENCIES
###############################################################################
install_dependencies() {
    log "Installiere Basis-Pakete..."

    local packages=(
        "curl"
        "wget"
        "nano"
        "htop"
        "screen"
        "sudo"
        "ufw"
        "git"
        "gnupg2"
        "apt-transport-https"
        "ca-certificates"
        "tar"
        "gzip"
        "jq"
        "unzip"
        "procps"
    )

    local needed_packages=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -l 2>/dev/null | grep -q "^ii  $pkg "; then
            needed_packages+=("$pkg")
        else
             log_skip "$pkg bereits installiert"
        fi
    done

    if [ ${#needed_packages[@]} -gt 0 ]; then
        log "Installiere folgende Pakete: ${needed_packages[*]}..."
        DEBIAN_FRONTEND=noninteractive apt-get install -y "${needed_packages[@]}" >> "$LOG_FILE" 2>&1
        log_success "Alle Basis-Pakete sind installiert."
    else
        log_success "Alle Basis-Pakete waren bereits installiert."
    fi
}

###############################################################################
# TIMEZONE
###############################################################################
set_timezone() {
    log "Setze Timezone auf Europe/Berlin..."
    set +e
    if timedatectl set-timezone Europe/Berlin >> "$LOG_FILE" 2>&1; then
        log_success "Timezone gesetzt: Europe/Berlin"
    else
        log_warning "Timezone konnte nicht gesetzt werden"
    fi
    set -e
}

###############################################################################
# JAVA INSTALLATION
###############################################################################
install_java() {
    log "Prüfe Java Installation..."

    # Minecraft 1.21.x benötigt Java 21
    local required_java_version=21 

    if command -v java &> /dev/null; then
        local java_version
        java_version=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
        if [[ "$java_version" == "${required_java_version}"* ]]; then
            log_skip "Java ${required_java_version} bereits installiert: $java_version"
            return 0
        else
            log_warning "Falsche Java-Version gefunden ($java_version). Installiere Version ${required_java_version}."
        fi
    fi

    log "Installiere Java ${required_java_version}..."

    set +e

    # Versuche zuerst das Standard-Debian-Paket
    if DEBIAN_FRONTEND=noninteractive apt-get install -y "openjdk-${required_java_version}-jre-headless" >> "$LOG_FILE" 2>&1; then
        log_success "OpenJDK ${required_java_version} installiert"
    else
        log_info "Standard OpenJDK-Paket nicht gefunden, versuche Amazon Corretto..."
        # Corretto Repository hinzufügen
        wget -q -O- https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list
        apt-get update >> "$LOG_FILE" 2>&1

        if DEBIAN_FRONTEND=noninteractive apt-get install -y "java-${required_java_version}-amazon-corretto-jdk" >> "$LOG_FILE" 2>&1; then
            log_success "Amazon Corretto ${required_java_version} installiert"
        else
            log_error "Konnte keine passende Java-Version installieren."
            exit 1
        fi
    fi
    set -e

    # Verify
    if command -v java &> /dev/null; then
        log_success "Java installiert: $(java -version 2>&1 | head -n 1)"
    else
        log_error "Java Installation fehlgeschlagen"
        exit 1
    fi
}

###############################################################################
# MINECRAFT USER
###############################################################################
create_minecraft_user() {
    log "Erstelle Minecraft User..."

    if id "$MINECRAFT_USER" &>/dev/null; then
        log_skip "User '$MINECRAFT_USER' existiert bereits"
    else
        useradd -r -m -U -d "$MINECRAFT_HOME" -s /bin/bash "$MINECRAFT_USER" >> "$LOG_FILE" 2>&1
        log_success "User '$MINECRAFT_USER' erstellt"
    fi

    # Home-Dir sicherstellen
    if [[ ! -d "$MINECRAFT_HOME" ]]; then
        mkdir -p "$MINECRAFT_HOME"
    fi
    chown -R "$MINECRAFT_USER:$MINECRAFT_USER" "$MINECRAFT_HOME"
}

###############################################################################
# PAPER DOWNLOAD
###############################################################################
download_paper() {
    log "Lade PaperMC Server herunter..."
    
    cd "$MINECRAFT_HOME"

    if [[ -f "$MINECRAFT_HOME/paper.jar" ]]; then
        log_skip "paper.jar existiert bereits. Überspringe Download."
        return 0
    fi

    log_info "Ermittle neueste Paper Build für Minecraft-Version $PAPER_VERSION..."
    local paper_api_url="https://api.papermc.io/v2/projects/paper/versions/${PAPER_VERSION}"
    
    local latest_build
    latest_build=$(curl -s "$paper_api_url" | jq -r '.builds | last')

    if [[ -z "$latest_build" || "$latest_build" == "null" ]]; then
        log_error "Konnte keine Build für Paper $PAPER_VERSION finden."
        exit 1
    fi

    log_info "Neueste Build-Nummer ist #$latest_build."
    local jar_name="paper-${PAPER_VERSION}-${latest_build}.jar"
    local download_url="${paper_api_url}/builds/${latest_build}/downloads/${jar_name}"

    log_info "Lade $jar_name herunter..."
    if ! curl -L -o paper.jar "$download_url"; then
        log_error "Download von PaperMC fehlgeschlagen."
        exit 1
    fi

    chown "$MINECRAFT_USER:$MINECRAFT_USER" paper.jar
    log_success "PaperMC (Build #$latest_build) heruntergeladen."
}

###############################################################################
# START SCRIPT
###############################################################################
create_start_script() {
    log "Erstelle optimiertes Start-Script..."

    local start_script="$MINECRAFT_HOME/start.sh"

    # Aikar's Flags: https://mcflags.emc.gs
    cat > "$start_script" << EOF
#!/bin/bash
cd "$MINECRAFT_HOME"

java -Xms${JAVA_MEMORY}M -Xmx${JAVA_MEMORY}M \\
  -XX:+UseG1GC \\
  -XX:+ParallelRefProcEnabled \\
  -XX:MaxGCPauseMillis=200 \\
  -XX:+UnlockExperimentalVMOptions \\
  -XX:+DisableExplicitGC \\
  -XX:+AlwaysPreTouch \\
  -XX:G1NewSizePercent=30 \\
  -XX:G1MaxNewSizePercent=40 \\
  -XX:G1HeapRegionSize=8M \\
  -XX:G1ReservePercent=20 \\
  -XX:G1HeapWastePercent=5 \\
  -XX:G1MixedGCCountTarget=4 \\
  -XX:InitiatingHeapOccupancyPercent=15 \\
  -XX:G1MixedGCLiveThresholdPercent=90 \\
  -XX:G1RSetUpdatingPauseTimePercent=5 \\
  -XX:SurvivorRatio=32 \\
  -XX:+PerfDisableSharedMem \\
  -XX:MaxTenuringThreshold=1 \\
  -Dusing.aikars.flags=https://mcflags.emc.gs \\
  -Daikars.new.flags=true \\
  -jar paper.jar --nogui
EOF

    chmod +x "$start_script"
    chown "$MINECRAFT_USER:$MINECRAFT_USER" "$start_script"
    log_success "Start-Script erstellt: $start_script"
}

# Plugin-Auswahl
INSTALL_GEYSER=false
INSTALL_ESSENTIALS=false
INSTALL_LUCKPERMS=false
INSTALL_BENTOBOX=false
INSTALL_MULTIWORLD=false
INSTALL_PL3XMAP=false
INSTALL_VAULT=false
INSTALL_CHESTSHOP=false
INSTALL_WORLDGUARD=false

###############################################################################
# EULA
###############################################################################
accept_eula() {
    log "Akzeptiere Minecraft EULA..."

    local eula_file="$MINECRAFT_HOME/eula.txt"

    if [[ -f "$eula_file" ]] && grep -q "eula=true" "$eula_file"; then
        log_skip "EULA bereits akzeptiert"
        return 0
    fi

    echo "eula=true" > "$eula_file"
    chown "$MINECRAFT_USER:$MINECRAFT_USER" "$eula_file"
    log_success "EULA akzeptiert"
}

###############################################################################
# INTERAKTIVE PLUGIN-AUSWAHL
###############################################################################
prompt_for_plugins() {
    echo ""
    log_info "Plugin-Auswahl (j/n)"
    echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
    
    local response
    
    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} Cross-Play (Geyser & Floodgate) installieren? (Empfohlen) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_GEYSER=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_GEYSER=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done

    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} EssentialsX (Nützliche Admin-Befehle) installieren? (Empfohlen) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_ESSENTIALS=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_ESSENTIALS=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done

    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} LuckPerms (Rechte-Verwaltung) installieren? (Dringend empfohlen) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_LUCKPERMS=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_LUCKPERMS=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done
    
    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} BentoBox (für OneBlock Spielmodus) installieren? [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_BENTOBOX=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_BENTOBOX=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done

    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} MultiWorld (Mehrere Welten verwalten) installieren? (Empfohlen) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_MULTIWORLD=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_MULTIWORLD=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done

    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} Pl3xMap (Live-Karte im Browser) installieren? (Empfohlen) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_PL3XMAP=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_PL3XMAP=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done

    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} Vault (Economy-API) installieren? (Basis für Shop-Plugins) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_VAULT=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_VAULT=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done

    if [[ "$INSTALL_VAULT" = true ]]; then
        while true; do
            read -r -p "$(echo -e "${BLUE}[?]${NC} ChestShop (Spieler-Shops mit Truhen) installieren? [j/n]: ")" response
            case "$response" in
                [jJ][aA]|[jJ]|"") INSTALL_CHESTSHOP=true; break ;;
                [nN][eE][iI][nN]|[nN]) INSTALL_CHESTSHOP=false; break ;;
                *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
            esac
        done
    else
        INSTALL_CHESTSHOP=false
        log_info "ChestShop übersprungen (benötigt Vault)"
    fi

    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} WorldGuard (Grundstücksschutz) installieren? (Empfohlen) [j/n]: ")" response
        case "$response" in
            [jJ][aA]|[jJ]|"") INSTALL_WORLDGUARD=true; break ;;
            [nN][eE][iI][nN]|[nN]) INSTALL_WORLDGUARD=false; break ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done
    echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
}

###############################################################################
# PLUGINS
###############################################################################
download_plugins() {
    log "Lade ausgewählte Plugins herunter..."

    local plugins_dir="$MINECRAFT_HOME/plugins"
    mkdir -p "$plugins_dir"
    cd "$plugins_dir"
    
    local download_count=0

    # Funktion zum Herunterladen einer Datei
    download_file() {
        local file_name="$1"
        local download_url="$2"
        
        log_info "Lade $file_name herunter..."
        if ! curl -L -s -o "$file_name" "$download_url" || [[ ! -s "$file_name" ]]; then
            log_error "$file_name konnte nicht heruntergeladen werden von: $download_url"
            # Lösche die leere Datei, falls sie erstellt wurde
            rm -f "$file_name"
            return 1
        fi
        log_success "$file_name erfolgreich heruntergeladen."
        ((download_count++))
    }

    if [[ "$INSTALL_GEYSER" = true ]]; then
        log_info "Geyser benötigt Floodgate (wird automatisch mitinstalliert)"
        download_file "Geyser-Spigot.jar" "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot"
        download_file "floodgate-spigot.jar" "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot"
    fi

    if [[ "$INSTALL_ESSENTIALS" = true ]]; then
        local essentials_url
        essentials_url=$(curl -s https://api.github.com/repos/EssentialsX/Essentials/releases/latest | jq -r '.assets[] | select(.name | test("^EssentialsX-[0-9.]+\\.jar$")) | .browser_download_url')
        if [[ -n "$essentials_url" ]]; then
            download_file "EssentialsX.jar" "$essentials_url"
        else
            log_error "Konnte Download-URL für EssentialsX nicht finden."
        fi
    fi

    if [[ "$INSTALL_LUCKPERMS" = true ]]; then
        # Stabile, vom User bereitgestellte URL
        download_file "LuckPerms-Bukkit.jar" "https://download.luckperms.net/1609/bukkit/loader/LuckPerms-Bukkit-5.5.20.jar"
    fi

    if [[ "$INSTALL_BENTOBOX" = true ]]; then
        local bentobox_url
        bentobox_url=$(curl -s https://api.github.com/repos/BentoBoxWorld/BentoBox/releases/latest | jq -r '.assets[0].browser_download_url')
        if [[ -n "$bentobox_url" ]]; then
            download_file "BentoBox.jar" "$bentobox_url"
            
            # Addons für BentoBox
            local addons_dir="$plugins_dir/BentoBox/addons"
            mkdir -p "$addons_dir"
            cd "$addons_dir"
            
            local oneblock_url
            oneblock_url=$(curl -s https://api.github.com/repos/BentoBoxWorld/AOneBlock/releases/latest | jq -r '.assets[0].browser_download_url')
            if [[ -n "$oneblock_url" ]]; then
                download_file "AOneBlock.jar" "$oneblock_url"
            else
                log_error "Konnte Download-URL für AOneBlock nicht finden."
            fi

            local level_url
            level_url=$(curl -s https://api.github.com/repos/BentoBoxWorld/Level/releases/latest | jq -r '.assets[0].browser_download_url')
             if [[ -n "$level_url" ]]; then
                download_file "Level.jar" "$level_url"
            else
                log_error "Konnte Download-URL für Level Addon nicht finden."
            fi
        else
            log_error "Konnte Download-URL für BentoBox nicht finden."
        fi
    fi

    if [[ "$INSTALL_MULTIWORLD" = true ]]; then
        cd "$plugins_dir"
        log_info "MultiWorld benötigt FacilisCommon (wird automatisch mitinstalliert)"
        # FacilisCommon ist eine Abhängigkeit von MultiWorld
        local faciliscommon_url
        faciliscommon_url=$(curl -s "https://api.modrinth.com/v2/project/faciliscommon/version" | jq -r '[.[] | select(.game_versions[] | contains("1.21")) | select(.loaders[] | contains("bukkit"))] | .[0].files[0].url')
        if [[ -n "$faciliscommon_url" ]]; then
            download_file "FacilisCommon.jar" "$faciliscommon_url"
        else
            log_warning "Konnte FacilisCommon nicht herunterladen"
        fi
        download_file "MultiWorld-Bukkit.jar" "https://cdn.modrinth.com/data/KhDvVEoP/versions/MLblsJEi/MultiWorld-Bukkit-1.7.7-SNAPSHOT.jar"
    fi

    if [[ "$INSTALL_PL3XMAP" = true ]]; then
        cd "$plugins_dir"
        local pl3xmap_url
        pl3xmap_url=$(curl -s "https://api.modrinth.com/v2/project/pl3xmap/version" | jq -r '[.[] | select(.game_versions[] | contains("1.21")) | select(.loaders[] | contains("bukkit") or contains("paper") or contains("spigot"))] | .[0].files[0].url')
        if [[ -n "$pl3xmap_url" ]]; then
            download_file "Pl3xMap.jar" "$pl3xmap_url"
        else
            log_warning "Konnte Pl3xMap nicht herunterladen - verwende Fallback-URL"
            download_file "Pl3xMap.jar" "https://cdn.modrinth.com/data/PlxMM3x4/versions/T4KqNt8q/Pl3xMap-1.21.1-518.jar"
        fi
    fi

    if [[ "$INSTALL_VAULT" = true ]]; then
        cd "$plugins_dir"
        local vault_url
        vault_url=$(curl -s https://api.github.com/repos/MilkBowl/Vault/releases/latest | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')
        if [[ -n "$vault_url" ]]; then
            download_file "Vault.jar" "$vault_url"
        else
            log_warning "Konnte Vault nicht herunterladen"
        fi
    fi

    if [[ "$INSTALL_CHESTSHOP" = true ]]; then
        cd "$plugins_dir"
        local chestshop_url
        chestshop_url=$(curl -s https://api.github.com/repos/ChestShop-authors/ChestShop-3/releases/latest | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')
        if [[ -n "$chestshop_url" ]]; then
            download_file "ChestShop.jar" "$chestshop_url"
        else
            log_warning "Konnte ChestShop nicht herunterladen"
        fi
    fi

    if [[ "$INSTALL_WORLDGUARD" = true ]]; then
        cd "$plugins_dir"
        log_info "WorldGuard benötigt WorldEdit (wird automatisch mitinstalliert)"
        # WorldEdit ist eine Abhängigkeit von WorldGuard
        local worldedit_url
        worldedit_url=$(curl -s "https://api.modrinth.com/v2/project/worldedit/version" | jq -r '[.[] | select(.game_versions[] | contains("1.21")) | select(.loaders[] | contains("bukkit"))] | .[0].files[] | select(.filename | contains("bukkit")) | .url')
        if [[ -n "$worldedit_url" ]]; then
            download_file "WorldEdit.jar" "$worldedit_url"
        else
            log_warning "Konnte WorldEdit nicht herunterladen"
        fi

        local worldguard_url
        worldguard_url=$(curl -s "https://api.modrinth.com/v2/project/worldguard/version" | jq -r '[.[] | select(.game_versions[] | contains("1.21")) | select(.loaders[] | contains("bukkit"))] | .[0].files[0].url')
        if [[ -n "$worldguard_url" ]]; then
            download_file "WorldGuard.jar" "$worldguard_url"
        else
            log_warning "Konnte WorldGuard nicht herunterladen"
        fi
    fi

    if [[ $download_count -gt 0 ]]; then
        chown -R "$MINECRAFT_USER:$MINECRAFT_USER" "$MINECRAFT_HOME/plugins"
        log_success "Alle ausgewählten Plugins wurden heruntergeladen."
    else
        log_info "Keine Plugins zum Herunterladen ausgewählt."
    fi
}

###############################################################################
# INITIAL START (Config-Generierung)
###############################################################################
initial_server_start() {
    # Nur ausführen, wenn Plugins installiert wurden, die eine Konfiguration benötigen
    if [[ "$INSTALL_GEYSER" = false && "$INSTALL_ESSENTIALS" = false && "$INSTALL_LUCKPERMS" = false && "$INSTALL_BENTOBOX" = false && "$INSTALL_MULTIWORLD" = false && "$INSTALL_PL3XMAP" = false && "$INSTALL_VAULT" = false && "$INSTALL_CHESTSHOP" = false && "$INSTALL_WORLDGUARD" = false ]]; then
        log_skip "Keine Plugins installiert, überspringe initialen Serverstart."
        return
    fi
    
    log "Starte Server initial für Config-Generierung..."

    cd "$MINECRAFT_HOME"

    # Verhindere, dass das Skript hier bei einem Fehler abbricht
    set +e

    log_info "Server läuft für 45 Sekunden, um Konfigurationen zu generieren..."
    if sudo -u "$MINECRAFT_USER" screen -dmS minecraft ./start.sh; then
        sleep 45

        if sudo -u "$MINECRAFT_USER" screen -list | grep -q minecraft; then
            log_info "Stoppe temporären Server..."
            sudo -u "$MINECRAFT_USER" screen -S minecraft -X stuff "stop^M"
            # Warte, bis der Server vollständig heruntergefahren ist
            sleep 15
        else
            log_warning "Screen-Sitzung konnte für den initialen Start nicht gefunden werden."
        fi
        log_success "Initiale Server-Configs generiert."
    else
        log_error "Server konnte für die Config-Generierung nicht gestartet werden."
    fi
    
    # Fehlerbehandlung wieder aktivieren
    trap 'handle_error $LINENO' ERR
}

###############################################################################
# SERVER PROPERTIES
###############################################################################
configure_server_properties() {
    log "Konfiguriere server.properties..."

    local props_file="$MINECRAFT_HOME/server.properties"

    # Warte bis die Datei existiert
    for ((i=0; i<10; i++)); do
        [[ -f "$props_file" ]] && break
        sleep 2
    done

    if [[ ! -f "$props_file" ]]; then
        log_warning "server.properties nicht gefunden, erstelle eine neue Basis-Konfiguration."
        # Schreibe eine neue Datei, falls sie nicht existiert
        cat > "$props_file" << EOF
# Minecraft server properties
server-ip=$SERVER_IP
server-port=$MINECRAFT_PORT
max-players=$MAX_PLAYERS
view-distance=$VIEW_DISTANCE
simulation-distance=$SIMULATION_DISTANCE
motd=Ein cooler Minecraft Server
gamemode=survival
difficulty=normal
spawn-protection=0
enable-command-block=true
network-compression-threshold=256
entity-broadcast-range-percentage=100
EOF
    else
        log_info "Aktualisiere vorhandene server.properties."
        # Backup der alten Datei
        cp "$props_file" "${props_file}.bak"

        # Verwende sed, um Werte zu aktualisieren oder hinzuzufügen
        sed -i "s/^server-ip=.*/server-ip=$SERVER_IP/" "$props_file"
        sed -i "s/^server-port=.*/server-port=$MINECRAFT_PORT/" "$props_file"
        sed -i "s/^max-players=.*/max-players=$MAX_PLAYERS/" "$props_file"
        sed -i "s/^view-distance=.*/view-distance=$VIEW_DISTANCE/" "$props_file"
        sed -i "s/^simulation-distance=.*/simulation-distance=$SIMULATION_DISTANCE/" "$props_file"
        sed -i "s/^spawn-protection=.*/spawn-protection=0/" "$props_file"
        sed -i "s/^enable-command-block=.*/enable-command-block=true/" "$props_file"
        sed -i "s/^motd=.*/motd=Ein cooler Minecraft Server/" "$props_file"
    fi

    chown "$MINECRAFT_USER:$MINECRAFT_USER" "$props_file"
    log_success "server.properties konfiguriert."
}

###############################################################################
# MULTIWORLD CONFIG
###############################################################################
configure_multiworld() {
    if [[ "$INSTALL_MULTIWORLD" = false ]]; then
        return
    fi

    log "Konfiguriere MultiWorld Plugin..."

    local multiworld_config="$MINECRAFT_HOME/plugins/MultiWorld/config.yml"

    # Warte bis die Config-Datei existiert
    for ((i=0; i<10; i++)); do
        [[ -f "$multiworld_config" ]] && break
        sleep 2
    done

    if [[ ! -f "$multiworld_config" ]]; then
        log_warning "MultiWorld config.yml nicht gefunden, überspringe Konfiguration."
        return
    fi

    log_info "Aktiviere Auto-Import für neue Welten..."
    # Aktiviere auto-world-import
    sed -i 's/auto-world-import: false/auto-world-import: true/' "$multiworld_config"

    chown -R "$MINECRAFT_USER:$MINECRAFT_USER" "$MINECRAFT_HOME/plugins/MultiWorld"
    log_success "MultiWorld konfiguriert - Auto-Import aktiviert."
}

###############################################################################
# FIREWALL
###############################################################################
configure_firewall() {
    log "Konfiguriere UFW Firewall..."

    if ! command -v ufw &> /dev/null; then
        log_warning "UFW nicht installiert, überspringe Firewall-Konfiguration."
        return 0
    fi
    
    set +e
    
    ufw allow ssh >/dev/null
    ufw allow "$MINECRAFT_PORT/tcp" comment 'Minecraft Java' >/dev/null
    
    if [[ "$INSTALL_GEYSER" = true ]]; then
        ufw allow "$BEDROCK_PORT/udp" comment 'Minecraft Bedrock' >/dev/null
        log_info "Port $BEDROCK_PORT/udp für Bedrock (Geyser) freigeschaltet."
    fi

    if ! ufw status | grep -q "Status: active"; then
        echo "y" | ufw enable >> "$LOG_FILE" 2>&1
    fi
    
    set -e
    log_success "Firewall konfiguriert (Ports: $MINECRAFT_PORT/tcp, 22/tcp)."
}

###############################################################################
# SYSTEMD SERVICE
###############################################################################
create_systemd_service() {
    log "Erstelle Systemd Service..."

    local service_file="/etc/systemd/system/minecraft.service"
    
    # Dynamische CPU- und RAM-Limits für den Service
    local cpu_quota="${CPU_CORES}00%"
    local memory_max="${JAVA_MEMORY}M"

    cat > "$service_file" << EOF
[Unit]
Description=Minecraft PaperMC Server
After=network.target

[Service]
Type=forking
User=$MINECRAFT_USER
Group=$MINECRAFT_USER
WorkingDirectory=$MINECRAFT_HOME

ExecStart=/usr/bin/screen -dmS minecraft $MINECRAFT_HOME/start.sh
ExecStop=/usr/bin/screen -S minecraft -X stuff "stop^M"

Restart=on-failure
RestartSec=15
TimeoutStartSec=600
TimeoutStopSec=60

# Ressourcen-Kontrolle
CPUQuota=$cpu_quota
MemoryMax=$memory_max

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable minecraft.service >> "$LOG_FILE" 2>&1

    log_success "Systemd Service 'minecraft.service' erstellt und aktiviert."
}

###############################################################################
# BACKUP SCRIPT
###############################################################################
create_backup_script() {
    log "Erstelle Backup-Script..."

    local backup_script="$MINECRAFT_HOME/backup.sh"

    cat > "$backup_script" << 'EOF'
#!/bin/bash
BACKUP_DIR="/opt/minecraft/backups"
TIMESTAMP=$(date +%Y-%m-%d_%H-%M)
BACKUP_FILE="$BACKUP_DIR/backup-$TIMESTAMP.tar.gz"

# Stellt sicher, dass das Backup-Verzeichnis existiert
mkdir -p "$BACKUP_DIR"

echo "Erstelle Backup: $BACKUP_FILE"

# Server-Konsole benachrichtigen
if screen -list | grep -q "minecraft"; then
    screen -S minecraft -X stuff "say §c[Server] §eBackup wird erstellt... Kurze Lags sind möglich!§r^M"
fi

# Backup erstellen
tar -czf "$BACKUP_FILE" -C "/opt/minecraft" \
  --exclude='backups' \
  --exclude='cache' \
  --exclude='logs' \
  --exclude='paper.jar' \
  .

# Alte Backups löschen (älter als 7 Tage)
find "$BACKUP_DIR" -name "backup-*.tar.gz" -type f -mtime +7 -delete
echo "Alte Backups (älter als 7 Tage) wurden gelöscht."
echo "Backup erfolgreich erstellt."
EOF

    chmod +x "$backup_script"
    chown "$MINECRAFT_USER:$MINECRAFT_USER" "$backup_script"

    # Cronjob einrichten (ohne Duplikate)
    (crontab -u "$MINECRAFT_USER" -l 2>/dev/null | grep -v -F "$backup_script" ; echo "0 4 * * * $backup_script >> $MINECRAFT_HOME/logs/backup.log 2>&1") | crontab -u "$MINECRAFT_USER" -
    
    log_success "Backup-Script erstellt und täglichen Cronjob für 4 Uhr morgens eingerichtet."
}

###############################################################################
# MANAGEMENT SCRIPTS
###############################################################################
create_management_scripts() {
    log "Erstelle Management-Scripts..."

    cat > /usr/local/bin/mc-console << 'EOF'
#!/bin/bash
# Verbindet zur Live-Konsole des Minecraft-Servers
sudo -u minecraft screen -r minecraft
EOF

    cat > /usr/local/bin/mc-start << 'EOF'
#!/bin/bash
# Startet den Minecraft-Server via systemd
systemctl start minecraft
EOF

    cat > /usr/local/bin/mc-stop << 'EOF'
#!/bin/bash
# Stoppt den Minecraft-Server via systemd
systemctl stop minecraft
EOF

    cat > /usr/local/bin/mc-restart << 'EOF'
#!/bin/bash
# Startet den Minecraft-Server neu via systemd
systemctl restart minecraft
EOF

    cat > /usr/local/bin/mc-status << 'EOF'
#!/bin/bash
# Zeigt den Status des Minecraft-Servers
systemctl status minecraft
EOF

    chmod +x /usr/local/bin/mc-*
    log_success "Management-Scripts erstellt: mc-console, mc-start, mc-stop, mc-restart, mc-status"
}

###############################################################################
# START SERVER
###############################################################################
start_server() {
    log "Starte Minecraft Server via systemd..."

    set +e
    if systemctl is-active --quiet minecraft; then
        log_skip "Server läuft bereits."
        return 0
    fi

    systemctl start minecraft
    
    log_info "Warte bis zu 60 Sekunden, bis der Server vollständig gestartet ist..."
    for ((i=0; i<12; i++)); do
        if journalctl -u minecraft -n 1 --no-pager | grep -q "Done"; then
            log_success "Server erfolgreich gestartet!"
            set -e
            return
        fi
        sleep 5
    done
    
    log_warning "Server konnte nicht innerhalb von 60 Sekunden gestartet werden."
    log_info "Überprüfe die Logs für Details: journalctl -u minecraft -n 50"
    set -e
}

###############################################################################
# SUMMARY
###############################################################################
print_summary() {
    echo ""
    log_success "Installation erfolgreich abgeschlossen!"
    echo -e "${YELLOW}------------------------- SERVER-ÜBERSICHT -------------------------${NC}"
    echo -e "  ${BLUE}Server IP:${NC}       ${GREEN}$SERVER_IP${NC}"
    echo -e "  ${BLUE}Java Port:${NC}       ${GREEN}$MINECRAFT_PORT${NC}"
    if [[ "$INSTALL_GEYSER" = true ]]; then
    echo -e "  ${BLUE}Bedrock Port:${NC}    ${GREEN}$BEDROCK_PORT${NC}"
    fi
    echo -e "  ${BLUE}RAM zugewiesen:${NC}  ${GREEN}${JAVA_MEMORY}M${NC}"
    echo -e ""
    echo -e "${CYAN}Installierte Plugins:${NC}"
    [[ "$INSTALL_GEYSER" = true ]] && echo -e "  ${GREEN}✓${NC} Geyser & Floodgate"
    [[ "$INSTALL_ESSENTIALS" = true ]] && echo -e "  ${GREEN}✓${NC} EssentialsX"
    [[ "$INSTALL_LUCKPERMS" = true ]] && echo -e "  ${GREEN}✓${NC} LuckPerms"
    [[ "$INSTALL_BENTOBOX" = true ]] && echo -e "  ${GREEN}✓${NC} BentoBox (für OneBlock)"
    [[ "$INSTALL_MULTIWORLD" = true ]] && echo -e "  ${GREEN}✓${NC} MultiWorld"
    [[ "$INSTALL_PL3XMAP" = true ]] && echo -e "  ${GREEN}✓${NC} Pl3xMap (Live-Karte)"
    [[ "$INSTALL_VAULT" = true ]] && echo -e "  ${GREEN}✓${NC} Vault (Economy-API)"
    [[ "$INSTALL_CHESTSHOP" = true ]] && echo -e "  ${GREEN}✓${NC} ChestShop (Shop-System)"
    [[ "$INSTALL_WORLDGUARD" = true ]] && echo -e "  ${GREEN}✓${NC} WorldGuard + WorldEdit (Schutz)"
    echo -e ""
    echo -e "${CYAN}Verbindung:${NC}"
    echo -e "  ${BLUE}PC (Java Edition):${NC}     ${GREEN}$SERVER_IP:$MINECRAFT_PORT${NC}"
    if [[ "$INSTALL_GEYSER" = true ]]; then
    echo -e "  ${BLUE}Switch/Mobile etc.:${NC}  ${GREEN}$SERVER_IP${NC} (Port: ${GREEN}$BEDROCK_PORT${NC})"
    fi
    echo -e ""
    echo -e "${CYAN}Wichtige Befehle:${NC}"
    echo -e "  ${YELLOW}mc-console${NC}         → Live-Konsole des Servers anzeigen"
    echo -e "  ${YELLOW}mc-start / mc-stop${NC} → Server starten / stoppen"
    echo -e "  ${YELLOW}mc-restart${NC}        → Server neustarten"
    echo -e "  ${YELLOW}mc-status${NC}          → Detail-Status des Servers anzeigen"
    echo -e ""
    echo -e "${CYAN}Erste Schritte im Spiel:${NC}"
    echo -e "  1. Verbinde dich mit dem Server."
    echo -e "  2. Gib dir im Terminal OP-Rechte: ${YELLOW}mc-console${NC} und dann ${YELLOW}op <DeinName>${NC}"
    if [[ "$INSTALL_BENTOBOX" = true ]]; then
    echo -e "  3. Starte dein OneBlock-Abenteuer mit: ${YELLOW}/ob${NC}"
    fi
    if [[ "$INSTALL_PL3XMAP" = true ]]; then
    echo -e "  ${BLUE}→${NC} Live-Karte öffnen: ${GREEN}http://$SERVER_IP:8080${NC}"
    fi
    if [[ "$INSTALL_WORLDGUARD" = true ]]; then
    echo -e "  ${BLUE}→${NC} Grundstück schützen: Holzaxt + Linksklick/Rechtsklick Ecken + ${YELLOW}/region define <name>${NC}"
    fi
    if [[ "$INSTALL_CHESTSHOP" = true ]]; then
    echo -e "  ${BLUE}→${NC} Shop erstellen: Truhe + Schild mit Format: (leer) / Anzahl / B Preis:Preis S / item"
    fi
    if [[ "$INSTALL_MULTIWORLD" = true ]]; then
    echo -e "  ${BLUE}→${NC} Welten verwalten: ${YELLOW}/world list${NC} | ${YELLOW}/world create <name> NORMAL -t NORMAL${NC}"
    fi
    echo -e ""
    echo -e "${CYAN}Nützliche Links:${NC}"
    echo -e "  ${BLUE}Dokumentation:${NC} ${GREEN}https://github.com/hehljo/Minecraft${NC}"
    if [[ "$INSTALL_LUCKPERMS" = true ]]; then
    echo -e "  ${BLUE}LuckPerms Editor:${NC} Im Spiel ${YELLOW}/lp editor${NC} ausführen und Link öffnen"
    fi
    echo -e "${YELLOW}--------------------------------------------------------------------${NC}"
    echo -e "${GREEN}Viel Spaß auf deinem Server! 🎮${NC}"
    echo ""
}

###############################################################################
# MAIN
###############################################################################
main() {
    check_root
    banner
    detect_system_specs
    prompt_for_plugins
    
    update_system
    install_dependencies
    set_timezone
    install_java
    
    create_minecraft_user
    download_paper
    create_start_script
    accept_eula
    
    download_plugins
    initial_server_start

    configure_server_properties
    configure_multiworld
    configure_firewall
    create_systemd_service
    create_backup_script
    create_management_scripts
    
    start_server
    print_summary
}

main

exit 0
