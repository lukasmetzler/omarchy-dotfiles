#!/bin/bash

# --- CONFIGURATION ---
# Destination directory for the backup
BACKUP_DIR="$HOME/Documents/omarchy-backup"
DATE=$(date +"%Y-%m-%d_%H-%M")

echo "Starting System Backup..."

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

# Check if 'yay' is installed to update both System and AUR
if command -v yay &> /dev/null; then
    echo "Using 'yay' to update system and AUR packages..."
    yay
else
    # Fallback to standard pacman if yay is not found
    echo "Using 'pacman' to update system..."
    sudo pacman -Syu
fi

echo "All tasks completed successfully!
