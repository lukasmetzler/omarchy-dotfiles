#!/bin/bash

# --- CONFIGURATION ---
BACKUP_DIR="$HOME/Documents/omarchy-backup"
DATE=$(date +"%Y-%m-%d_%H-%M")

echo "---------------------------------------"
echo "Starting System Backup..."
echo "---------------------------------------"

# 1. Ensures directory structure exists
mkdir -p "$BACKUP_DIR/configs"

# 2. Export package lists
echo "Backing up package lists..."
pacman -Qqe > "$BACKUP_DIR/pkglist_native.txt"
pacman -Qqm > "$BACKUP_DIR/pkglist_aur.txt"

# 3. Backup configurations (Dotfiles)
echo "Backing up general configurations..."

# Shells
cp ~/.zshrc "$BACKUP_DIR/configs/.zshrc" 2>/dev/null
cp ~/.bashrc "$BACKUP_DIR/configs/.bashrc" 2>/dev/null

# Apps & Chromium Flags (Neu hinzugefügt)
echo "Backing up App configs (including Chromium flags)..."
rsync -av --delete ~/.config/espanso "$BACKUP_DIR/configs/"
[ -f ~/.config/chromium-flags.conf ] && cp ~/.config/chromium-flags.conf "$BACKUP_DIR/configs/"
[ -d ~/.config/zed ] && rsync -av --delete ~/.config/zed "$BACKUP_DIR/configs/"
[ -d ~/.config/ghostty ] && rsync -av --delete ~/.config/ghostty "$BACKUP_DIR/configs/"

# 4. Hyprland & Waybar
echo "Backing up Hyprland & Waybar..."
[ -d ~/.config/hypr ] && rsync -av --delete ~/.config/hypr "$BACKUP_DIR/configs/"
[ -d ~/.config/waybar ] && rsync -av --delete ~/.config/waybar "$BACKUP_DIR/configs/"

# 5. Git Sync
cd "$BACKUP_DIR"
if [ -d .git ]; then
    echo "Git repository detected. Pushing to remote..."
    git add .
    git commit -m "Backup from $DATE"
    git push
    echo "Backup pushed to GitHub successfully."
else
    echo "Warning: Not a git repository."
fi

# 6. System Update
echo "---------------------------------------"
echo "Starting System Update..."
echo "---------------------------------------"
if command -v yay &> /dev/null; then
    yay --noconfirm
else
    sudo pacman -Syu --noconfirm
fi

# Firmware update
echo "---------------------------------------"
echo "Checking for Firmware Updates..."
echo "---------------------------------------"
if command -v fwupdmgr &> /dev/null; then
    fwupdmgr refresh --force
    fwupdmgr update -y
fi

# 7. Cleanup
echo "---------------------------------------"
echo "Cleanup..."
echo "---------------------------------------"

sync

sudo rm -f /var/cache/pacman/pkg/download-*

echo "Cleaning pacman cache..."
sudo pacman -Sc --noconfirm

if command -v yay &> /dev/null; then
    echo "Cleaning AUR cache and orphans..."
    yay -Sc --aur --noconfirm
    yay -Yc --noconfirm
fi

sudo /usr/bin/pacman -D --check

# 8. Health Check
echo "---------------------------------------"
echo "Final System Health Check..."
echo "---------------------------------------"
FAILED_SERVICES=$(systemctl --failed --no-legend)
if [ -z "$FAILED_SERVICES" ]; then
    echo "All systemd services are running correctly. Green status."
else
    echo "WARNING: The following services have failed:"
    systemctl --failed
fi

echo "---------------------------------------"
echo "Backup and Cleanup completed!"
echo "---------------------------------------"
