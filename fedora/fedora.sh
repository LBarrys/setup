#!/bin/bash

# Configure DNF
printf "%s" "
fastestmirror=True
max_parallel_downloads=5
defaultyes=True
" | sudo tee -a /etc/dnf/dnf.conf

# Install/Enable Repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install flatpak -y
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release -y
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo
sudo dnf update

# RPMs & Flatpaks & Systemd Services
RPMs="kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils lightdm-gtk-greeter lightdm-gtk-greeter-settings hyprland waybar nautilus gnome-text-editor mate-polkit pavucontrol gammastep gnome-shell gnome-tweaks curl cabextract xorg-x11-font-utils fontconfig google-roboto-fonts google-noto-fonts-all google-noto-sans-cjk-fonts jetbrains-mono-fonts firefox thunderbird qbittorrent vlc vlc-plugins-all wine winetricks steam mangohud gnome-disk-utility timeshift inotify-tools cloudflare-warp java-21-openjdk fastfetch papirus-icon-theme bat wget p7zip p7zip-plugins unrar tldr make @virtualization"
Flatpaks="com.github.tchx84.Flatseal info.febvre.Komikku com.stremio.Stremio io.github.radiolamp.mangojuice io.github.Foldex.AdwSteamGtk com.vysp3r.ProtonPlus"
sudo dnf install $RPMs
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf install @multimedia
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
# sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
flatpak install flathub $Flatpaks
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable warp-svc.service
sudo systemctl set-default graphical.target
sudo usermod -aG libvirt "$(whoami)"

# NVIDIA
GRUB_FILE="/etc/default/grub"
GRUB_PARAM="nvidia-drm.modeset=1"
  # Configure GRUB for NVIDIA Drivers
sudo cp "$GRUB_FILE" "${GRUB_FILE}.bak"
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ $GRUB_PARAM\"/" "$GRUB_FILE"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Build grub-btrfs
cd
git clone https://github.com/Antynea/grub-btrfs.git
cd grub-btrfs
sed -i '/#GRUB_BTRFS_SNAPSHOT_KERNEL/a GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="systemd.volatile=state"' config
sed -i '/#GRUB_BTRFS_GRUB_DIRNAME/a GRUB_BTRFS_GRUB_DIRNAME="/boot/grub2"' config
sed -i '/#GRUB_BTRFS_MKCONFIG=/a GRUB_BTRFS_MKCONFIG=/sbin/grub2-mkconfig' config
sed -i '/#GRUB_BTRFS_SCRIPT_CHECK=/a GRUB_BTRFS_SCRIPT_CHECK=grub2-script-check' config
sudo make install
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

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
# ./install.sh --theme green --color dark --size standard --icon fedora --libadwaita --tweaks solid compact dock
# ./install.sh --theme green --color dark --size standard --icon fedora --libadwaita --tweaks solid compact --round 0px
sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0
sudo cp -r ~/.themes/* /usr/share/themes

# My Configs
cp -r ~/setup/dotfiles/* ~/.config

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
alias flatin='flatpak install flathub'
alias flatrm='flatpak remove'
alias flatse='flatpak search'
alias timeshiftC='sudo timeshift --create && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftR='sudo timeshift --restore && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftD='sudo timeshift --delete && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes. DO NOT FORGOT GRUB-BTRFS. \033[0m"
