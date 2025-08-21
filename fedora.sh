#!/bin/bash

# Identifiers
GRUB_FILE="/etc/default/grub"
GRUB_PARAM="nvidia-drm.modeset=1"
OUTPUT_FILE="/boot/grub2/grub.cfg"
Nvidia="kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils"
RPMs="ghostty timeshift grub-btrfs-timeshift cloudflare-warp firefox thunderbird fastfetch celluloid losange telegram-desktop transmission-gtk steam wine winetricks mangohud goverlay java-latest-openjdk prismlauncher protonplus papirus-icon-theme bat wget p7zip p7zip-plugins unrar @virtualization"
GNOME="gdm gdm-settings gnome-shell gnome-tweaks nautilus nautilus-open-any-terminal gnome-disk-utility gnome-text-editor extension-manager gnome-weather gnome-shell-extension-appindicator gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-just-perfection gnome-shell-extension-user-theme breeze-cursor-theme"
Fonts="curl cabextract xorg-x11-font-utils fontconfig google-roboto-fonts google-noto-fonts-all google-noto-sans-cjk-fonts jet-brains-mono-nerd-fonts"
Trash="zram* vim* gnome-tour gnome-color-manager malcontent-control gnome-extensions-app gnome-remote-desktop gnome-bluetooth dosbox-staging speech-dispatcher speech-dispatcher-utils sane-backends-drivers-cameras sane-backends-drivers-scanners virt-viewer"

# Configure DNF
printf "%s" "
fastestmirror=True
max_parallel_downloads=5
defaultyes=True
" | sudo tee -a /etc/dnf/dnf.conf

# Install/Enable repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
sudo dnf copr enable bieszczaders/kernel-cachyos -y
sudo dnf copr enable bieszczaders/kernel-cachyos-addons -y
sudo dnf copr enable kylegospo/grub-btrfs -y
sudo dnf copr enable scottames/ghostty -y
sudo dnf copr enable wehagy/protonplus -y
sudo dnf copr enable g3tchoo/prismlauncher -y
sudo dnf copr enable umutd3401/extension-manager -y
sudo dnf copr enable reanimator/gdm-settings -y
sudo dnf copr enable monkeygold/nautilus-open-any-terminal -y
sudo dnf copr enable tymmesyde/Losange -y
sudo dnf copr enable aquacash5/nerd-fonts -y
sudo dnf update

# GNOME
sudo dnf install $GNOME

# CachyOS stuff
sudo setsebool -P domain_kernel_load_modules on
sudo dnf install kernel-cachyos kernel-cachyos-devel-matched scx-scheds
sudo systemctl enable --now scx.service
sudo dnf install libcap-ng libcap-ng-devel procps-ng procps-ng-devel
sudo dnf install uksmd
sudo ksmctl -e

# NVIDIA proprietary drivers
sudo dnf install $Nvidia

# Configure GRUB for nvidia drivers
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ $GRUB_PARAM\"/" "$GRUB_FILE"
sudo grub2-mkconfig -o "$OUTPUT_FILE"

# RPMs & other stuff
sudo dnf install $RPMs
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable --now grub-btrfs.path
sudo systemctl enable warp-svc.service
sudo systemctl set-default graphical.target

# Multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Fonts
sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo dnf install $Fonts
sudo fc-cache -fv

# Remove Firewalld's Default Rules
sudo firewall-cmd --permanent --remove-port=1025-65535/udp
sudo firewall-cmd --permanent --remove-port=1025-65535/tcp
sudo firewall-cmd --permanent --remove-service=mdns
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --remove-service=samba-client
sudo firewall-cmd --reload

# Remove unnecessary packages
sudo dnf remove $Trash
sudo dnf autoremove

# Orchis theme
cd
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --theme green --color dark --size standard --icon fedora --libadwaita --tweaks solid compact dock
sudo cp -r ~/.themes/* /usr/share/themes

# My configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config
mv ~/setup/alacritty ~/.config
mv ~/setup/ghostty ~/.config

# My .bashrc
echo "#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias autorm='sudo dnf autoremove'
alias in='sudo dnf install'
alias rm='sudo dnf remove'
alias se='dnf search'
alias up='sudo dnf update --refresh'
alias timeshiftC='sudo timeshift --create && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftR='sudo timeshift --restore && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftD='sudo timeshift --delete'
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
