# Minecraft PaperMC Server Installer

**Language / Sprache:** [🇩🇪 Deutsch](README.md) | [🇬🇧 English](README.en.md)

[![Operating System](https://img.shields.io/badge/OS-Debian%20%2F%20Ubuntu-blue?style=for-the-badge&logo=debian)](https://www.debian.org/)
[![Java Version](https://img.shields.io/badge/Java-21-orange?style=for-the-badge&logo=openjdk)](https://www.java.com/)
[![GitHub Repo Size](https://img.shields.io/github/repo-size/hehljo/Minecraft-PaperMC-Installer?style=for-the-badge&logo=github)](https://github.com/hehljo/Minecraft-PaperMC-Installer)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](https://github.com/hehljo/Minecraft-PaperMC-Installer/blob/main/LICENSE)

<a href="https://buymeacoffee.com/pommesbude" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

**Fully automated, interactive installation script for a powerful and stable Minecraft server on any Debian-based system (including Proxmox LXC).**

> **📖 Full Documentation:** For detailed guides, troubleshooting, and advanced features, please see the [German README](README.md) (use your browser's translation feature if needed).

---

## 🔗 Compatibility

**Tested with:**
- **Paper:** 1.21.10 Build #117 (stable with Geyser)
- **Bedrock:** 1.21.90 - 1.21.130
- **Geyser:** 2.9.2+ (Java ↔ Bedrock cross-play)

**Important:** Bedrock clients cannot downgrade. The script automatically uses compatible versions!

---

## ⚡ Quick Start

```bash
bash -c "$(curl -sSL https://raw.githubusercontent.com/hehljo/Minecraft/main/minecraft-install.sh)"
```

The script will guide you through the installation with interactive prompts.

---

## ⭐ Key Features

### Automated Installation
- **Dynamic Resource Detection:** Automatically detects IP address, RAM, and CPU cores
- **Optimized Performance:** Uses [PaperMC](https://papermc.io/) with [Aikar's Flags](https://mcflags.emc.gs/)
- **SystemD Integration:** Automatic startup, resource limits, and easy management

### Optional Plugins (Choose during installation)
- **GeyserMC + Floodgate:** Cross-play between Java Edition (PC) and Bedrock Edition (Mobile/Console)
- **EssentialsX:** 100+ admin commands and utilities
- **LuckPerms:** Fast and reliable permissions management with web editor
- **BentoBox + AOneBlock:** OneBlock game mode
- **MultiWorld + FacilisCommon:** Multiple world management with auto-import
- **Pl3xMap:** Live web-based map (Port 8080)
- **Vault + ChestShop:** Economy system with player shops
- **WorldGuard + WorldEdit:** Region protection and world editing

### Professional Management
- **SystemD Service:** Server runs as a service with automatic restart
- **Management Commands:**
  - `mc-start` / `mc-stop` / `mc-restart` - Start, stop, restart server
  - `mc-status` - Show detailed status
  - `mc-console` - Attach to live console (exit with `Ctrl+a`, then `d`)
- **Automatic Daily Backups:** Via cron job at 4 AM
- **UFW Firewall Configuration:** Automatic port setup

---

## 📋 Requirements

- Debian-based OS (Debian 11/12, Ubuntu 22.04+, Proxmox LXC)
- Root access (or sudo privileges)
- Minimum 2 GB RAM recommended

---

## 🚀 After Installation

### Connect to Your Server

- **Java Edition (PC):** `YOUR_SERVER_IP:25565`
- **Bedrock Edition (Mobile/Console):** `YOUR_SERVER_IP` (Port: `19132`)

### Give Yourself Admin Rights

```bash
mc-console
op YOUR_MINECRAFT_NAME
```

Exit console with `Ctrl+a`, then `d`.

### Test Installed Features

**Cross-Play (Geyser):**
- Connect with Bedrock client to port 19132
- You should see Java players and vice versa!

**Live Map (Pl3xMap):**
- Open in browser: `http://YOUR_SERVER_IP:8080`
- See your world in real-time

**MultiWorld:**
- List all worlds: `/world list`
- Create new world: `/world create myworld NORMAL -t NORMAL`
- Teleport: `/world teleport myworld`

**Economy (ChestShop):**
- Place a chest
- Place a sign next to it with:
  - Line 1: (empty)
  - Line 2: `10` (quantity)
  - Line 3: `B 50:10 S` (buy:sell price)
  - Line 4: `diamond` (item name)

**Protection (WorldGuard):**
- Hold a wooden axe
- Left-click one corner, right-click opposite corner
- `/region define myregion`

---

## 🔄 Update Your Server

```bash
cd /root/Minecraft
bash minecraft-update.sh
```

The script will:
- Create automatic backup
- Download new version
- Update plugins (optional)
- Restart server
- Roll back automatically if errors occur

---

## 🗑️ Uninstall

```bash
cd /root/Minecraft
bash minecraft-uninstall.sh
```

The script will ask for confirmation before removing:
- Minecraft server
- SystemD service
- Management commands
- Cron jobs
- Firewall rules
- Optionally: World data and backups

---

## 📚 Detailed Documentation

This is a quick-start guide. For comprehensive documentation including:

- **World Migration:** Import Singleplayer and Server worlds
- **MultiWorld Setup:** Detailed multi-world management guide
- **OneBlock World Creation:** Step-by-step tutorial
- **Map Configuration:** Multi-world map viewing
- **LiveAtlas Setup:** Modern map frontend
- **Troubleshooting:** Common issues and solutions
- **FAQ:** Frequently asked questions

**Please see the [German README](README.md)** (use browser translation if needed).

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Support

If you find this project helpful, consider:

<a href="https://buymeacoffee.com/pommesbude" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

---

**Made with ❤️ for the Minecraft community**
