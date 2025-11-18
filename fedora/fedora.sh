#!/bin/bash

# Fedora Version = 43

# Configure DNF
printf "%s" "
fastestmirror=True
max_parallel_downloads=5
defaultyes=True
best=True
clean_requirements_on_remove=True
installonly_limit=2
" | sudo tee -a /etc/dnf/dnf.conf

# Install Repositories
    # RPM Fusion
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    # COPR
sudo dnf copr enable g3tchoo/prismlauncher -y
sudo dnf copr enable wehagy/protonplus -y
sudo dnf copr enable tymmesyde/Losange -y
sudo dnf copr enable kylegospo/grub-btrfs -y

sudo dnf copr enable lbarrys/papirus-folders -y
sudo dnf copr enable lbarrys/bottles-latest -y
sudo dnf copr enable lbarrys/adwsteamgtk -y
sudo dnf copr enable lbarrys/komikku -y
sudo dnf copr enable lbarrys/mangojuice -y
sudo dnf copr enable lbarrys/nwg-look -y
sudo dnf copr enable lbarrys/hyprland-scratchpad -y
sudo dnf copr enable lbarrys/hyprland -y
    # Cloudflare Warp
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo

# Hyprland
HYPR="sddm-wayland-generic hyprland hyprpaper hyprland-scratchpad  waybar nwg-look rofi-wayland xfce-polkit thunar thunar-archive-plugin thunar-volman file-roller pavucontrol gammastep copyq"
sudo dnf install $HYPR

# nVidia
NVIDIA="kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia libva-nvidia-driver libva-utils"
sudo dnf install $NVIDIA
sudo cp "/etc/default/grub" "/etc/default/grub.bak"
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ nvidia-drm.modeset=1\"/" "/etc/default/grub"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# RPMs
RPMs="alacritty firefox thunderbird qbittorrent vlc vlc-plugins-all distrobox podman gnome-boxes komikku losange wine winetricks protonplus mangohud mangojuice steam adwsteamgtk bottles prismlauncher gnome-disk-utility timeshift grub-btrfs-timeshift inotify-tools cloudflare-warp fastfetch papirus-icon-theme papirus-folders breeze-cursor-theme bat wget p7zip p7zip-plugins unrar tldr btop micro"
sudo dnf install $RPMs
sudo dnf install @multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing

# Virtualization
# sudo dnf install @virtualization
# sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
# sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
# sudo systemctl enable libvirtd
# sudo usermod -aG libvirt "$(whoami)"

# Fonts
FONTS="google-rubik-fonts jetbrains-mono-fonts"
sudo dnf install $FONTS

# Auto Mount Disk
systemd-escape -p --suffix=mount "/home/$USER/Plus"
printf "%s" "
[Unit]
Description=Mount storage volume

[Mount]
What=/dev/disk/by-uuid/385eedac-e64f-4b95-8608-534734216022
Where=~/Plus
Type=btrfs
Options=nosuid,nodev,nofail,x-gvfs-show

[Install]
WantedBy=multi-user.target
" | sudo tee -a /etc/systemd/system/home-$USER-Plus.mount
sudo systemctl daemon-reload

# Systemd Services
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable warp-svc.service
sudo systemctl set-default graphical.target
sudo systemctl enable grub-btrfs.path
sudo systemctl enable home-$USER-Plus.mount
sudo systemctl start home-$USER-Plus.mount

# Remove Firewalld's Default Rules
sudo firewall-cmd --permanent --remove-port=1025-65535/udp
sudo firewall-cmd --permanent --remove-port=1025-65535/tcp
sudo firewall-cmd --permanent --remove-service=mdns
sudo firewall-cmd --permanent --remove-service=ssh
sudo firewall-cmd --permanent --remove-service=samba-client
sudo firewall-cmd --reload

# Gruvbox Theme
cd
git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git --depth=1
cd Gruvbox-GTK-Theme
cd themes
./install.sh --theme all --color dark --size standard --libadwaita --tweaks medium
sudo cp -r ~/.themes/* /usr/share/themes

# Qt theme
sudo mkdir -p /etc/environment.d/
sudo touch /etc/environment.d/qt6.conf
echo "QT_QPA_PLATFORMTHEME=gtk3" | sudo tee -a /etc/environment.d/qt6.conf

# Dotfiles
cp -r ~/setup/dotfiles/* ~/.config
cp ~/setup/home-dotfiles/.* /home/$USER

# Cleanup
TRASH="nano* vim* gnome-tour gnome-color-manager malcontent-control gnome-extensions-app gnome-remote-desktop gnome-bluetooth dosbox-staging speech-dispatcher speech-dispatcher-utils sane-backends-drivers-cameras sane-backends-drivers-scanners virt-viewer nwg-panel wofi kitty brightnessctl swww hdrop grimblast golang gtk3-devel libappindicator-gtk3-devel fontawesome*"
sudo dnf remove $TRASH
sudo dnf autoremove

echo -e "\033[1;32mScript completed. Please reboot to apply changes. \033[0m"