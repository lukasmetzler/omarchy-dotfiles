#!/bin/bash

# --- CONFIGURATION ---
# Destination directory for the backup
BACKUP_DIR="$HOME/omarchy-backup"
DATE=$(date +"%Y-%m-%d_%H-%M")

echo "Starting Omarchy Backup..."

# 1. Ensure directory structure exists
mkdir -p "$BACKUP_DIR/configs"

# 2. Export package lists
# -Qqe = All explicitly installed native packages
# -Qqm = All AUR packages (foreign)
echo "Backing up package lists..."
pacman -Qqe > "$BACKUP_DIR/pkglist_native.txt"
pacman -Qqm > "$BACKUP_DIR/pkglist_aur.txt"

# 3. Backup configurations (Dotfiles)
echo "Backing up general configurations (Shell, Zed, Espanso)..."

# Shells (Zsh / Bash)
cp ~/.zshrc "$BACKUP_DIR/configs/.zshrc" 2>/dev/null
cp ~/.bashrc "$BACKUP_DIR/configs/.bashrc" 2>/dev/null

# Apps: Espanso & Zed
rsync -av --delete ~/.config/espanso "$BACKUP_DIR/configs/"

# Zed config
[ -d ~/.config/zed ] && rsync -av --delete ~/.config/zed "$BACKUP_DIR/configs/"
[ -d ~/.config/zeditor ] && rsync -av --delete ~/.config/zeditor "$BACKUP_DIR/configs/"

# 4. Hyprland & Waybar
echo "Backing up Hyprland & Waybar..."

# Hyprland Configs
if [ -d ~/.config/hypr ]; then
    rsync -av --delete ~/.config/hypr "$BACKUP_DIR/configs/"
else
    echo "Warning: No Hyprland folder found."
fi

# Waybar Configs
if [ -d ~/.config/waybar ]; then
    rsync -av --delete ~/.config/waybar "$BACKUP_DIR/configs/"
else
    echo "Warning: No Waybar folder found."
fi

# 5. Git (Optional - Uncomment if needed)
# cd "$BACKUP_DIR"
# git add .
# git commit -m "Backup from $DATE"
# git push

echo "Backup successfully saved in $BACKUP_DIR!"
