#!/bin/bash

# Configure DNF
printf "%s" "
fastestmirror=True
max_parallel_downloads=5
defaultyes=True
" | sudo tee -a /etc/dnf/dnf.conf

# Install/Enable Repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release -y
sudo dnf install flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
sudo dnf copr enable bieszczaders/kernel-cachyos -y
sudo dnf copr enable kylegospo/grub-btrfs -y
sudo dnf update

# GNOME
GNOME="ghostty gdm gnome-shell gnome-tweaks nautilus nautilus-open-any-terminal gnome-text-editor gnome-weather gnome-shell-extension-appindicator gnome-shell-extension-blur-my-shell gnome-shell-extension-dash-to-dock gnome-shell-extension-just-perfection gnome-shell-extension-user-theme breeze-cursor-theme celluloid"
FlatpaksGNOME="com.mattjakeman.ExtensionManager io.github.realmazharhussain.GdmSettings"
# sudo dnf install $GNOME
# flatpak install flathub $FlatpaksGNOME

# Xfcei3
Xfcei3="lightdm-gtk lightmdm-gtk-greeter-settings i3 xfce4-session xfce4-panel xfce4-settings xfconf xfdesktop thunar xrandr xfce4-whiskermenu-plugin xfce4-clipman-plugin xfce4-pulseaudio-plugin xfce4-datetime-plugin alacritty xed ulauncher vlc vlc-plugins-all"
# sudo dnf install $Xfcei3

# CachyOS Kernel
sudo setsebool -P domain_kernel_load_modules on
sudo dnf install kernel-cachyos kernel-cachyos-devel-matched scx-scheds

# NVIDIA
GRUB_FILE="/etc/default/grub"
GRUB_PARAM="nvidia-drm.modeset=1"
OUTPUT_FILE="/boot/grub2/grub.cfg"
Nvidia="kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils"
  # NVIDIA Proprietary Drivers
sudo dnf install $Nvidia
  # Configure GRUB for NVIDIA Drivers
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ $GRUB_PARAM\"/" "$GRUB_FILE"
sudo grub2-mkconfig -o "$OUTPUT_FILE"

# RPMs & Flatpaks & Systemd Services
RPMs="gnome-disk-utility timeshift grub-btrfs-timeshift cloudflare-warp firefox thunderbird fastfetch transmission-gtk steam mangohud java-21-openjdk papirus-icon-theme bat wget p7zip p7zip-plugins unrar gnome-boxes"
Flatpaks="com.github.tchx84.Flatseal com.vysp3r.ProtonPlus io.github.radiolamp.mangojuice info.febvre.Komikku com.usebottles.bottles com.stremio.Stremio"
flatpak install flathub $Flatpaks
sudo dnf install $RPMs
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable --now grub-btrfs.path
sudo systemctl enable warp-svc.service
sudo systemctl set-default graphical.target

# Multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install @multimedia --setopt="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

# Fonts
Fonts="ms-core-fonts google-roboto-fonts google-noto-fonts-all google-noto-sans-cjk-fonts jetbrainsmono-nerd-fonts"
sudo dnf install $Fonts

# Remove Firewalld's Default Rules
sudo firewall-cmd --permanent --remove-port=1025-65535/udp
sudo firewall-cmd --permanent --remove-port=1025-65535/tcp
sudo firewall-cmd --permanent --remove-service=mdns
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --remove-service=samba-client
sudo firewall-cmd --reload

# Remove Unnecessary Packages
Trash="zram* vim* gnome-tour gnome-color-manager malcontent-control gnome-extensions-app gnome-remote-desktop gnome-bluetooth dosbox-staging speech-dispatcher speech-dispatcher-utils sane-backends-drivers-cameras sane-backends-drivers-scanners virt-viewer"
sudo dnf remove $Trash
sudo dnf autoremove

# Orchis Theme
cd
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --theme green --color dark --size standard --icon fedora --libadwaita --tweaks solid compact dock
# ./install.sh --theme green --color dark --size standard --icon fedora --libadwaita --tweaks solid compact dock --round 0px
sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0
sudo cp -r ~/.themes/* /usr/share/themes

# My Configs
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
alias up='sudo dnf update --refresh; flatpak update'
alias flatin='flatpak flathub install'
alias flatrm='flatpak remove'
alias flatse='flatpak search'
alias timeshiftC='sudo timeshift --create && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftR='sudo timeshift --restore && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftD='sudo timeshift --delete && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
