#!/bin/bash

# Identifiers
GRUB_FILE="/etc/default/grub"
GRUB_PARAM="nvidia-drm.modeset=1"
OUTPUT_FILE="/boot/grub2/grub.cfg"
Nvidia="kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils"
RPMs="alacritty timeshift grub-btrfs-timeshift cloudflare-warp gnome-disk-utility fastfetch steam mangohud papirus-icon-theme bat wget p7zip p7zip-plugins unrar @virtualization"
Flatpaks="com.vysp3r.ProtonPlus io.github.radiolamp.mangojuice info.febvre.Komikku io.missioncenter.MissionCenter dev.qwery.AddWater org.mozilla.firefox com.usebottles.bottles org.telegram.desktop com.github.tchx84.Flatseal org.qbittorrent.qBittorrent org.prismlauncher.PrismLauncher io.github.flattool.Warehouse com.stremio.Stremio eu.betterbird.Betterbird "
GNOME="gdm gnome-shell gnome-tweaks nautilus com.mattjakeman.ExtensionManager io.github.realmazharhussain.GdmSettings io.github.Foldex.AdwSteamGtk org.gnome.Weather org.gnome.TextEditor gnome-shell-extension-appindicator gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-just-perfection gnome-shell-extension-user-theme breeze-cursor-theme io.github.Foldex.AdwSteamGtk org.gnome.Totem"
Plasma="sddm-kcm sddm-breeze plasma-desktop plasma-nm plasma-pa kscreen breeze-gtk kde-gtk-config xed nemo-fileroller alacritty transmission-qt"
Niri="niri lightdm lightdm-settings lxappearance nemo nemo-fillroller xed transmission-gtk breeze-cursor-theme"
Fonts="google-roboto-fonts google-noto-fonts-all google-noto-fonts-all-static google-noto-fonts-all-vf google-noto-sans-cjk-fonts google-noto-sans-cjk-vf-fonts ms-core-fonts jetbrainsmono-nerd-fonts"
Trash="zram* vim* gnome-tour gnome-color-manager malcontent-control gnome-extensions-app gnome-remote-desktop gnome-bluetooth dosbox-staging speech-dispatcher speech-dispatcher-utils sane-backends-drivers-cameras sane-backends-drivers-scanners plasma-welcome virt-viewer"

# Configure DNF
sudo echo "fastestmirror=True
max_parallel_downloads=5
defaultyes=True
countme=false" >> /etc/dnf/dnf.conf

# Install/Enable repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
sudo dnf copr enable bieszczaders/kernel-cachyos
sudo dnf copr enable bieszczaders/kernel-cachyos-addons
sudo dnf copr enable kylegospo/grub-btrfs
sudo dnf update

# GNOME
# sudo dnf install $GNOME

# Plasma
# sudo dnf install $Plasma

# Niri
# sudo dnf install $Niri

# Install CachyOS stuff
sudo setsebool -P domain_kernel_load_modules on
sudo dnf install kernel-cachyos kernel-cachyos-devel-matched scx-scheds
sudo systemctl enable --now scx.service
sudo dnf install libcap-ng libcap-ng-devel procps-ng procps-ng-devel
sudo dnf install uksmd
sudo ksmctl -e

# Install nvidia proprietary drivers
sudo dnf install $Nvidia

# Configure GRUB for nvidia drivers
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ $GRUB_PARAM\"/" "$GRUB_FILE"
sudo grub2-mkconfig -o "$OUTPUT_FILE"

# Install RPMs & flatpaks
sudo dnf install $RPMs
flatpak install flathub $Flatpaks
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"

# Multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf install --setopt=install_weak_deps=false gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install flexiblas-openblas-serial
sudo dnf install lame\* --exclude=lame-devel

# Install fonts
sudo dnf install $Fonts

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

# Systemd services
sudo systemctl set-default graphical.target
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable --now grub-btrfs.path
sudo systemctl enable warp-svc.service

# My configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config
mv ~/setup/alacritty ~/.config

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
alias up='sudo dnf update --refresh; flatpak update'
alias timeshiftC='sudo timeshift --create && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftR='sudo timeshift --restore && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftD='sudo timeshift --delete'
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
