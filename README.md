# gnomp - GNOME Backup & Restore Script

A simple script to backup and restore GNOME settings, extensions, and their configurations. Supports both Wayland and X11 sessions.

## Features

* **Comprehensive Backup:** Backs up GNOME settings (`dconf`), user extensions, and key config directories.
* **Easy Restore:** Restores all settings and extensions from a single timestamped backup file.
* **Auto-Reload:** Fully reloads the GNOME Shell and extensions after a restore to apply settings immediately.
* **Drag-and-Drop:** Supports dragging and dropping the backup file onto the terminal when prompted for the path.
* **Safe Backups:** Creates timestamped backups to prevent new backups from overwriting old ones.

---

## Requirements

Before running, ensure you have the following tools installed:

* `dconf` (or `dconf-cli`)
* `gnome-extensions` (or `gnome-extensions-cli`)

---

## Installation

1.  Save the script as `gnome_backup_restore.sh`.
2.  Make the script executable:
    ```bash
    chmod +x gnome_backup_restore.sh
    ```

---

## Usage

1.  Run the script in your terminal:
    ```bash
    ./gnome_backup_restore.sh
    ```
2.  Choose an option from the menu:
    * **1: Backup** - Creates a new backup of your current settings.
    * **2: Restore** - Restores your settings from a previous backup.
3.  If restoring, you will be prompted for the path to the backup file. You can drag and drop the file from your file manager directly into the terminal to paste its full path.

---

## Backup Details

### Backup Location

All backups are saved as `.tar.gz` files in:
`$HOME/gnome_backup`

### What's Included

Each backup archive contains:

* A full `dconf` export of all GNOME settings.
* `~/.config`
* `~/.local/share`
* `~/.gnome`
* `~/.local/share/gnome-shell/extensions`

---

## Notes

* **On Wayland:** Extensions are reloaded automatically using D-Bus. However, some complex extensions may still require a manual logout and login to fully apply all changes.
* **On X11:** The script will automatically restart the GNOME Shell to apply the restored settings.
