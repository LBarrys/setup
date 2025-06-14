#!/bin/bash

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo."
    exit 1
fi

# Define the GRUB config file
GRUB_FILE="/etc/default/grub"
GRUB_PARAM="nvidia-drm.modeset=1"
OUTPUT_FILE="/boot/grub2/grub.cfg"

# DNF configuration
echo "max_parallel_downloads=5
defaultyes=True" >> /etc/dnf/dnf.conf

# Install free and nonfree repositories
dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# CachyOS kernel
sudo setsebool -P domain_kernel_load_modules on
sudo dnf copr enable bieszczaders/kernel-cachyos
sudo dnf install kernel-cachyos kernel-cachyos-devel-matched

# Multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Install nvidia proprietary drivers
sudo dnf install kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils

# Backup the GRUB config file
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"
echo "Backed up $GRUB_FILE to ${GRUB_FILE}.bak"

# Check if the parameter is already present
if grep -q "$GRUB_PARAM" "$GRUB_FILE"; then
    echo "$GRUB_PARAM is already present in $GRUB_FILE. No changes needed."
    exit 0
fi

# Append the parameter to GRUB_CMDLINE_LINUX
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ $GRUB_PARAM\"/" "$GRUB_FILE"
if [[ $? -eq 0 ]]; then
    echo "Successfully added $GRUB_PARAM to $GRUB_FILE"
else
    echo "Failed to modify $GRUB_FILE. Check permissions or file content."
    exit 1
fi

# Update GRUB configuration
sudo grub2-mkconfig -o "$OUTPUT_FILE"
if [[ $? -eq 0 ]]; then
    echo "GRUB configuration updated successfully at $OUTPUT_FILE"
else
    echo "Failed to update GRUB configuration. Check permissions or grub2-mkconfig."
    exit 1
fi

# Installing packages
dnf install gdm gnome-shell gnome-terminal gnome-tweaks gnome-terminal nautilus gnome-terminal-nautilus gnome-disk-utility gnome-text-editor gnome-weather timeshift flatpak fedora-flathub-remote firefox thunderbird fastfetch telegram-desktop transmission-gtk steam lutris wine winetricks protontricks mangohud papirus-icon-theme breeze-cursor-theme @virtualization
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"

# Flathub
flatpak install flathub com.github.tchx84.Flatseal com.usebottles.bottles com.vysp3r.ProtonPlus io.github.Foldex.AdwSteamGtk io.github.radiolamp.mangojuice org.prismlauncher.PrismLauncher com.mattjakeman.ExtensionManager io.github.realmazharhussain.GdmSettings com.stremio.Stremio info.febvre.Komikku

# Fonts
sudo dnf copr enable aquacash5/nerd-fonts
sudo dnf install google-roboto-fonts google-noto-fonts-all google-noto-fonts-all-static google-noto-fonts-all-vf google-noto-sans-cjk-fonts google-noto-sans-cjk-vf-fonts jet-brains-mono-nerd-fonts

# My configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config

# My .bashrc
echo "#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias autoremove='sudo dnf autoremove'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias search='dnf search'
alias update='sudo dnf update'
alias timeshiftC='sudo timeshift --create'
alias timeshiftR='sudo timeshift --restore'
alias timeshiftD='sudo timeshift --delete'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small" >> ~/.bashrc


echo "Script completed. Please reboot to apply changes."
