# Minecraft PaperMC Server Installer

**Language / Sprache:** [🇩🇪 Deutsch](README.md) | [🇬🇧 English](README.en.md)

[![Betriebssystem](https://img.shields.io/badge/OS-Debian%20%2F%20Ubuntu-blue?style=for-the-badge&logo=debian)](https://www.debian.org/)
[![Java-Version](https://img.shields.io/badge/Java-21-orange?style=for-the-badge&logo=openjdk)](https://www.java.com/)
[![GitHub-Repo-Größe](https://img.shields.io/github/repo-size/hehljo/Minecraft?style=for-the-badge&logo=github)](https://github.com/hehljo/Minecraft)
[![Lizenz](https://img.shields.io/badge/Lizenz-MIT-green?style=for-the-badge)](https://github.com/hehljo/Minecraft/blob/main/LICENSE)

<a href="https://buymeacoffee.com/pommesbude" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

Ein vollautomatisches, interaktives Skript zur Installation eines leistungsstarken und stabilen Minecraft-Servers auf jedem Debian-basierten System (inkl. Proxmox LXC).

## 🔗 Kompatibilität

**Getestet mit:**
- **Paper:** 1.21.10 Build #117 (stabil mit Geyser)
- **Bedrock:** 1.21.90 - 1.21.130
- **Geyser:** 2.9.2+ (Cross-Play Java ↔ Bedrock)

**Wichtig:** Bedrock-Clients können nicht downgraden. Das Script verwendet automatisch kompatible Versionen!

---

## ⭐ Features

- **💻 Vollautomatisch:** Führt alle notwendigen Schritte von der System-Aktualisierung bis zum fertigen Serverstart selbstständig aus.
- **🧠 Dynamische Anpassung:** Erkennt automatisch die System-Ressourcen (IP-Adresse, RAM, CPU-Kerne) und konfiguriert den Server für optimale Leistung.
- **🧩 Interaktive Plugin-Auswahl:** Sie entscheiden per Ja/Nein-Abfrage, welche Plugins Sie installieren möchten.
- **🚀 Performance-optimiert:** Nutzt [PaperMC](https://papermc.io/) und [Aikar's Flags](https://mcflags.emc.gs/) für maximale Performance und Stabilität.
- **🎮 Cross-Play (Optional):** Installiert [GeyserMC](https://geysermc.org/), damit Spieler von der Bedrock Edition (Switch, Smartphone, Windows 10/11) und der Java Edition (PC) zusammenspielen können.
- **🧰 Wichtige Plugins (Optional):**
  - **EssentialsX:** Fügt über 100 nützliche Befehle und Funktionen hinzu.
  - **LuckPerms:** Eine extrem schnelle und zuverlässige Rechte-Verwaltung.
  - **BentoBox:** Die Grundlage für den "OneBlock"-Spielmodus.
  - **MultiWorld:** Verwalten Sie mehrere Welten auf einem Server und wechseln Sie einfach zwischen ihnen.
  - **Pl3xMap:** Live-Karte Ihrer Welt im Browser - sehen Sie die Welt und Spieler in Echtzeit.
  - **Vault + ChestShop:** Economy-System - Spieler können mit virtuellem Geld handeln und eigene Shops erstellen.
  - **WorldGuard:** Grundstücksschutz - Spieler können ihre Bereiche vor Griefing schützen.
- **⚙️ Professionelles Management:**
  - Richtet einen `systemd`-Service ein, damit der Server automatisch startet und einfach verwaltet werden kann.
  - Erstellt simple Management-Befehle (`mc-start`, `mc-stop`, `mc-console`, etc.).
  - Richtet tägliche, automatische Backups ein.

## 📋 Anforderungen

- Ein Server oder LXC-Container mit einem **Debian-basierten Betriebssystem** (z.B. Debian 11/12, Ubuntu 22.04+).
- **Root-Zugriff** (oder `sudo`-Rechte) für die Installation.
- Mindestens **2 GB RAM** empfohlen.

## 🚀 Installation

Verbinden Sie sich mit Ihrem Server via SSH und führen Sie den folgenden Befehl aus. Das Skript wird Sie durch die Installation führen.

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/hehljo/Minecraft/main/minecraft-install.sh)"
```

Das Skript wird Sie fragen, welche der empfohlenen Plugins Sie installieren möchten.

## 🛠️ Nach der Installation: Erste Schritte

Ihr Server ist nun betriebsbereit und startet bei einem Neustart des Systems automatisch.

1.  **Verbinden Sie sich mit Ihrem Server:**
    - **Java Edition (PC):** `IHRE_SERVER_IP:25565`
    - **Bedrock Edition (Switch etc.):** `IHRE_SERVER_IP` (Port: `19132`)
      *Die IP-Adresse wird Ihnen am Ende der Installation angezeigt.*

2.  **Admin-Rechte (OP) vergeben:**
    - Öffnen Sie ein **neues Terminal** und verbinden Sie sich erneut mit Ihrem Server.
    - Geben Sie `mc-console` ein, um die Live-Konsole des Servers zu sehen.
    - Geben Sie dort den Befehl `op IHR_MINECRAFT_NAME` ein (ersetzen Sie `IHR_MINECRAFT_NAME` mit Ihrem exakten Spielernamen).
    - Sie können die Konsole mit der Tastenkombination `STRG + a`, dann `d` verlassen.

## ✅ Funktions-Test (Für Server-Admins)

Nachdem Sie sich OP-Rechte gegeben haben, können Sie die Funktionalität der installierten Plugins testen.

#### Cross-Play (GeyserMC) testen
- **Test:** Versuchen Sie, sich mit einem Bedrock-Client (z.B. auf dem Smartphone oder Windows 10/11) mit der IP des Servers und dem Port `19132` zu verbinden.
- **Erfolg:** Sie können den Server betreten und sehen andere Java-Spieler.

#### EssentialsX testen
- **Test:** Geben Sie im Spiel die folgenden Befehle ein.
  - `/gamemode creative` - Wechselt Ihren Spielmodus.
  - `/sethome zuhause` - Setzt einen Teleportationspunkt.
  - `/home zuhause` - Teleportiert Sie zu diesem Punkt.
- **Erfolg:** Alle Befehle werden ohne Fehlermeldung ausgeführt.

#### LuckPerms testen
- **Test:** Der `lp`-Befehl ist das mächtigste Werkzeug zur Rechteverwaltung.
  - `/lp editor` - Dieser Befehl generiert einen Link. Öffnen Sie ihn im Browser.
- **Erfolg:** Eine Weboberfläche lädt, in der Sie Gruppen und Berechtigungen einfach per Klick verwalten können. Das ist der empfohlene Weg, um mit LuckPerms zu arbeiten.

#### BentoBox (OneBlock) testen
- **Test:** Geben Sie im Spiel den Startbefehl für den OneBlock-Modus ein.
  - `/ob`
- **Erfolg:** Sie werden auf eine neue Insel teleportiert, die nur aus einem einzigen, sich regenerierenden Block besteht.

**🎮 OneBlock-Welt erstellen (Anleitung):**

So erstellen Sie eine dedizierte OneBlock-Welt die unabhängig von Ihrer Hauptwelt läuft:

1. **Neue Welt mit BentoBox erstellen:**
   ```
   /bbox world create oneblock OneBlock NORMAL
   ```
   - `oneblock` = Name der neuen Welt
   - `OneBlock` = Gamemode (OneBlock-Addon)
   - `NORMAL` = Welttyp

2. **Zur OneBlock-Welt teleportieren:**
   ```
   /bbox world tp oneblock
   ```

3. **Neues OneBlock-Spiel starten:**
   ```
   /ob
   ```
   Sie spawnen nun auf Ihrer OneBlock-Insel in der dedizierten Welt!

4. **Weitere Spieler einladen:**
   ```
   /ob team invite SpielerName
   ```

**💡 Vorteile einer separaten OneBlock-Welt:**
- ✅ Hauptwelt bleibt unberührt
- ✅ Separate Karte in Pl3xMap
- ✅ Eigene Spawn-Einstellungen
- ✅ Unabhängige Backups möglich

#### MultiWorld testen
- **Test:** Verwenden Sie die MultiWorld-Befehle, um Welten zu verwalten.
  - `/world list` - Zeigt alle verfügbaren Welten an.
  - `/world create testwelt NORMAL -t NORMAL` - Erstellt eine neue Welt namens "testwelt".
  - `/world teleport testwelt` - Teleportiert Sie zur neuen Welt.
- **Erfolg:** Sie sehen die Liste der Welten und können zwischen ihnen wechseln.

#### Pl3xMap testen (Live-Karte)
- **Test:** Öffnen Sie einen Browser und gehen Sie zu: `http://IHRE_SERVER_IP:8080`
- **Erfolg:** Sie sehen eine interaktive Karte Ihrer Minecraft-Welt im Browser.
- **Hinweis:** Die Karte zeigt nur bereits erkundete Bereiche. Laufen Sie im Spiel herum, um die Karte zu füllen!

**🗺️ Multi-World Map-Ansicht (Mehrere Welten in Pl3xMap):**

Wenn Sie MultiWorld installiert haben, kann Pl3xMap **alle Welten** anzeigen!

**So funktioniert's:**
1. Öffnen Sie Pl3xMap: `http://192.168.1.8:8080`
2. **Oben links** sehen Sie ein **Dropdown-Menü** mit allen Welten:
   - `world` (Hauptwelt)
   - `SofiesWelt`
   - `Pommesbude`
   - `oneblock` (OneBlock-Welt, falls erstellt)
   - Alle anderen Welten die Sie erstellt haben

3. **Klicken Sie auf eine Welt** um zur Karte zu wechseln
4. Die Karte lädt automatisch die gewählte Welt!

**💡 Tipps:**
- Jede Welt hat ihre eigene Karte
- Spieler werden in Echtzeit auf der aktiven Welt angezeigt
- Marker und POIs sind pro Welt getrennt
- Die Karte rendert sich automatisch während Sie spielen

**Weltoptionen in Pl3xMap:**
- **Zoom-Stufen:** Verschiedene Detail-Level verfügbar
- **Layer:** Oberflächenkarte, Höhlenkarte, Biom-Ansicht
- **Marker:** Spieler-Positionen, Spawn-Punkte, POIs

**📍 Marker setzen (optional):**
```
/pl3xmap marker add <name> <beschreibung>
```

**🌟 LiveAtlas - Modernes Web-Frontend für Pl3xMap (Optional)**

[LiveAtlas](https://github.com/JLyne/LiveAtlas) ist ein modernes, schönes Web-Frontend für Pl3xMap mit verbesserter Performance und Benutzeroberfläche.

**Schnelle Installation:**
```bash
# 1. Node.js installieren (falls noch nicht vorhanden)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# 2. LiveAtlas herunterladen und installieren
cd /opt
git clone https://github.com/JLyne/LiveAtlas.git
cd LiveAtlas
npm install
npm run build

# 3. Webserver konfigurieren (z.B. mit nginx)
apt-get install -y nginx
cat > /etc/nginx/sites-available/liveatlas << 'EOF'
server {
    listen 80;
    server_name _;

    root /opt/LiveAtlas/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /tiles {
        proxy_pass http://localhost:8080/tiles;
    }
}
EOF

ln -s /etc/nginx/sites-available/liveatlas /etc/nginx/sites-enabled/
rm /etc/nginx/sites-enabled/default
systemctl restart nginx
```

**Nutzung:** Öffnen Sie `http://IHRE_SERVER_IP` im Browser - Sie sehen jetzt die moderne LiveAtlas-Oberfläche!

**Vorteile:**
- ✅ Schnellere Ladezeiten
- ✅ Moderne, responsive Oberfläche
- ✅ Bessere Marker-Verwaltung
- ✅ Mobilfreundlich

#### ChestShop testen (Shops erstellen)
- **Test:** Erstellen Sie Ihren ersten Shop!
  1. Platzieren Sie eine Truhe im Spiel
  2. Füllen Sie die Truhe mit Items zum Verkaufen (z.B. 10 Diamanten)
  3. Platzieren Sie ein Schild direkt über/neben der Truhe
  4. Schreiben Sie auf das Schild (Zeile für Zeile):
     - Zeile 1: (leer lassen - wird automatisch gefüllt)
     - Zeile 2: `10` (Anzahl der Items pro Verkauf)
     - Zeile 3: `B 50:10 S` (Kaufpreis: 50, Verkaufspreis: 10)
     - Zeile 4: `diamond` (Item-Name)
- **Erfolg:** Das Schild wird grün und zeigt Ihren Shop-Namen! Andere Spieler können nun mit Rechtsklick kaufen/verkaufen.
- **Hinweis:** Ohne Economy-Plugin (Vault) funktionieren nur Tauschgeschäfte!

#### WorldGuard testen (Grundstücksschutz)
- **Test:** Schützen Sie einen Bereich vor Griefing.
  1. Nehmen Sie eine Holzaxt in die Hand
  2. Klicken Sie mit Links auf einen Block (1. Ecke)
  3. Klicken Sie mit Rechts auf einen anderen Block (2. Ecke gegenüber)
  4. Geben Sie ein: `/region define meingrundstück`
  5. Testen Sie den Schutz: Versuchen Sie Blöcke zu platzieren/abbauen
- **Erfolg:** Sie haben einen geschützten Bereich erstellt! Nur Sie (als Owner) können dort bauen.
- **Wichtige Befehle:**
  - `/region addmember meingrundstück SpielerName` - Spieler hinzufügen
  - `/region flag meingrundstück pvp deny` - PvP in der Region deaktivieren
  - `/region info meingrundstück` - Region-Infos anzeigen

## 🔒 Server-Zugang beschränken (Whitelist & Passwortschutz)

### Option 1: Whitelist (Einfach - bereits eingebaut!)

Nur Spieler auf der Whitelist dürfen joinen:

```bash
# Via mc-console oder im Spiel mit OP-Rechten:
whitelist on
whitelist add SpielerName

# Spieler entfernen:
whitelist remove SpielerName

# Alle Spieler anzeigen:
whitelist list
```

**Wann nutzen?** Wenn Sie einen privaten Server für Freunde haben und genau wissen, wer spielen darf.

### Option 2: AuthMe Plugin (Passwort-Login)

**Für mehr Sicherheit:** Jeder Spieler muss sich beim ersten Join registrieren und danach immer einloggen.

**Installation:**
```bash
cd /opt/minecraft/plugins
wget https://github.com/AuthMe/AuthMeReloaded/releases/download/5.6.0-beta2/AuthMe-5.6.0-beta2.jar
mc-restart
```

**Nutzung für Spieler:**
```bash
# Beim ersten Join:
/register <passwort> <passwort>

# Bei jedem Join danach:
/login <passwort>
```

**Wann nutzen?** Wenn Sie einen öffentlichen Server haben oder zusätzliche Sicherheit gegen Account-Diebstahl wollen.

---

## 📦 Welt-Migration: Singleplayer und Server-Welten importieren

Sie können bestehende Minecraft-Welten von Ihrem Singleplayer-Spiel oder einem anderen Server auf Ihren neuen PaperMC-Server übertragen.

### Migration einer Singleplayer-Welt (aus dem `saves` Ordner)

**Schritt 1: Singleplayer-Welt lokalisieren**

Auf Ihrem PC befindet sich die Singleplayer-Welt im Minecraft-Datenordner:
- **Windows:** `%APPDATA%\.minecraft\saves\[WELTNAME]`
- **macOS:** `~/Library/Application Support/minecraft/saves/[WELTNAME]`
- **Linux:** `~/.minecraft/saves/[WELTNAME]`

**Schritt 2: Welt auf den Server hochladen**

Verwenden Sie `scp` oder einen SFTP-Client (z.B. FileZilla, WinSCP):

```bash
# Beispiel mit scp (von Ihrem PC aus)
scp -r /pfad/zu/.minecraft/saves/MeineWelt root@IHRE_SERVER_IP:/tmp/
```

**Schritt 3: Server stoppen**

```bash
mc-stop
```

**Schritt 4: Welt auf dem Server platzieren**

```bash
# Wechseln Sie zum Minecraft-Verzeichnis
cd /opt/minecraft

# Entfernen oder umbenennen Sie die Standard-Welt (Optional, Backup erstellen!)
mv world world_backup

# Kopieren Sie Ihre Welt
cp -r /tmp/MeineWelt world

# Setzen Sie die richtigen Berechtigungen
chown -R minecraft:minecraft world
```

**Schritt 5: server.properties anpassen**

```bash
nano /opt/minecraft/server.properties
```

Stellen Sie sicher, dass diese Zeile korrekt ist:
```
level-name=world
```

**Schritt 6: Server starten**

```bash
mc-start
```

Ihre Singleplayer-Welt ist nun auf dem Server verfügbar!

---

### Migration einer bestehenden Server-Welt (aus dem `world` Ordner)

**Schritt 1: Server-Welt lokalisieren**

Auf Ihrem alten Minecraft-Server befinden sich die Weltdaten im Server-Verzeichnis:
- Hauptwelt: `world/`
- Nether: `world_nether/`
- End: `world_the_end/`

**Schritt 2: Welten auf den neuen Server hochladen**

```bash
# Beispiel mit scp (von Ihrem PC oder alten Server aus)
scp -r /pfad/zu/altem-server/world root@IHRE_SERVER_IP:/tmp/
scp -r /pfad/zu/altem-server/world_nether root@IHRE_SERVER_IP:/tmp/
scp -r /pfad/zu/altem-server/world_the_end root@IHRE_SERVER_IP:/tmp/
```

**Schritt 3: Server stoppen**

```bash
mc-stop
```

**Schritt 4: Welten auf dem neuen Server platzieren**

```bash
# Wechseln Sie zum Minecraft-Verzeichnis
cd /opt/minecraft

# Backup der alten Welten erstellen (falls vorhanden)
mv world world_backup 2>/dev/null
mv world_nether world_nether_backup 2>/dev/null
mv world_the_end world_the_end_backup 2>/dev/null

# Neue Welten kopieren
cp -r /tmp/world ./
cp -r /tmp/world_nether ./
cp -r /tmp/world_the_end ./

# Berechtigungen setzen
chown -R minecraft:minecraft world world_nether world_the_end
```

**Schritt 5: Server starten**

```bash
mc-start
```

Ihre Server-Welt ist nun auf dem neuen PaperMC-Server aktiv!

---

### Mehrere Welten verwalten mit MultiWorld

Wenn Sie **MultiWorld** während der Installation ausgewählt haben, können Sie mehrere Welten gleichzeitig auf dem Server verwalten.

**🎯 Auto-Import Feature (NEU!):**
MultiWorld ist so konfiguriert, dass neue Welten **automatisch erkannt** werden!

**Was bedeutet das für Sie?**
- Laden Sie einfach einen Weltordner nach `/opt/minecraft/` hoch
- Setzen Sie die richtigen Berechtigungen mit `chown -R minecraft:minecraft /opt/minecraft/IhreWelt`
- Beim nächsten Server-Neustart oder `/multiworld reload` erkennt MultiWorld die Welt automatisch!
- Sie müssen **nichts manuell importieren** - die Welt erscheint in `/world list`

**So einfach geht's:**
1. Welt hochladen nach `/opt/minecraft/IhreWelt`
2. Berechtigungen setzen: `chown -R minecraft:minecraft /opt/minecraft/IhreWelt`
3. Im Spiel: `/world load IhreWelt` (beim ersten Mal)
4. Fertig! Teleportieren mit `/world teleport IhreWelt`

**Zusätzliche Welt manuell importieren (falls Auto-Import deaktiviert):**

```bash
# Server stoppen
mc-stop

# Welt hochladen (z.B. in /tmp/ZweiteWelt)
cd /opt/minecraft

# Welt ins Minecraft-Verzeichnis kopieren
cp -r /tmp/ZweiteWelt ./

# Berechtigungen setzen
chown -R minecraft:minecraft ZweiteWelt

# Server starten
mc-start
```

**Welt im Spiel laden:**

```bash
# Im Spiel (mit OP-Rechten) oder in der Konsole (mc-console):
/world create ZweiteWelt NORMAL -t NORMAL

# Zur Welt teleportieren:
/world teleport ZweiteWelt

# Alle verfügbaren Welten anzeigen:
/world list
```

**Wichtige MultiWorld-Befehle:**
- `/world create <weltname> NORMAL -t NORMAL` - Neue Welt erstellen
- `/world import <weltname> NORMAL -t NORMAL` - Bestehende Welt manuell importieren
- `/world teleport <weltname>` - Zu einer Welt teleportieren
- `/world list` - Alle verfügbaren Welten anzeigen
- `/world unload <weltname>` - Welt entladen (aber nicht löschen)
- `/world load <weltname>` - Welt laden

**Hinweis:** Mit Auto-Import müssen Sie normalerweise **nicht** `/world import` nutzen - die Welt wird automatisch erkannt!

**Beispiel für Import einer bereits kopierten Welt (falls Auto-Import deaktiviert):**
```bash
# Im Spiel oder über mc-console:
/world import ZweiteWelt NORMAL -t NORMAL
/world teleport ZweiteWelt
```

---

### 🎮 PRAXIS-ANLEITUNG: MultiWorld mit eigenen Welten testen

Diese Anleitung zeigt Ihnen **Schritt für Schritt**, wie Sie Ihre Singleplayer- oder Server-Welten mit MultiWorld auf dem Server laden und zwischen ihnen wechseln können.

#### 📋 Was Sie brauchen:
- Zugriff auf Ihren Server (SSH)
- Eine oder mehrere Minecraft-Welten (Singleplayer oder Server)
- SFTP-Client (z.B. FileZilla, WinSCP) oder `scp` Befehl
- Minecraft Java Edition 1.21.11 Client

---

#### **Schritt 1: Welten auf Ihren PC finden**

**Singleplayer-Welt (vom PC):**
- **Windows:** `%APPDATA%\.minecraft\saves\[WELTNAME]`
- **macOS:** `~/Library/Application Support/minecraft/saves/[WELTNAME]`
- **Linux:** `~/.minecraft/saves/[WELTNAME]`

**Server-Welt (von einem alten Server):**
- `world/` (Hauptwelt)
- `world_nether/` (Nether)
- `world_the_end/` (End)

**Beispiel:** Ich habe eine Singleplayer-Welt namens "SofiesWelt" und eine Server-Welt "Pommesbude"

---

#### **Schritt 2: Welten dauerhaft auf den Server hochladen**

**⚠️ WICHTIG:** Laden Sie Ihre Welten **direkt** nach `/opt/minecraft` - sie bleiben dort dauerhaft!

**Option A: Mit SFTP-Client (z.B. FileZilla) - EMPFOHLEN für große Welten**

1. Öffnen Sie FileZilla
2. Verbinden Sie sich mit Ihrem Server:
   - Host: `IHRE_SERVER_IP`
   - Benutzername: `root`
   - Passwort: Ihr Root-Passwort
   - Port: `22`
3. **Navigieren Sie rechts zu `/opt/minecraft`** ← Direkt ins Minecraft-Verzeichnis!
4. Ziehen Sie Ihre Welt-Ordner per Drag & Drop von links nach rechts

**Option B: Mit scp-Befehl (Terminal/PowerShell)**

```bash
# Für Windows (PowerShell):
scp -r "C:\Users\IhrName\AppData\Roaming\.minecraft\saves\SofiesWelt" root@IHRE_SERVER_IP:/opt/minecraft/

# Für macOS/Linux:
scp -r ~/Library/Application\ Support/minecraft/saves/SofiesWelt root@IHRE_SERVER_IP:/opt/minecraft/
```

**💡 Tipp:** Bei sehr großen Welten (>1GB) nutzen Sie FileZilla - bei Abbruch können Sie fortsetzen!

**Hochladen kann je nach Weltgröße dauern:**
- Kleine Welten (<100MB): 1-3 Minuten
- Mittlere Welten (100MB-500MB): 5-10 Minuten
- Große Welten (>500MB): 10-30 Minuten

---

#### **Schritt 3: Berechtigungen setzen**

Verbinden Sie sich per SSH mit dem Server:

```bash
ssh root@IHRE_SERVER_IP
```

**Prüfen Sie, ob die Welten angekommen sind:**

```bash
ls -lh /opt/minecraft/ | grep -E "SofiesWelt|Pommesbude"
```

Sie sollten Ihre hochgeladenen Ordner sehen!

**Berechtigungen für den Minecraft-User setzen (WICHTIG!):**

```bash
# Für alle hochgeladenen Welten:
chown -R minecraft:minecraft /opt/minecraft/SofiesWelt
chown -R minecraft:minecraft /opt/minecraft/Pommesbude

# Prüfen ob level.dat existiert (wichtig!):
ls -lh /opt/minecraft/SofiesWelt/level.dat
ls -lh /opt/minecraft/Pommesbude/level.dat
```

✅ Beide Befehle sollten die `level.dat` Datei anzeigen - das bedeutet die Welten sind korrekt!

---

#### **Schritt 4: MultiWorld-Befehle verstehen**

**Wichtigste Befehle:**

| Befehl | Beschreibung | Beispiel |
|--------|--------------|----------|
| `/world list` | Zeigt alle verfügbaren Welten | `/world list` |
| `/world load <name>` | Lädt eine Welt (wichtig vor teleport!) | `/world load SofiesWelt` |
| `/world teleport <name>` | Teleportiert zu einer Welt | `/world teleport SofiesWelt` |
| `/world import <name> NORMAL -t NORMAL` | Importiert eine Welt manuell | `/world import SofiesWelt NORMAL -t NORMAL` |
| `/world create <name> NORMAL -t NORMAL` | Erstellt eine neue Welt | `/world create NeueWelt NORMAL -t NORMAL` |
| `/world setspawn` | Setzt den Spawn in aktueller Welt | `/world setspawn` |
| `/world info <name>` | Zeigt Infos über eine Welt | `/world info world` |
| `/world unload <name>` | Entlädt eine Welt (löscht sie NICHT) | `/world unload SofiesWelt` |

**Welttypen für -t Parameter:**
- `NORMAL` - Normale Oberwelt (immer Großbuchstaben!)
- `NETHER` - Nether
- `THE_END` - End

**💡 Tipp:** Mit Auto-Import müssen Sie `/world import` normalerweise nicht nutzen - einfach hochladen und `/world load`!

---

#### **Schritt 5: Mit Minecraft verbinden und testen**

**1. Starten Sie Minecraft Java Edition 1.21.11**

**2. Verbinden Sie sich mit dem Server:**
- Klicken Sie auf "Multiplayer"
- Klicken Sie auf "Server hinzufügen"
- Servername: `Mein Test-Server`
- Serveradresse: `IHRE_SERVER_IP:25565`
- Klicken Sie auf "Fertig"
- Doppelklick auf den Server

**3. Geben Sie sich OP-Rechte (falls noch nicht geschehen):**

Öffnen Sie ein **neues Terminal** (lassen Sie Minecraft laufen):

```bash
ssh root@IHRE_SERVER_IP
mc-console
```

In der Konsole tippen Sie:
```
op IhrMinecraftName
```

Drücken Sie `Ctrl+a` dann `d` um die Konsole zu verlassen.

**Sie haben jetzt Admin-Rechte im Spiel!**

---

#### **Schritt 6: Welten laden und zwischen ihnen wechseln**

**Im Spiel (drücken Sie `T` für Chat):**

**1. Zeigen Sie alle verfügbaren Welten:**
```
/world list
```
Dank Auto-Import sollten Sie hier bereits `SofiesWelt` und `Pommesbude` sehen!

**2. Laden Sie SofiesWelt (wichtig beim ersten Mal!):**
```
/world load SofiesWelt
```

✅ **Erfolgsmeldung:** "The world SofiesWelt was loaded successfully!"

**3. Laden Sie Pommesbude:**
```
/world load Pommesbude
```

✅ **Erfolgsmeldung:** "The world Pommesbude was loaded successfully!"

**💡 Hinweis:** Falls die Welten nicht automatisch erkannt wurden, importieren Sie sie manuell:
```
/world import SofiesWelt NORMAL -t NORMAL
/world import Pommesbude NORMAL -t NORMAL
```

**4. Listen Sie alle Welten erneut auf:**
```
/world list
```

Sie sollten jetzt sehen:
- `world` (Standard)
- `SofiesWelt` (geladen)
- `Pommesbude` (geladen)

**5. Teleportieren Sie sich zu SofiesWelt:**
```
/world teleport SofiesWelt
```

🎉 **Sie sind jetzt in SofiesWelt auf dem Server!**

**6. Wechseln Sie zu Pommesbude:**
```
/world teleport Pommesbude
```

**7. Zurück zur Standard-Welt:**
```
/world teleport world
```

---

#### **Schritt 7: Weitere Spieler einladen**

Ihre Freunde können sich jetzt auch verbinden!

**So wechseln normale Spieler zwischen Welten:**

1. Sie müssen ihnen **Rechte geben**, Welten zu betreten:

```bash
# Im Spiel oder via mc-console:
/lp group default permission set multiverse.access.SofiesWelt true
/lp group default permission set multiverse.access.Pommesbude true
```

2. **Alternative:** Portale erstellen (fortgeschritten):
   - MultiWorld unterstützt Portal-Plugins für erweiterte Funktionalität
   - Spieler können dann durch Portale laufen statt Befehle zu nutzen

3. **Oder:** Nutzen Sie `/world teleport SpielerName WeltName` um andere zu teleportieren

---

#### **Schritt 8: Spawn-Punkte setzen (optional)**

Jede Welt kann einen eigenen Spawn-Punkt haben:

1. Teleportieren Sie sich zur gewünschten Welt:
```
/world teleport SofiesWelt
```

2. Laufen Sie zur gewünschten Position

3. Setzen Sie den Spawn:
```
/world setspawn
```

4. Testen Sie es:
```
/world spawn
```
Sie werden zum gesetzten Spawn teleportiert!

---

#### **🔧 Troubleshooting**

**Problem: "World not found"**
- Lösung: Prüfen Sie den exakten Namen: `ls /opt/minecraft/ | grep -i sofies`
- MultiWorld ist **case-sensitive**: `SofiesWelt` ≠ `sofieswelt`

**Problem: "World already exists"**
- Lösung: Die Welt ist bereits importiert oder wurde automatisch erkannt. Nutzen Sie `/world load WeltName` und dann `/world teleport WeltName`

**Problem: "World is not loaded"**
- Lösung: Welt muss erst geladen werden mit `/world load WeltName` bevor Sie sich dorthin teleportieren können

**Problem: "Permission denied"**
- Lösung: Sie haben keine OP-Rechte. Geben Sie sich via `mc-console` OP: `op IhrName`

**Problem: "World could not be loaded"**
- Lösung: Welt ist defekt oder falsche Version
- Prüfen Sie die Logs: `tail -50 /opt/minecraft/logs/latest.log`

**Problem: Welt ist leer/neu generiert**
- Lösung: Falscher Ordner wurde importiert
- Wichtig: Der `level.dat` muss im Root-Ordner der Welt liegen
- Prüfen: `ls /opt/minecraft/SofiesWelt/level.dat` (sollte existieren)

---

#### **💾 Worlds verwalten**

**Welt entladen (aber nicht löschen):**
```
/world unload WeltName
```

**Welt wieder laden:**
```
/world load WeltName
```

**Welt löschen (VORSICHT!):**
```bash
# NUR via Terminal, nicht im Spiel!
mc-stop
rm -rf /opt/minecraft/WeltName
mc-start
```

**Liste aller Welten auf dem Server:**
```bash
ls -lh /opt/minecraft/ | grep "^d" | grep -v "^\."
```

---

#### **📊 Beispiel-Szenario**

Sie haben jetzt:
- **world** - Standard Welt (vom Server generiert)
- **SofiesWelt** - Ihre importierte Welt
- **Pommesbude** - Ihre zweite importierte Welt

**Typischer Workflow:**
1. Spieler loggen ein → Landen in `world` (Standard)
2. Spieler wollen zu SofiesWelt → `/world teleport SofiesWelt`
3. Spieler wollen zur Pommesbude → `/world teleport Pommesbude`
4. Zurück zur Standard-Welt → `/world teleport world`

**Jede Welt behält:**
- ✅ Inventar (wenn nicht konfiguriert anders)
- ✅ Position
- ✅ Gamemode (sofern gesetzt)
- ✅ Alle Blöcke und Entities

---

### 🎯 Zusammenfassung MultiWorld

**Was Sie jetzt können:**
1. ✅ Singleplayer-Welten auf den Server laden
2. ✅ Server-Welten importieren
3. ✅ Zwischen Welten wechseln
4. ✅ Mehrere Welten gleichzeitig laufen lassen
5. ✅ Spawn-Punkte pro Welt setzen
6. ✅ Freunde einladen und Zugriff verwalten

**Wichtige Befehle nochmal:**
```bash
/world list                            # Alle verfügbaren Welten anzeigen
/world load <name>                     # Welt laden (wichtig!)
/world teleport <name>                 # Zur Welt teleportieren
/world import <name> NORMAL -t NORMAL  # Welt manuell importieren (selten nötig dank Auto-Import)
/world setspawn                        # Spawn setzen
/world info <name>                     # Welt-Infos anzeigen
```

**💡 Wichtig:** Mit aktiviertem Auto-Import einfach Welten nach `/opt/minecraft/` hochladen, Berechtigungen setzen, und mit `/world load` laden!

Viel Spaß beim Testen! 🎮

---

## ⚙️ Server-Verwaltung im Detail

Diese Befehle können Sie jederzeit in Ihrem Server-Terminal eingeben, um Ihren Server zu steuern.

- `mc-start`
  - **Funktion:** Startet den Minecraft-Server, falls er gestoppt wurde.
- `mc-stop`
  - **Funktion:** Fährt den Server sicher herunter und speichert alle Welten und Spielerdaten korrekt.
- `mc-restart`
  - **Funktion:** Fährt den Server sicher herunter und startet ihn danach sofort wieder. Nützlich, um Konfigurations-Änderungen zu laden.
- `mc-status`
  - **Funktion:** Zeigt den detaillierten Status des Server-Prozesses an, inklusive Laufzeit, RAM-Nutzung und den letzten Log-Einträgen.
- `mc-console`
  - **Funktion:** Verbindet Sie mit der Live-Konsole des Minecraft-Servers. Hier sehen Sie alle Server-Meldungen in Echtzeit und können administrative Befehle eingeben.
  - **Verlassen:** Drücken Sie `STRG + a`, lassen Sie los, und drücken Sie dann `d`.

## 🔄 Server aktualisieren

Ihr Minecraft-Server sollte regelmäßig aktualisiert werden, um Sicherheitslücken zu schließen, Bugs zu beheben und neue Features zu erhalten.

### Warum aktualisieren?

- **Sicherheit:** Neue Minecraft-Versionen schließen Sicherheitslücken
- **Kompatibilität:** Spieler mit neueren Minecraft-Versionen können sich verbinden
- **Bug-Fixes:** Bekannte Probleme werden behoben
- **Neue Features:** Profitieren Sie von Verbesserungen in Paper und den Plugins

### ⚠️ WICHTIG vor dem Update:

1. **Spieler informieren:** Kündigen Sie das Update im Voraus an
2. **Backup prüfen:** Das Update-Script erstellt automatisch ein Backup, aber besser doppelt sicher!
3. **Ruhezeit wählen:** Führen Sie Updates durch, wenn wenig Spieler online sind
4. **Zeit einplanen:** Updates dauern ca. 5-10 Minuten

---

### 🚀 Automatisches Update (EMPFOHLEN)

Wir haben ein sicheres Update-Script für Sie erstellt, das automatisch:
- ✅ Ein Backup erstellt
- ✅ Die neue Version herunterlädt
- ✅ Plugins aktualisiert (optional)
- ✅ Bei Fehler automatisch zur alten Version zurückkehrt

**So führen Sie ein Update durch:**

```bash
# 1. Script herunterladen (falls noch nicht vorhanden)
cd /root/Minecraft

# 2. Update starten
bash minecraft-update.sh
```

**Das Script fragt Sie:**
1. **Welche Version?** Tippen Sie `latest` für die neueste Version oder eine spezifische Version wie `1.21.11`
2. **Plugins aktualisieren?** Tippen Sie `j` für Ja oder `n` für Nein
3. **Bestätigung:** Tippen Sie `j` um fortzufahren

**Das passiert dann automatisch:**
- Server wird gestoppt
- Backup wird erstellt
- Neue Version wird heruntergeladen
- Optional: Plugins werden aktualisiert
- Server wird neu gestartet
- Update wird verifiziert

**Beispiel-Ausgabe:**
```
[?] Welche Version möchtest du installieren? latest
[✓] Version 1.21.11 ausgewählt
[?] Möchtest du auch die Plugins aktualisieren? j
[✓] Server gestoppt
[✓] Backup erstellt: pre-update-backup-2025-12-12_11-15.tar.gz
[✓] Paper 1.21.11 (Build #38) heruntergeladen
[✓] 5 Plugin(s) aktualisiert
[✓] Server erfolgreich gestartet
[✓] Update erfolgreich!
```

---

### 🔧 Manuelles Update (für Fortgeschrittene)

Falls Sie lieber manuell updaten möchten:

**Schritt 1: Server stoppen**
```bash
mc-stop
```

**Schritt 2: Backup erstellen**
```bash
cd /opt/minecraft
tar -czf backup-$(date +%Y-%m-%d).tar.gz paper.jar server.properties world world_nether world_the_end plugins
```

**Schritt 3: Neue Paper-Version herunterladen**
```bash
# Beispiel für Version 1.21.11 Build 38
cd /opt/minecraft
mv paper.jar paper.jar.old
curl -L -o paper.jar "https://api.papermc.io/v2/projects/paper/versions/1.21.11/builds/38/downloads/paper-1.21.11-38.jar"
chown minecraft:minecraft paper.jar
```

**Schritt 4: Server starten und testen**
```bash
mc-start
```

**Schritt 5: Logs prüfen**
```bash
tail -50 /opt/minecraft/logs/latest.log
```

Suchen Sie nach "Done" - das bedeutet der Server ist erfolgreich gestartet.

---

### 🆘 Bei Problemen nach dem Update

**Server startet nicht:**
```bash
# Logs prüfen
journalctl -u minecraft -n 50

# Oder direkt die Minecraft-Logs
tail -100 /opt/minecraft/logs/latest.log
```

**Häufige Probleme:**

1. **"Unsupported server version"** - Ein Plugin ist nicht kompatibel
   - Lösung: Plugin aktualisieren oder temporär deaktivieren

2. **"Address already in use"** - Port ist belegt
   - Lösung: `killall java` und Server neu starten

3. **Out of Memory** - Nicht genug RAM
   - Lösung: RAM-Zuweisung anpassen in `/opt/minecraft/start.sh`

**Backup wiederherstellen:**

Falls etwas schiefgeht, können Sie zum alten Stand zurückkehren:

```bash
# 1. Server stoppen
mc-stop

# 2. Backup finden
ls -lh /opt/minecraft/backups/

# 3. Neuestes Backup wiederherstellen (ACHTUNG: Überschreibt aktuelle Daten!)
cd /opt/minecraft
tar -xzf backups/pre-update-backup-2025-12-12_11-15.tar.gz

# 4. Server starten
mc-start
```

---

### 📅 Update-Empfehlungen

**Wie oft aktualisieren?**
- **Paper:** Bei kritischen Sicherheitsupdates sofort, sonst alle 1-2 Monate
- **Plugins:** Alle 3-6 Monate oder bei Problemen
- **Minecraft-Version:** Wenn Ihre Spieler die neue Version nutzen möchten

**Update-Strategie:**
1. Testen Sie Updates zuerst auf einem Test-Server (falls möglich)
2. Lesen Sie die Release-Notes für Breaking Changes
3. Führen Sie Updates nie während Stoßzeiten durch
4. Behalten Sie das Backup für mindestens 7 Tage

**Versionswahl:**
- **Stable Releases:** `1.21.11`, `1.21.10` etc. (empfohlen für Produktiv-Server)
- **Release Candidates:** `1.21.11-rc2` (für Test-Server)
- **Snapshots/Pre-Releases:** Nur für Entwickler

---

## 🗑️ Server deinstallieren

Falls Sie den Minecraft-Server komplett entfernen möchten, steht ein **Uninstall-Script** bereit.

### Automatische Deinstallation

```bash
cd /root/Minecraft
bash minecraft-uninstall.sh
```

**Das Script entfernt:**
- ✓ Minecraft-Server (gestoppt)
- ✓ systemd Service
- ✓ Management-Befehle (`mc-start`, `mc-stop`, etc.)
- ✓ Cron-Jobs (Backup-Schedule)
- ✓ Firewall-Regeln
- ✓ Optional: Server-Dateien und Welten
- ✓ Optional: Minecraft-Benutzer

**⚠️ WICHTIG:**
- Das Script fragt vor jedem kritischen Schritt um Bestätigung
- Welten und Backups können behalten werden
- Backup vor Deinstallation empfohlen: `tar -czf minecraft-backup.tar.gz /opt/minecraft`

### Manuelle Deinstallation

Falls Sie manuell deinstallieren möchten:

```bash
# 1. Server stoppen
mc-stop

# 2. Service deaktivieren
systemctl disable minecraft
systemctl stop minecraft
rm /etc/systemd/system/minecraft.service
systemctl daemon-reload

# 3. Management-Befehle entfernen
rm /usr/local/bin/mc-*

# 4. Cron-Jobs entfernen
crontab -u minecraft -r

# 5. Firewall-Regeln entfernen
ufw delete allow 25565/tcp
ufw delete allow 19132/udp
ufw delete allow 8080/tcp

# 6. Minecraft-Verzeichnis löschen (VORSICHT!)
rm -rf /opt/minecraft

# 7. Benutzer löschen (optional)
userdel -r minecraft
```

---

## ❓ FAQ (Häufig gestellte Fragen)

#### Wie finde ich die IP-Adresse meines Proxmox LXC Containers?
1.  Loggen Sie sich in Ihre Proxmox-Weboberfläche ein.
2.  Wählen Sie in der linken Leiste Ihren LXC-Container aus.
3.  Gehen Sie zum Tab **"Netzwerk"**.
4.  Dort sehen Sie eine Liste der Netzwerkgeräte. Die IP-Adresse (im Format `xxx.xxx.xxx.xxx`) ist die Adresse, die Sie für die Verbindung benötigen.

#### Wie kann ich ein Plugin (de)aktivieren?
Plugins werden nur geladen, wenn sie sich im Plugin-Ordner befinden und auf `.jar` enden.

1.  **Stoppen Sie den Server:** `mc-stop`
2.  **Navigieren Sie zum Plugin-Ordner:** `cd /opt/minecraft/plugins`
3.  **Deaktivieren:** Um ein Plugin zu deaktivieren, benennen Sie die `.jar`-Datei einfach um.
    - **Beispiel:** `mv EssentialsX.jar EssentialsX.jar.disabled`
4.  **Aktivieren:** Benennen Sie die Datei einfach wieder zurück.
    - **Beispiel:** `mv EssentialsX.jar.disabled EssentialsX.jar`
5.  **Starten Sie den Server neu:** `mc-restart`

#### Wo liegen die Konfigurationsdateien der Plugins?
Jedes Plugin erstellt nach dem ersten Start einen eigenen Ordner für seine Konfigurationen.

- **Pfad:** `/opt/minecraft/plugins/`
- **Beispiel (EssentialsX):** Die Konfiguration liegt in `/opt/minecraft/plugins/EssentialsX/config.yml`
- Sie können diese Dateien mit einem Texteditor wie `nano` bearbeiten: `nano /opt/minecraft/plugins/EssentialsX/config.yml`.

---

Dieses Projekt wurde mit dem Ziel erstellt, die Einrichtung eines Minecraft-Servers so einfach und zugänglich wie möglich zu machen.
