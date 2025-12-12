#!/bin/bash
###############################################################################
# Minecraft PaperMC Server Update Script
# Sicheres Update von Paper und Plugins
# Version: 1.0
# Datum: 2025-12-12
###############################################################################

###############################################################################
# KONFIGURATION
###############################################################################
MINECRAFT_HOME="/opt/minecraft"
MINECRAFT_USER="minecraft"
BACKUP_DIR="$MINECRAFT_HOME/backups"
LOG_FILE="/var/log/minecraft-update.log"
UPDATE_PLUGINS=false

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
    touch "$LOG_FILE"
    chown "$(logname 2>/dev/null || echo root)" "$LOG_FILE" 2>/dev/null
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

###############################################################################
# FEHLERBEHANDLUNG
###############################################################################
handle_error() {
    log_error "Fehler in Zeile $1"
    if [[ -f "$MINECRAFT_HOME/paper.jar.backup" ]]; then
        log_warning "Stelle vorherige Version wieder her..."
        mv "$MINECRAFT_HOME/paper.jar.backup" "$MINECRAFT_HOME/paper.jar"
        chown "$MINECRAFT_USER:$MINECRAFT_USER" "$MINECRAFT_HOME/paper.jar"
        log_success "Rollback erfolgreich"
    fi
    log_error "Update fehlgeschlagen. Bitte prüfe das Log: $LOG_FILE"
    exit 1
}

trap 'handle_error $LINENO' ERR

###############################################################################
# BANNER
###############################################################################
banner() {
    clear
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║       Minecraft PaperMC Server Update Script v1.0             ║"
    echo "║           Sicheres Update mit automatischem Backup            ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    log_info "Update gestartet..."
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
# SERVER CHECK
###############################################################################
check_server_exists() {
    log "Prüfe ob Server existiert..."
    if [[ ! -f "$MINECRAFT_HOME/paper.jar" ]]; then
        log_error "Kein Minecraft-Server gefunden in $MINECRAFT_HOME"
        log_info "Bitte führe zuerst das Installations-Script aus."
        exit 1
    fi
    log_success "Server gefunden"
}

###############################################################################
# AKTUELLE VERSION ERMITTELN
###############################################################################
get_current_version() {
    log "Ermittle aktuelle Server-Version..."

    if [[ ! -f "$MINECRAFT_HOME/logs/latest.log" ]]; then
        log_warning "Keine Log-Datei gefunden, Version unbekannt"
        CURRENT_VERSION="Unbekannt"
        return
    fi

    CURRENT_VERSION=$(grep "This server is running Paper version" "$MINECRAFT_HOME/logs/latest.log" | tail -1 | sed -n 's/.*Paper version \([0-9.]*\).*/\1/p')

    if [[ -z "$CURRENT_VERSION" ]]; then
        CURRENT_VERSION="Unbekannt"
        log_warning "Aktuelle Version konnte nicht ermittelt werden"
    else
        log_success "Aktuelle Version: $CURRENT_VERSION"
    fi
}

###############################################################################
# VERFÜGBARE VERSIONEN ANZEIGEN
###############################################################################
show_available_versions() {
    log "Hole verfügbare Paper-Versionen..."

    AVAILABLE_VERSIONS=$(curl -s "https://api.papermc.io/v2/projects/paper" | jq -r '.versions | .[]' | grep "^1.21" | tail -10)

    if [[ -z "$AVAILABLE_VERSIONS" ]]; then
        log_error "Konnte verfügbare Versionen nicht abrufen"
        exit 1
    fi

    echo ""
    log_info "Verfügbare Versionen:"
    echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
    echo "$AVAILABLE_VERSIONS" | nl
    echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
    echo ""
}

###############################################################################
# VERSION AUSWÄHLEN
###############################################################################
select_version() {
    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} Welche Version möchtest du installieren? (z.B. 1.21.11 oder 'latest' für neueste): ")" SELECTED_VERSION

        if [[ "$SELECTED_VERSION" == "latest" ]]; then
            SELECTED_VERSION=$(echo "$AVAILABLE_VERSIONS" | tail -1)
            log_info "Neueste Version ausgewählt: $SELECTED_VERSION"
            break
        elif echo "$AVAILABLE_VERSIONS" | grep -q "^$SELECTED_VERSION$"; then
            log_success "Version $SELECTED_VERSION ausgewählt"
            break
        else
            log_error "Ungültige Version. Bitte wähle eine aus der Liste."
        fi
    done
}

###############################################################################
# PLUGIN UPDATE FRAGEN
###############################################################################
ask_plugin_update() {
    echo ""
    while true; do
        read -r -p "$(echo -e "${BLUE}[?]${NC} Möchtest du auch die Plugins aktualisieren? (j/n): ")" response
        case "$response" in
            [jJ][aA]|[jJ])
                UPDATE_PLUGINS=true
                log_info "Plugins werden aktualisiert"
                break
                ;;
            [nN][eE][iI][nN]|[nN])
                UPDATE_PLUGINS=false
                log_info "Plugins werden nicht aktualisiert"
                break
                ;;
            *) echo -e "${RED}Ungültige Eingabe.${NC}" ;;
        esac
    done
}

###############################################################################
# SERVER STOPPEN
###############################################################################
stop_server() {
    log "Stoppe Minecraft-Server..."

    if systemctl is-active --quiet minecraft; then
        systemctl stop minecraft
        sleep 10

        if systemctl is-active --quiet minecraft; then
            log_error "Server konnte nicht gestoppt werden"
            exit 1
        fi
        log_success "Server gestoppt"
    else
        log_info "Server läuft nicht"
    fi
}

###############################################################################
# BACKUP ERSTELLEN
###############################################################################
create_backup() {
    log "Erstelle Backup..."

    mkdir -p "$BACKUP_DIR"
    local timestamp=$(date +%Y-%m-%d_%H-%M)
    local backup_file="$BACKUP_DIR/pre-update-backup-$timestamp.tar.gz"

    log_info "Backup wird erstellt: $backup_file"

    cd "$MINECRAFT_HOME"
    tar -czf "$backup_file" \
        --exclude='backups' \
        --exclude='cache' \
        --exclude='logs' \
        paper.jar server.properties world world_nether world_the_end plugins 2>/dev/null

    chown "$MINECRAFT_USER:$MINECRAFT_USER" "$backup_file"

    local backup_size=$(du -h "$backup_file" | cut -f1)
    log_success "Backup erstellt: $backup_file (Größe: $backup_size)"

    # Alte Backups löschen (älter als 30 Tage)
    find "$BACKUP_DIR" -name "pre-update-backup-*.tar.gz" -type f -mtime +30 -delete 2>/dev/null
    log_info "Alte Backups (älter als 30 Tage) wurden gelöscht"
}

###############################################################################
# PAPER JAR UPDATEN
###############################################################################
update_paper() {
    log "Aktualisiere Paper auf Version $SELECTED_VERSION..."

    # Hole neueste Build-Nummer
    local latest_build
    latest_build=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$SELECTED_VERSION" | jq -r '.builds | last')

    if [[ -z "$latest_build" || "$latest_build" == "null" ]]; then
        log_error "Konnte Build-Nummer für Version $SELECTED_VERSION nicht finden"
        exit 1
    fi

    log_info "Neueste Build-Nummer: #$latest_build"

    local jar_name="paper-${SELECTED_VERSION}-${latest_build}.jar"
    local download_url="https://api.papermc.io/v2/projects/paper/versions/${SELECTED_VERSION}/builds/${latest_build}/downloads/${jar_name}"

    # Backup der aktuellen paper.jar
    if [[ -f "$MINECRAFT_HOME/paper.jar" ]]; then
        mv "$MINECRAFT_HOME/paper.jar" "$MINECRAFT_HOME/paper.jar.backup"
        log_info "Alte paper.jar gesichert"
    fi

    # Download neue Version
    cd "$MINECRAFT_HOME"
    log_info "Lade $jar_name herunter..."

    if curl -L -o paper.jar "$download_url"; then
        chown "$MINECRAFT_USER:$MINECRAFT_USER" paper.jar
        log_success "Paper $SELECTED_VERSION (Build #$latest_build) heruntergeladen"

        # Lösche Backup bei Erfolg
        rm -f "$MINECRAFT_HOME/paper.jar.backup"
    else
        log_error "Download fehlgeschlagen"
        # Rollback wird durch trap ausgeführt
        exit 1
    fi
}

###############################################################################
# PLUGINS UPDATEN
###############################################################################
update_plugins() {
    if [[ "$UPDATE_PLUGINS" = false ]]; then
        log_info "Plugin-Update übersprungen"
        return
    fi

    log "Aktualisiere Plugins..."

    local plugins_dir="$MINECRAFT_HOME/plugins"
    cd "$plugins_dir"

    # Backup der aktuellen Plugins
    mkdir -p "$plugins_dir/backup"
    cp *.jar "$plugins_dir/backup/" 2>/dev/null || true

    local update_count=0

    # Geyser & Floodgate
    if [[ -f "Geyser-Spigot.jar" ]]; then
        log_info "Aktualisiere Geyser..."
        curl -L -s -o "Geyser-Spigot.jar" "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot" && ((update_count++))
    fi

    if [[ -f "floodgate-spigot.jar" ]]; then
        log_info "Aktualisiere Floodgate..."
        curl -L -s -o "floodgate-spigot.jar" "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot" && ((update_count++))
    fi

    # EssentialsX
    if [[ -f "EssentialsX.jar" ]]; then
        log_info "Aktualisiere EssentialsX..."
        local essentials_url
        essentials_url=$(curl -s https://api.github.com/repos/EssentialsX/Essentials/releases/latest | jq -r '.assets[] | select(.name | test("^EssentialsX-[0-9.]+\\.jar$")) | .browser_download_url')
        if [[ -n "$essentials_url" ]]; then
            curl -L -s -o "EssentialsX.jar" "$essentials_url" && ((update_count++))
        fi
    fi

    # LuckPerms
    if [[ -f "LuckPerms-Bukkit.jar" ]]; then
        log_info "Aktualisiere LuckPerms..."
        curl -L -s -o "LuckPerms-Bukkit.jar" "https://download.luckperms.net/1609/bukkit/loader/LuckPerms-Bukkit-5.5.20.jar" && ((update_count++))
    fi

    # MultiWorld
    if [[ -f "MultiWorld-Bukkit.jar" ]]; then
        log_info "Aktualisiere MultiWorld..."
        curl -L -s -o "MultiWorld-Bukkit.jar" "https://cdn.modrinth.com/data/KhDvVEoP/versions/MLblsJEi/MultiWorld-Bukkit-1.7.7-SNAPSHOT.jar" && ((update_count++))
    fi

    # FacilisCommon
    if [[ -f "FacilisCommon.jar" ]]; then
        log_info "Aktualisiere FacilisCommon..."
        local faciliscommon_url
        faciliscommon_url=$(curl -s "https://api.modrinth.com/v2/project/faciliscommon/version" | jq -r '[.[] | select(.game_versions[] | contains("1.21")) | select(.loaders[] | contains("bukkit"))] | .[0].files[0].url')
        if [[ -n "$faciliscommon_url" ]]; then
            curl -L -s -o "FacilisCommon.jar" "$faciliscommon_url" && ((update_count++))
        fi
    fi

    chown -R "$MINECRAFT_USER:$MINECRAFT_USER" "$plugins_dir"

    if [[ $update_count -gt 0 ]]; then
        log_success "$update_count Plugin(s) aktualisiert"
    else
        log_warning "Keine Plugins aktualisiert"
    fi
}

###############################################################################
# SERVER STARTEN
###############################################################################
start_server() {
    log "Starte Minecraft-Server..."

    systemctl start minecraft

    log_info "Warte auf Server-Start (60 Sekunden)..."
    sleep 60

    if systemctl is-active --quiet minecraft; then
        log_success "Server erfolgreich gestartet"
    else
        log_error "Server konnte nicht gestartet werden"
        log_error "Prüfe die Logs mit: journalctl -u minecraft -n 50"
        exit 1
    fi
}

###############################################################################
# UPDATE VERIFIZIEREN
###############################################################################
verify_update() {
    log "Verifiziere Update..."

    sleep 10

    if [[ ! -f "$MINECRAFT_HOME/logs/latest.log" ]]; then
        log_warning "Konnte Log-Datei nicht finden"
        return
    fi

    local new_version
    new_version=$(grep "This server is running Paper version" "$MINECRAFT_HOME/logs/latest.log" | tail -1 | sed -n 's/.*Paper version \([0-9.]*\).*/\1/p')

    if [[ "$new_version" == "$SELECTED_VERSION" ]]; then
        log_success "Update erfolgreich! Server läuft jetzt auf Version $new_version"
    else
        log_warning "Version konnte nicht verifiziert werden"
        log_info "Aktuelle Version laut Log: $new_version"
    fi

    # Plugin-Status prüfen
    local loaded_plugins
    loaded_plugins=$(grep "Loaded.*plugins" "$MINECRAFT_HOME/logs/latest.log" | tail -1)
    if [[ -n "$loaded_plugins" ]]; then
        log_info "Plugins: $loaded_plugins"
    fi
}

###############################################################################
# ZUSAMMENFASSUNG
###############################################################################
print_summary() {
    echo ""
    echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
    log_success "Update abgeschlossen!"
    echo ""
    echo -e "${CYAN}Änderungen:${NC}"
    echo -e "  ${BLUE}Vorherige Version:${NC} ${YELLOW}$CURRENT_VERSION${NC}"
    echo -e "  ${BLUE}Neue Version:${NC}      ${GREEN}$SELECTED_VERSION${NC}"
    echo ""
    echo -e "${CYAN}Server-Status:${NC}"
    systemctl status minecraft --no-pager | head -10
    echo ""
    echo -e "${CYAN}Nächste Schritte:${NC}"
    echo -e "  ${YELLOW}mc-console${NC}  → Verbinde zur Live-Konsole"
    echo -e "  ${YELLOW}mc-status${NC}   → Zeige Server-Status"
    echo ""
    echo -e "${CYAN}Bei Problemen:${NC}"
    echo -e "  ${YELLOW}journalctl -u minecraft -n 50${NC}  → Zeige Server-Logs"
    echo -e "  ${YELLOW}Backup wiederherstellen:${NC}"
    echo -e "    ${YELLOW}mc-stop${NC}"
    echo -e "    ${YELLOW}cd $BACKUP_DIR${NC}"
    echo -e "    ${YELLOW}tar -xzf pre-update-backup-*.tar.gz -C $MINECRAFT_HOME${NC}"
    echo -e "    ${YELLOW}mc-start${NC}"
    echo -e "${YELLOW}-------------------------------------------------------------------${NC}"
    echo ""
}

###############################################################################
# MAIN
###############################################################################
main() {
    check_root
    banner
    check_server_exists
    get_current_version
    show_available_versions
    select_version
    ask_plugin_update

    echo ""
    log_warning "Das Update wird jetzt durchgeführt. Der Server wird gestoppt."
    read -r -p "$(echo -e "${BLUE}[?]${NC} Fortfahren? (j/n): ")" confirm

    case "$confirm" in
        [jJ][aA]|[jJ])
            ;;
        *)
            log_info "Update abgebrochen"
            exit 0
            ;;
    esac

    stop_server
    create_backup
    update_paper
    update_plugins
    start_server
    verify_update
    print_summary
}

main

exit 0
