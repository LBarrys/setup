#!/bin/bash

# Define the GRUB config file
GRUB_FILE="/etc/default/grub"
GRUB_PARAM="nvidia-drm.modeset=1"
OUTPUT_FILE="/boot/grub2/grub.cfg"

# DNF configuration
echo "
fastestmirror=True
max_parallel_downloads=5
defaultyes=True
countme=false
" >> /etc/dnf/dnf.conf

# Install RPMfusion & terra repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
sudo dnf update

# CachyOS kernel
sudo setsebool -P domain_kernel_load_modules on
sudo dnf copr enable bieszczaders/kernel-cachyos
sudo dnf install kernel-cachyos kernel-cachyos-devel-matched

# Install nvidia proprietary drivers
sudo dnf install kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils

# Backup the GRUB config file
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"

# Append the parameter to GRUB_CMDLINE_LINUX
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ $GRUB_PARAM\"/" "$GRUB_FILE"

# Update GRUB configuration
sudo grub2-mkconfig -o "$OUTPUT_FILE"

# Install RPMs
sudo dnf install timeshift flatpak firefox thunderbird gnome-disk-utility fastfetch vlc telegram-desktop komikku steam bottles wine winetricks protontricks mangohud papirus-icon-theme bat wget p7zip p7zip-plugins unrar @virtualization
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"

# Install Flatpaks
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.tchx84.Flatseal com.vysp3r.ProtonPlus io.github.Foldex.AdwSteamGtk io.github.radiolamp.mangojuice com.mattjakeman.ExtensionManager io.github.realmazharhussain.GdmSettings

# GNOME
# sudo dnf install gdm gnome-shell gnome-terminal gnome-tweaks nautilus gnome-terminal-nautilus gnome-text-editor gnome-weather gnome-shell-extension-appindicator gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-just-perfection gnome-shell-extension-user-theme transmission-gtk

# Plasma
# sudo dnf install sddm-kcm sddm-breeze plasma-desktop plasma-nm plasma-pa kscreen breeze-gtk kde-gtk-config xed nemo-fileroller alacritty transmission-qt breeze-cursor-theme

# Multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Install & set-up grub-btrfs
sudo dnf copr enable kylegospo/grub-btrfs
sudo dnf install grub-btrfs-timeshift
sudo systemctl enable --now grub-btrfs.path

# Install & set-up Cloudflare-Warp
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
sudo dnf update
sudo dnf install cloudflare-warp
sudo systemctl enable warp-svc.service
sudo systemctl start warp-svc.service
warp-cli registration new

# Install fonts
sudo dnf install google-roboto-fonts google-noto-fonts-all google-noto-fonts-all-static google-noto-fonts-all-vf google-noto-sans-cjk-fonts google-noto-sans-cjk-vf-fonts ms-core-fonts jetbrainsmono-nerd-fonts

# Remove unnecessary packages
sudo dnf remove zram* vim* gnome-tour gnome-color-manager malcontent-control virt-viewer
sudo dnf autoremove

# Systemd
sudo systemctl set-default graphical.target
sudo systemctl disable NetworkManager-wait-online.service

# My .bashrc
echo "
#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias autoremove='sudo dnf autoremove'
alias in='sudo dnf install'
alias rm='sudo dnf remove'
alias se='dnf search'
alias up='sudo dnf update --refresh; flatpak update'
alias timeshiftC='sudo timeshift --create && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftR='sudo timeshift --restore && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftD='sudo timeshift --delete'
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small
" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
