# gnomp - GNOME Settings Backup & Restore Tool

A shell script for backing up and restoring GNOME desktop settings, extensions, and configurations.  
Works with both Wayland and X11 sessions.

---

## Requirements

Ensure the following tools are installed before running:

- `dconf` or `dconf-cli`  
- `gnome-extensions` or `gnome-extensions-cli`

---

## Usage

Clone the repository:
```bash
git clone https://github.com/ext4zu/gnomp.git
cd gnomp
```
Make it executable:
```bash
chmod +x gnomp.sh
```
Run the script from your terminal:
```bash
./gnomp.sh
```


### Menu Options

1. **Backup** – Create a new timestamped backup of your GNOME settings  
2. **Restore** – Restore settings from a selected backup file

When restoring, you can drag and drop the backup file into the terminal to auto-fill its path.

---

## Backup Contents

Backups are saved as `.tar.gz` archives in:
```
$HOME/gnome_backup
```

Each archive includes:

- Full `dconf` export of GNOME settings  
- `~/.config`  
- `~/.local/share`  
- `~/.gnome`  
- `~/.local/share/gnome-shell/extensions`

---

## Notes

- On Wayland: Extensions reload automatically via D-Bus. Some may require logout/login to fully apply.  
- On X11: GNOME Shell is restarted automatically after restore to apply changes.

---

## Exit

Press `Ctrl + C` to cancel or exit the script at any time.
