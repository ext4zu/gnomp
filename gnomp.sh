#!/usr/bin/env bash
set -e

BACKUP_DIR="$HOME/gnome-backup-$(date +%Y%m%d-%H%M%S)"
RESTORE_DIR="$HOME/gnome-backup-latest"

# ====== DEPENDENCY CHECK ======
check_deps() {
    echo "Checking required dependencies..."
    REQUIRED=("curl" "wget" "unzip" "jq" "dconf" "gnome-extensions" "tar" "gsettings")
    MISSING=()

    for pkg in "${REQUIRED[@]}"; do
        if ! command -v "$pkg" &>/dev/null; then
            MISSING+=("$pkg")
        fi
    done

    if [ ${#MISSING[@]} -ne 0 ]; then
        echo "Installing missing packages: ${MISSING[*]}"
        sudo dnf install -y "${MISSING[@]}"
    else
        echo "All required dependencies are installed."
    fi
}

# ====== BACKUP ======
backup() {
    echo "Starting GNOME backup..."
    mkdir -p "$BACKUP_DIR"

    echo "Backing up GNOME settings..."
    dconf dump / > "$BACKUP_DIR/dconf-settings.ini"

    echo "Saving list of enabled extensions..."
    gnome-extensions list --enabled > "$BACKUP_DIR/extensions-list.txt"

    echo "Backing up local GNOME extensions..."
    mkdir -p "$BACKUP_DIR/extensions"
    cp -r ~/.local/share/gnome-shell/extensions/* "$BACKUP_DIR/extensions/" 2>/dev/null || true

    echo "Backing up fonts, icons, and themes..."
    mkdir -p "$BACKUP_DIR/themes"
    cp -r ~/.icons ~/.local/share/icons ~/.themes ~/.local/share/themes ~/.fonts ~/.local/share/fonts "$BACKUP_DIR/themes/" 2>/dev/null || true

    echo "Backing up GDM theme if customized..."
    sudo cp -r /usr/share/gnome-shell/theme "$BACKUP_DIR/gdm-theme" 2>/dev/null || true

    echo "Compressing backup archive..."
    tar czf "$BACKUP_DIR.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")"

    echo "Backup completed successfully."
    echo "Backup archive created at: $BACKUP_DIR.tar.gz"
}

# ====== RESTORE ======
restore() {
    echo "Starting GNOME restore process..."
    echo "Enter the path to your backup .tar.gz file:"
    read -r TARFILE

    if [ ! -f "$TARFILE" ]; then
        echo "Error: Backup file not found."
        exit 1
    fi

    mkdir -p "$RESTORE_DIR"
    tar xzf "$TARFILE" -C "$RESTORE_DIR" --strip-components=1

    echo "Restoring GNOME settings..."
    dconf load / < "$RESTORE_DIR/dconf-settings.ini"

    echo "Restoring local GNOME extensions..."
    mkdir -p ~/.local/share/gnome-shell/extensions/
    cp -r "$RESTORE_DIR/extensions/"* ~/.local/share/gnome-shell/extensions/ 2>/dev/null || true

    echo "Reinstalling missing online extensions..."
    while read -r ext_uuid; do
        [ -z "$ext_uuid" ] && continue
        if ! gnome-extensions info "$ext_uuid" &>/dev/null; then
            echo "Installing extension: $ext_uuid"
            VERSION=$(gnome-shell --version | awk '{print $3}' | cut -d'.' -f1,2)
            INFO_URL="https://extensions.gnome.org/extension-info/?uuid=$ext_uuid&shell_version=$VERSION"
            ZIP_PATH=$(curl -s "$INFO_URL" | grep -oP '(?<=\"download_url\": \")[^\"]*')
            if [ -n "$ZIP_PATH" ]; then
                mkdir -p ~/.local/share/gnome-shell/extensions/"$ext_uuid"
                wget -qO /tmp/ext.zip "https://extensions.gnome.org$ZIP_PATH"
                unzip -oq /tmp/ext.zip -d ~/.local/share/gnome-shell/extensions/"$ext_uuid"
                echo "Extension $ext_uuid installed successfully."
            else
                echo "Warning: Could not download extension $ext_uuid."
            fi
        fi
        gnome-extensions enable "$ext_uuid" 2>/dev/null || true
    done < "$RESTORE_DIR/extensions-list.txt"

    echo "Restoring themes and fonts..."
    cp -r "$RESTORE_DIR/themes/"* ~ 2>/dev/null || true
    sudo cp -r "$RESTORE_DIR/gdm-theme" /usr/share/gnome-shell/theme 2>/dev/null || true

    echo "Applying restored GNOME settings..."
    gsettings reset-recursively org.gnome.shell || true
    gsettings reset-recursively org.gnome.desktop.interface || true
    gsettings reset-recursively org.gnome.desktop.wm.preferences || true
    gsettings set org.gnome.shell enabled-extensions "$(cat "$RESTORE_DIR/extensions-list.txt" | jq -R -s -c 'split("\n")[:-1]')"

    echo "Reloading GNOME Shell..."
    busctl --user call org.gnome.Shell /org/gnome/Shell org.gnome.Shell Eval "s" 'Meta.restart("Restoring GNOME configuration...")' 2>/dev/null || \
        echo "Please log out and log back in manually to complete the restoration."

    echo "GNOME restore process completed successfully."
}

# ====== MENU ======
check_deps
echo "======================================"
echo " Fedora 43 GNOME Backup and Restore Tool"
echo "======================================"
echo "1) Backup GNOME"
echo "2) Restore GNOME"
echo "Select an option (1/2): "
read -r CHOICE

case "$CHOICE" in
    1) backup ;;
    2) restore ;;
    *) echo "Invalid option selected." ;;
esac
