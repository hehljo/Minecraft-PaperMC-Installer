#!/bin/bash

###############################################################################
# Minecraft PaperMC Server - Uninstall Script
# Entfernt den kompletten Minecraft-Server und alle Komponenten
###############################################################################

set -e

# Farben für Log-Ausgabe
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging-Funktionen
log() {
    echo -e "${CYAN}[$(date +'%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Root-Check
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Dieses Script muss als root ausgeführt werden!"
        exit 1
    fi
}

# Banner
banner() {
    echo -e "${CYAN}"
    cat << "EOF"
    __  ____       _           __        ____
   /  |/  (_)___  ___  ___________ _/ __/ /_   __  ______  ___  _______________  _____
  / /|_/ / / __ \/ _ \/ ___/ ___/ __ `/ /_/ __/  / / / __ \/ _ \/ ___/ ___/ __ \/ ___/
 / /  / / / / / /  __/ /__/ /  / /_/ / __/ /_   / /_/ / / /  __(__  )  /__/ /_/ (__  )
/_/  /_/_/_/ /_/\___/\___/_/   \__,_/_/  \__/   \__,_/_/ /_/\___/____/_____/\____/____/

                    UNINSTALL SCRIPT

EOF
    echo -e "${NC}"
}

# Warnung anzeigen
show_warning() {
    echo -e "${RED}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║                         WARNUNG!                              ║${NC}"
    echo -e "${RED}╠═══════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${RED}║  Dieses Script wird ALLE Minecraft-Server-Komponenten        ║${NC}"
    echo -e "${RED}║  von diesem System entfernen!                                 ║${NC}"
    echo -e "${RED}║                                                               ║${NC}"
    echo -e "${RED}║  Was wird entfernt:                                          ║${NC}"
    echo -e "${RED}║  • Minecraft-Server (Paper)                                   ║${NC}"
    echo -e "${RED}║  • Alle installierten Plugins                                 ║${NC}"
    echo -e "${RED}║  • Systemd Service                                            ║${NC}"
    echo -e "${RED}║  • Management-Befehle (mc-start, mc-stop, etc.)              ║${NC}"
    echo -e "${RED}║  • Cron-Jobs (Backups)                                        ║${NC}"
    echo -e "${RED}║  • Optional: Welten und Backups                               ║${NC}"
    echo -e "${RED}║  • Optional: Minecraft-Benutzer                               ║${NC}"
    echo -e "${RED}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Bestätigung einholen
confirm_uninstall() {
    echo -e "${YELLOW}Möchten Sie WIRKLICH fortfahren?${NC}"
    while true; do
        read -r -p "$(echo -e "${RED}Zum Bestätigen tippen Sie 'JA LÖSCHEN': ${NC}")" response
        if [[ "$response" = "JA LÖSCHEN" ]]; then
            log_warning "Deinstallation wird gestartet..."
            return 0
        else
            log_info "Abbruch durch Benutzer."
            exit 0
        fi
    done
}

# Server stoppen
stop_server() {
    log "Stoppe Minecraft-Server..."

    if systemctl is-active --quiet minecraft 2>/dev/null; then
        systemctl stop minecraft
        log_success "Server gestoppt."
    else
        log_info "Server läuft nicht."
    fi
}

# Systemd Service entfernen
remove_systemd_service() {
    log "Entferne systemd Service..."

    if systemctl is-enabled --quiet minecraft 2>/dev/null; then
        systemctl disable minecraft
        log_success "Service deaktiviert."
    fi

    if [[ -f /etc/systemd/system/minecraft.service ]]; then
        rm -f /etc/systemd/system/minecraft.service
        systemctl daemon-reload
        log_success "Service-Datei gelöscht."
    else
        log_info "Service-Datei existiert nicht."
    fi
}

# Management-Befehle entfernen
remove_management_commands() {
    log "Entferne Management-Befehle..."

    local commands=("mc-start" "mc-stop" "mc-restart" "mc-status" "mc-console")
    local removed=0

    for cmd in "${commands[@]}"; do
        if [[ -f "/usr/local/bin/$cmd" ]]; then
            rm -f "/usr/local/bin/$cmd"
            ((removed++))
        fi
    done

    if [[ $removed -gt 0 ]]; then
        log_success "$removed Management-Befehl(e) entfernt."
    else
        log_info "Keine Management-Befehle gefunden."
    fi
}

# Cron-Jobs entfernen
remove_cron_jobs() {
    log "Entferne Cron-Jobs..."

    if crontab -u minecraft -l 2>/dev/null | grep -q "minecraft"; then
        crontab -u minecraft -r 2>/dev/null || true
        log_success "Cron-Jobs entfernt."
    else
        log_info "Keine Cron-Jobs gefunden."
    fi
}

# Firewall-Regeln entfernen
remove_firewall_rules() {
    log "Entferne Firewall-Regeln..."

    if command -v ufw &> /dev/null; then
        ufw delete allow 25565/tcp 2>/dev/null || true
        ufw delete allow 19132/udp 2>/dev/null || true
        ufw delete allow 8080/tcp 2>/dev/null || true
        log_success "Firewall-Regeln entfernt."
    else
        log_info "UFW nicht installiert, übersprungen."
    fi
}

# Minecraft-Verzeichnis entfernen
remove_minecraft_directory() {
    echo ""
    log_warning "Minecraft-Verzeichnis (/opt/minecraft) enthält:"
    log_warning "  • Server-Software"
    log_warning "  • Alle Plugins"
    log_warning "  • Welten (world, world_nether, world_the_end)"
    log_warning "  • Backups"
    log_warning "  • Konfigurationen"
    echo ""

    while true; do
        read -r -p "$(echo -e "${YELLOW}Minecraft-Verzeichnis KOMPLETT löschen? [j/n]: ${NC}")" response
        case "$response" in
            [jJ][aA]|[jJ])
                if [[ -d /opt/minecraft ]]; then
                    rm -rf /opt/minecraft
                    log_success "Minecraft-Verzeichnis gelöscht."
                else
                    log_info "Verzeichnis existiert nicht."
                fi
                return 0
                ;;
            [nN][eE][iI][nN]|[nN])
                log_info "Minecraft-Verzeichnis wurde behalten: /opt/minecraft"
                log_info "Sie können es manuell sichern und später löschen."
                return 0
                ;;
            *) echo -e "${RED}Ungültige Eingabe. Bitte j oder n eingeben.${NC}" ;;
        esac
    done
}

# Minecraft-Benutzer entfernen
remove_minecraft_user() {
    echo ""
    while true; do
        read -r -p "$(echo -e "${YELLOW}Minecraft-Benutzer (minecraft) löschen? [j/n]: ${NC}")" response
        case "$response" in
            [jJ][aA]|[jJ])
                if id -u minecraft &>/dev/null; then
                    userdel -r minecraft 2>/dev/null || userdel minecraft 2>/dev/null || true
                    log_success "Benutzer 'minecraft' gelöscht."
                else
                    log_info "Benutzer existiert nicht."
                fi
                return 0
                ;;
            [nN][eE][iI][nN]|[nN])
                log_info "Benutzer 'minecraft' wurde behalten."
                return 0
                ;;
            *) echo -e "${RED}Ungültige Eingabe. Bitte j oder n eingeben.${NC}" ;;
        esac
    done
}

# Screen tmpfiles entfernen
remove_screen_config() {
    log "Entferne screen tmpfiles Konfiguration..."

    if [[ -f /etc/tmpfiles.d/screen.conf ]]; then
        rm -f /etc/tmpfiles.d/screen.conf
        log_success "Screen tmpfiles entfernt."
    else
        log_info "Screen tmpfiles nicht gefunden."
    fi
}

# Zusammenfassung
show_summary() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║              Deinstallation abgeschlossen!                    ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}Was wurde entfernt:${NC}"
    echo -e "  ${GREEN}✓${NC} Minecraft-Server gestoppt"
    echo -e "  ${GREEN}✓${NC} systemd Service entfernt"
    echo -e "  ${GREEN}✓${NC} Management-Befehle entfernt"
    echo -e "  ${GREEN}✓${NC} Cron-Jobs entfernt"
    echo -e "  ${GREEN}✓${NC} Firewall-Regeln entfernt"

    if [[ -d /opt/minecraft ]]; then
        echo -e "  ${YELLOW}→${NC} Minecraft-Verzeichnis behalten: /opt/minecraft"
    else
        echo -e "  ${GREEN}✓${NC} Minecraft-Verzeichnis gelöscht"
    fi

    if id -u minecraft &>/dev/null; then
        echo -e "  ${YELLOW}→${NC} Benutzer 'minecraft' behalten"
    else
        echo -e "  ${GREEN}✓${NC} Benutzer 'minecraft' gelöscht"
    fi

    echo ""
    log_info "System ist nun wieder im Ausgangszustand."

    if [[ -d /opt/minecraft ]]; then
        echo ""
        log_warning "WICHTIG: Das Minecraft-Verzeichnis wurde NICHT gelöscht!"
        log_info "Zum manuellen Löschen verwenden Sie: rm -rf /opt/minecraft"
        log_info "Zum Sichern erst Backup erstellen: tar -czf minecraft-backup.tar.gz /opt/minecraft"
    fi

    echo ""
}

###############################################################################
# MAIN
###############################################################################
main() {
    check_root
    banner
    show_warning
    confirm_uninstall

    stop_server
    remove_systemd_service
    remove_management_commands
    remove_cron_jobs
    remove_firewall_rules
    remove_screen_config
    remove_minecraft_directory
    remove_minecraft_user

    show_summary
}

# Script ausführen
main "$@"
