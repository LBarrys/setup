#!/bin/bash

#yay
cd
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

# Identifiers
CONFIG_FILE="/etc/mkinitcpio.conf"
BACKUP_FILE="${CONFIG_FILE}.bak"
NEW_MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
Nvidia="nvidia-dkms nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia linux-headers"
PACMANs="ghostty timeshift grub-btrfs timeshift-autosnap inotify-tools cloudflare-warp-bin firefox betterbird-bin telegram-desktop gnome-disk-utility fastfetch vlc vlc-plugins-all mission-center komikku papirus-icon-theme papirus-folders bat wget 7zip unrar jre-openjdk qemu-full qemu-img libvirt virt-install virt-manager edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned"
Gaming="alsa-lib alsa-plugins fontconfig gamemode gamescope giflib glfw gnutls gst-plugin-pipewire gst-plugin-va gst-plugins-bad gst-plugins-bad-libs gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly gtk2 gtk2+extra gtk3 libgcrypt libgpg-error libjpeg-turbo libldap libpng libpulse libva libva-mesa-driver libxcomposite libxinerama libxslt mangohud mangojuice mpg123 ncurses ocl-icd openal opencl-icd-loader sqlite adwsteamgtk steam protonplus ttf-liberation v4l-utils vkd3d vulkan-icd-loader prismlauncher dxvk-bin bottles wine-gecko wine-mono wine-staging winetricks wqy-zenhei lib32-alsa-lib lib32-alsa-plugins lib32-fontconfig lib32-giflib lib32-gnutls lib32-gst-plugins-base-libs lib32-gst-plugins-good lib32-gtk3 lib32-libgcrypt lib32-libgpg-error lib32-libjpeg-turbo lib32-libldap lib32-libpng lib32-libpulse lib32-libva lib32-libva-mesa-driver lib32-libxcomposite lib32-libxinerama lib32-libxslt lib32-mangohud lib32-mpg123 lib32-ncurses lib32-ocl-icd lib32-openal lib32-sqlite lib32-v4l-utils lib32-vkd3d lib32-vulkan-icd-loader"
GNOME="gdm gnome-shell gnome-tweaks gnome-control-center nautilus gnome-text-editor gdm-settings extension-manager gnome-weather transmission-gtk extra/breeze"
Fonts="ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-roboto ttf-ms-fonts"

# GNOME
yay -S $GNOME
sudo systemctl enable gdm

# Install nvidia proprietary drivers
yay -S $Nvidia

# Check if file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "File $CONFIG_FILE does not exist."
    exit 1
fi

# Backup the original file
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "Backup created at $BACKUP_FILE"

# Use awk to modify the MODULES line
awk -v new_mods="$NEW_MODULES" 
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
} "$CONFIG_FILE" > "$CONFIG_FILE.tmp"

# Replace the original file
mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub

sudo sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"loglevel=3 quiet nvidia-drm.modeset=1\"/" /etc/default/grub

sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install RPMs & flatpaks
yay -S $PACMANs
yay -S $Gaming
sudo sed -i s/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g /etc/libvirt/libvirtd.conf
sudo sed -i s/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"
sudo systemctl enable warp-svc.service
sudo systemctl enable tuned.service

# Install fonts
yay -S $Fonts

# My configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config
mv ~/setup/alacritty ~/.config

#bashrc
echo "#bash promit color
PS1=\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W 

#aliases
alias ls=ls -a --color=auto
alias grep=grep --color=auto
alias cat=bat -pp
alias autorm=sudo pacman -Rns $(pacman -Qdtq)
alias in=sudo pacman -S
alias rm=sudo pacman -Rns
alias se=pacman -Ss
alias timeshiftC=sudo timeshift --create
alias timeshiftR=sudo timeshift --restore
alias timeshiftD=sudo timeshift --delete
alias update-grub=sudo grub-mkconfig -o /boot/grub/grub.cfg

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo arch_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
