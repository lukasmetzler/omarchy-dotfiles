# Omarchy Backup Script

Automated script for system backups, updates, and maintenance on Arch Linux.

## Setup

1. Make the script executable:
   ```bash
   chmod +x ~/Documents/omarchy-backup/backup.sh
   ```

2. Create an alias:
Add the following line to the end of your shell configuration (`~/.bashrc` or `~/.zshrc`):
```bash
alias my-backup="$HOME/Documents/omarchy-backup/backup.sh"
```


3. Reload shell:
```bash
source ~/.bashrc
# or for Zsh:
source ~/.zshrc

```

## Usage
Run the backup and update process from the terminal:
```bash
my-backup
```
