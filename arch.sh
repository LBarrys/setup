#!/bin/bash

#Paru
cd
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si

# Identifiers
CONFIG_FILE="/etc/mkinitcpio.conf"
BACKUP_FILE="${CONFIG_FILE}.bak"
NEW_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
Nvidia="nvidia-dkms nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia linux-headers"
PACMANs="flatpak alacritty timeshift grub-btrfs timeshift-autosnap inotify-tools cloudflare-warp-bin firefox thunderbird telegram-desktop gnome-disk-utility fastfetch vlc vlc-plugins-all mission-center steam wine winetricks dxvk-bin prismlauncher mangohud mangojuice komikku papirus-icon-theme papirus-folders bat wget 7zip unrar jre-openjdk prismlauncher qemu-full qemu-img libvirt virt-install virt-manager edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned"
Flatpaks="com.vysp3r.ProtonPlus com.usebottles.bottles"
GNOME="gdm gnome-shell gnome-tweaks gnome-control-center nautilus gnome-text-editor gdm-settings com.mattjakeman.ExtensionManager io.github.Foldex.AdwSteamGtk gnome-weather gnome-shell-extension-appindicator gnome-shell-extension-vitals transmission-gtk extra/breeze"
Plasma="sddm-kcm plasma-desktop plasma-nm plasma-pa kscreen breeze-gtk kde-gtk-config nemo-fileroller xed transmission-qt"
Fonts="ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-roboto"

# GNOME
# paru -S $GNOME
# sudo systemctl enable gdm

# Plasma
# paru -S $Plasma
# sudo systemctl enable sddm

# Install nvidia proprietary drivers
paru -S $Nvidia

# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "File $CONFIG_FILE does not exist."
    exit 1
fi

# Backup the original file
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backup created at $BACKUP_FILE"

# Use awk to modify the MODULES line
awk -v new_mods="$NEW_MODULES" '
BEGIN {
    split(new_mods, add_arr, " ")
    for (i in add_arr) {
        to_add[add_arr[i]] = 1
    }
    found = 0
}
{
    if (/^MODULES=\(/) {
        found = 1
        # Extract existing modules
        line = $0
        gsub(/^MODULES=\(/, "", line)
        gsub(/\)$/, "", line)
        split(line, existing, /[ \t]+/)
        # Track current modules in an array
        delete current
        for (i in existing) {
            if (existing[i] != "") {
                current[existing[i]] = 1
            }
        }
        # Add new modules if not present
        for (mod in to_add) {
            if (!(mod in current)) {
                current[mod] = 1
            }
        }
        # Reconstruct the line
        printf "MODULES=("
        first = 1
        for (mod in current) {
            if (!first) printf " "
            printf "%s", mod
            first = 0
        }
        printf ")\n"
    } else {
        print $0
    }
}
END {
    # If no MODULES line was found, append it
    if (!found) {
        printf "MODULES=(%s)\n", new_mods
    }
}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"

# Replace the original file
mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub

sudo sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"loglevel=3 quiet nvidia-drm.modeset=1\"/" /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install RPMs & flatpaks
paru -S $PACMANs
flatpak install flathub $Flatpaks
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"
sudo systemctl enable warp-svc.service
sudo systemctl enable tuned.service

# Install fonts
paru -S $Fonts

# Systemd services
sudo systemctl set-default graphical.target
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable --now grub-btrfs.path
sudo systemctl enable warp-svc.service

# My configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config
mv ~/setup/alacritty ~/.config

#bashrc
echo "#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias autorm='sudo pacman -Rns $(pacman -Qdtq)'
alias in='sudo pacman -S'
alias rm='sudo pacman -Rns'
alias se='pacman -Ss'
alias timeshiftC='sudo timeshift --create'
alias timeshiftR='sudo timeshift --restore'
alias timeshiftD='sudo timeshift --delete'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo arch_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
