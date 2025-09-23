#!/bin/bash

# Configure DNF
printf "%s" "
fastestmirror=True
max_parallel_downloads=5
defaultyes=True
best=True
clean_requirements_on_remove=True
color=always
" | sudo tee -a /etc/dnf/dnf.conf

# Install Repositories
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install flatpak
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
# sudo dnf install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release -y
curl -fsSl https://pkg.cloudflareclient.com/cloudflare-warp-ascii.repo | sudo tee /etc/yum.repos.d/cloudflare-warp.repo

# Hyprland
Hypr="sddm-wayland-generic hyprland xdg-desktop-portal-hyprland swaybg waybar rofi-wayland nemo-fileroller mate-polkit pavucontrol gammastep"
# sudo dnf install $Hypr

# Plasma
Plasma="sddm sddm-kcm sddm-breeze plasma-desktop kscreen plasma-nm plasma-pa kde-gtk-config breeze-gtk xed nemo-fileroller"
# sudo dnf install $Plasma

# RPMs & Flatpaks & Systemd Services
RPMs="kmod-nvidia xorg-x11-drv-nvidia-cuda akmod-nvidia nvidia-vaapi-driver libva-utils alacritty curl cabextract xorg-x11-font-utils fontconfig google-roboto-fonts google-noto-fonts-all google-noto-sans-cjk-fonts google-noto-emoji-fonts google-noto-color-emoji-fonts jetbrains-mono-fonts firefox thunderbird qbittorrent vlc vlc-plugins-all wine winetricks steam gnome-disk-utility timeshift inotify-tools cloudflare-warp java-25-openjdk fastfetch papirus-icon-theme breeze-cursor-theme bat wget p7zip p7zip-plugins unrar tldr make btop vim awesome-vim-colorschemes golang gtk3-devel libappindicator-gtk3-devel @virtualization"
Flatpaks="com.github.tchx84.Flatseal info.febvre.Komikku com.stremio.Stremio io.github.radiolamp.mangojuice io.github.Foldex.AdwSteamGtk com.vysp3r.ProtonPlus"
flatpak install flathub $Flatpaks
sudo dnf install $RPMs
sudo dnf install @multimedia
sudo dnf swap ffmpeg-free ffmpeg --allowerasing
sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld --allowerasing
# sudo rpm -i https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
sudo sed -i 's/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g' /etc/libvirt/libvirtd.conf
sudo sed -i 's/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g' /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl enable warp-svc.service
sudo systemctl set-default graphical.target
sudo usermod -aG libvirt "$(whoami)"

# Configure GRUB for NVIDIA Drivers
sudo cp "/etc/default/grub" "/etc/default/grub.bak"
sudo sed -i "/^GRUB_CMDLINE_LINUX=/ s/\"$/ nvidia-drm.modeset=1\"/" "/etc/default/grub"
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Build & Install nwg-look
cd
git clone https://github.com/nwg-piotr/nwg-look.git
cd nwg-look
make build
sudo make install

# Install grub-btrfs
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

# Orchis Theme
cd
git clone https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git 
cd Gruvbox-GTK-Theme
cd themes
./install.sh --theme all --color dark --size standard --libadwaita --tweaks medium
sudo cp -r ~/.themes/* /usr/share/themes

# Dotfiles
cp -r ~/setup/dotfiles/* ~/.config

# Cleanup
Trash="zram* nano* gnome-tour gnome-color-manager malcontent-control gnome-extensions-app gnome-remote-desktop gnome-bluetooth dosbox-staging speech-dispatcher speech-dispatcher-utils sane-backends-drivers-cameras sane-backends-drivers-scanners virt-viewer nwg-panel wofi kitty brightnessctl swww hdrop grimblast golang gtk3-devel libappindicator-gtk3-devel"
sudo dnf remove $Trash
sudo dnf autoremove

# My .bashrc
echo "
##########
# Promit #
##########

# PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '
# PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\] \W\[\033[0;37m\]: '
PS1='\[\033[1;32m\]\u \[\033[0;37m\]\W \[\033[1;32m\]>\[\033[0;37m\] '



###########
# Aliases #
###########

# General
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias update-grub='sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias wconnect='warp-cli connect'
alias wdisconnect='warp-cli disconnect'

# DNF
alias autoremove='sudo dnf autoremove'
alias search='dnf search'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias update='sudo dnf update --refresh; flatpak update'
alias list-installed='dnf list --installed'

# Flatpak
alias flatin='flatpak install flathub'
alias flatrm='flatpak remove'
alias flatse='flatpak search'

# Timeshift
alias timeshiftC='sudo timeshift --create && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftR='sudo timeshift --restore && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'
alias timeshiftD='sudo timeshift --delete && sudo grub2-mkconfig -o /boot/grub2/grub.cfg'

#############
# Fastfetch #
#############

fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo fedora_small
" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes. DO NOT FORGOT GRUB-BTRFS. \033[0m"
