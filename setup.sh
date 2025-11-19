#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting setup for niri dotfiles...."

# --- Preflight checks ---
echo "==> Check if os is 'Arch Linux'..."
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$NAME" != "Arch Linux" ] | [ "$NAME" != "CachyOS Linux" ]; then
        echo "Error: This script is only intended for $EXPECTED_OS."
        echo "Detected OS: $NAME"
        exit 1
    else
        echo "OS check passed: $NAME detected."
    fi
else
    echo "Warning: Cannot determine the OS using /etc/os-release."
    exit 1
fi

echo "==> Check if pacman is installed..."
if ! command -v pacman &> /dev/null; then
    echo "Error: 'pacman' is not installed or not in the PATH."
    echo "This script is intended for Arch Linux or Arch-based systems."
    exit 1
fi

echo "==> Add chaotic AUR repo..."
# Define the configuration file path and the repository name
PACMAN_CONF="/etc/pacman.conf"
REPO_NAME="chaotic-aur"
KEY_ID="3056513887B78AEB" # The primary key ID for Chaotic-AUR

# Function to install the Chaotic-AUR
install_chaotic_aur() {
    echo "Attempting to install the [$REPO_NAME] repository..."

    # 1. Install the primary key
    echo "Importing the primary key..."
    sudo pacman-key --recv-key $KEY_ID --keyserver keyserver.ubuntu.com
    sudo pacman-key --lsign-key $KEY_ID

    # 2. Install the chaotic-keyring and chaotic-mirrorlist packages
    echo "Installing chaotic-keyring and chaotic-mirrorlist packages..."
    sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

    # 3. Append the repository entry to pacman.conf
    echo "Adding the repository entry to $PACMAN_CONF..."
    sudo bash -c "echo '' >> '$PACMAN_CONF'"
    sudo bash -c "echo '[$REPO_NAME]' >> '$PACMAN_CONF'"
    sudo bash -c "echo 'Include = /etc/pacman.d/chaotic-mirrorlist' >> '$PACMAN_CONF'"

    # 4. Update the system and sync package databases
    echo "Syncing package databases and updating the system..."
    sudo pacman -Syu --noconfirm

    echo "The [$REPO_NAME] repository has been successfully installed and enabled."
}

# Main logic to check and install
if grep -E "^\[$REPO_NAME\]" "$PACMAN_CONF" > /dev/null; then
    echo "The [$REPO_NAME] repository is already in $PACMAN_CONF and is enabled."
elif grep -E "^#\[$REPO_NAME\]" "$PACMAN_CONF" > /dev/null; then
    echo "The [$REPO_NAME] repository is in $PACMAN_CONF but is commented out (disabled)."
    read -p "Do you want to enable it now? (y/N): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        # Uncomment the lines if user agrees. Requires root for sed.
        sudo sed -i "/^#\[$REPO_NAME\]/,/^#Include =/s/^#//" "$PACMAN_CONF"
        echo "The [$REPO_NAME] repository has been enabled. Running full system update..."
        sudo pacman -Syu --noconfirm
        echo "Update complete."
    fi
else
    echo "The [$REPO_NAME] repository is not found in $PACMAN_CONF."
    install_chaotic_aur
fi

echo "==> Make sure git is installed..."
sudo pacman -Syu --needed --noconfirm git base-devel fakeroot

# --- Configuration ---
# The location of the main dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The directory where stow will deploy the files (your home directory)
TARGET_DIR="$HOME"
# The directory where backups will be stored
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d-%H%M%S)"




# PLACEHOLDER echo "==> Clone dotfiles repository..."



# --- Package installation ---
echo "==> Installing required packages..."
# The files where the packages to install are configured
PKG_FILE="$DOTFILES_DIR/packages.txt"
AUR_FILE="$DOTFILES_DIR/aur-packages.txt"
# --- Pacman packages ---
if [[ -f "$PKG_FILE" ]]; then
    echo -e "\n📦 Installing packages from 'packages.txt'..."
    while IFS= read -r pkg; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if ! pacman -Q "$pkg" &>/dev/null; then
            echo "  ➜ Installing $pkg..."
            sudo pacman -S --needed --noconfirm "$pkg"
        else
            echo "  ✓ $pkg already installed"
        fi
    done < "$PKG_FILE"
else
    echo "⚠️  No 'packages.txt' found, skipped."
fi

# --- Install paru if not installed ---
if ! command -v paru > /dev/null; then
    # Download the binary version to avoid compilation
    git clone https://aur.archlinux.org/paru-bin.git ~/repos/paru-bin
    cd ~/repos/paru-bin
    makepkg --syncdeps --install
    cd -
fi

# --- AUR packages ---
if [[ -f "$AUR_FILE" ]]; then
    echo -e "\n🌟 Installing AUR packages from 'aur-packages.txt'..."
    while IFS= read -r aurpkg; do
        [[ -z "$aurpkg" || "$aurpkg" == \#* ]] && continue
        if ! paru -Q "$aurpkg" &>/dev/null; then
            echo "  ➜ Installing $aurpkg..."
            paru -S --needed --noconfirm "$aurpkg"
        else
            echo "  ✓ $aurpkg already installed"
        fi
    done < "$AUR_FILE"
else
    echo "⚠️  No 'aur-packages.txt' found, skipped."
fi

# --- Enable Fish shell ---
if command -v fish >/dev/null 2>&1; then
    CURRENT_SHELL=$(basename "$SHELL")
    if [[ "$CURRENT_SHELL" != "fish" ]]; then
        echo "==> Enabling Fish shell..."
        if chsh -s "$(command -v fish)"; then
            echo "✅ Fish shell set successfully!"
        else
            echo "⚠️ Failed to change shell, please run 'chsh -s $(command -v fish)' manually."
        fi
    fi
fi

# --- Enable ly display manager ---
if command -v ly-dm >/dev/null 2>&1; then
    echo "==> Enabling ly display manager..."
    sudo systemctl enable ly.service
    echo "✅ ly enabled successfully!"
else
    echo "⚠️ ly not found, skipped enabling display manager."
fi

# --- Check stow ---
if ! command -v stow >/dev/null 2>&1; then
    echo "==> stow not found, installing..."
    sudo pacman -S --needed --noconfirm stow
fi

echo "==> Backup existing dotfiles and create symlinks with stow..."
echo "Dotfiles repository: $DOTFILES_DIR"
echo "Backup directory: $BACKUP_DIR"

# Create the main backup directory
mkdir -p "$BACKUP_DIR"
echo "Created backup directory: $BACKUP_DIR"

# Navigate into the dotfiles directory
cd "$DOTFILES_DIR"

# --- Conflict Resolution Loop ---
# Iterate through each package directory (e.g., paru, bat)
for package_dir in */; do
    package_name=$(basename "$package_dir")
    echo "Stow: $package_name"

    # Navigate into the specific package directory to correctly calculate paths
    cd "$DOTFILES_DIR/$package_name"

    # Find all files and symlinks inside this package (not directories themselves)
    find . -type f -o -type l | while IFS= read -r source_rel_path; do
        
        # Remove the leading './' from the path
        source_rel_path="${source_rel_path#./}"
        
        # The full path where this file would link to in $HOME
        full_target_path="$TARGET_DIR/$source_rel_path"

        # Check if the target path exists in $HOME (as a file, dir, or symlink)
        if [ -e "$full_target_path" ] || [ -L "$full_target_path" ]; then
            
            is_managed=false
            if [ -L "$full_target_path" ]; then
                # Check if the existing item is a symlink pointing back into our repo
                actual_source=$(readlink -f "$full_target_path")
                if [[ "$actual_source" == "$DOTFILES_DIR"* ]]; then
                    is_managed=true
                fi
            fi

            if [ "$is_managed" = false ]; then
                # This item is an unmanaged conflict
                echo "Found unmanaged conflict file: $full_target_path. Backing up and resolving..."
                
                backup_location="$BACKUP_DIR/$source_rel_path"

                # Ensure the parent directory in the backup location exists
                mkdir -p "$(dirname "$backup_location")"
                
                # Move ONLY this specific file/symlink
                mv "$full_target_path" "$backup_location"
                echo "Moved existing '$full_target_path' to '$backup_location'"
            fi
        fi
    done

    # Navigate back to the root of the repo for the next iteration
    cd "$DOTFILES_DIR"
    stow -R -t "$TARGET_DIR" $package_name --no-folding
done
echo "Backup and stow process finished successfully."

echo "==> Creating systemd user services..."
systemctl --user add-wants niri.service hypridle.service

echo "==> Done! 🎉"
