#!/bin/bash

# --- CONFIGURATION ---
# Destination directory for the backup
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

# Apps
rsync -av --delete ~/.config/espanso "$BACKUP_DIR/configs/"
[ -d ~/.config/zed ] && rsync -av --delete ~/.config/zed "$BACKUP_DIR/configs/"
[ -d ~/.config/zeditor ] && rsync -av --delete ~/.config/zeditor "$BACKUP_DIR/configs/"

# 4. Hyprland & Waybar
echo "Backing up Hyprland & Waybar..."

if [ -d ~/.config/hypr ]; then
    rsync -av --delete ~/.config/hypr "$BACKUP_DIR/configs/"
else
    echo "Warning: No Hyprland folder found."
fi

if [ -d ~/.config/waybar ]; then
    rsync -av --delete ~/.config/waybar "$BACKUP_DIR/configs/"
else
    echo "Warning: No Waybar folder found."
fi

# 5. Git Sync
cd "$BACKUP_DIR"

if [ -d .git ]; then
    echo "Git repository detected. Pushing to remote..."
    git add .
    git commit -m "Backup from $DATE"
    git push
    echo "Backup pushed to GitHub successfully."
else
    echo "Warning: Not a git repository. Files saved locally, but not pushed."
fi

echo "Backup finished!"

# 6. System Update
echo "---------------------------------------"
echo "Backup finished. Starting System Update..."
echo "---------------------------------------"

if command -v yay &> /dev/null; then
    echo "Using 'yay' to update system and AUR packages..."
    yay
else
    echo "Using 'pacman' to update system..."
    sudo pacman -Syu
fi

echo "All tasks completed successfully!"

echo "---------------------------------------"
echo "Checking for Firmware Updates (lvfs)"
echo "---------------------------------------"

# Firmware update
if command -v fwupdmgr &> /dev/null; then
    echo "Refreshing firmware metadata..."
    fwupdmgr refresh
    echo "Checking and applying firmware updates..."
    fwupdmgr update
else
    echo "fwupd is not installed. Skipping firmware update."
fi


# 7. Cleanup
echo "---------------------------------------"
echo "Cleanup..."
echo "---------------------------------------"

# Clean package cache and remove orphans
if command -v yay &> /dev/null; then
    yay -Sc --noconfirm
    yay -Yc --noconfirm
else
    sudo pacman -Sc --noconfirm
    sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null
fi

# Remove temporary files and directories
rm -rf "$BACKUP_DIR/tmp"

echo "Cleanup completed!"

#8. Health Check
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
