#!/bin/bash

#paru
cd
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si

#identifiers
CONFIG_FILE="/etc/mkinitcpio.conf"
MODULES_TO_ADD="nvidia nvidia_modeset nvidia_uvm nvidia_drm"

#essentials
paru -S firefox thunderbird alacritty fastfetch telegram-desktop komikku cloudflare-warp-bin protonplus dxvk-bin minecraft-launcher jre-openjdk grub-btrfs timeshift-autosnap inotify-tools papirus-icon-theme papirus-folders ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-roboto gnome-disk-utility vlc

#KDE Plasma
#paru -S --noconfirm sddm-kcm plasma-desktop plasma-nm plasma-pa kscreen breeze-gtk kde-gtk-config nemo-fileroller xed transmission-qt

#Cinnamon
#paru -S --noconfirm cinnamon lightdm-slick-greeter lightdm-settings nemo-fileroller transmission-gtk xed

#GNOME
#paru -S --noconfirm gnome-shell gdm gnome-control-center nautilus gnome-tweaks gnome-text-editor gdm-settings extension-manager transmission-gtk

#sddm
#sudo systemctl enable sddm
#lightdm
#sudo systemctl enable lightdm
#gdm
#sudo systemctl enable gdm

#configure mkinitcpio.conf for nvidia drivers
cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

if grep -q '^MODULES=' "$CONFIG_FILE"; then
    # Check if any of the NVIDIA modules are already present
    if ! grep -q 'nvidia' "$CONFIG_FILE"; then
        # Add modules to the MODULES line
        sed -i "/^MODULES=/ s/\"\(.*\)\"/\"\1 $MODULES_TO_ADD\"/" "$CONFIG_FILE"
        echo "NVIDIA modules added to $CONFIG_FILE"
    else
        echo "Some NVIDIA modules already exist in $CONFIG_FILE"
    fi
else
    # If MODULES line doesn't exist, add it
    echo "MODULES=($MODULES_TO_ADD)" >> "$CONFIG_FILE"
    echo "MODULES section created with NVIDIA modules in $CONFIG_FILE"
fi

#nvidia
sudo pacman -S --needed nvidia-dkms libglvnd nvidia-utils opencl-nvidia lib32-libglvnd lib32-nvidia-utils lib32-opencl-nvidia linux-headers

#configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config
mv ~/setup/alacritty ~/.config

#bashrc
echo "#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias autoremove='sudo pacman -Rns $(pacman -Qdtq)'
alias in='sudo pacman -S'
alias rm='sudo pacman -Rns'
alias se='pacman -Ss'
alias timeshiftC='sudo timeshift --create'
alias timeshiftR='sudo timeshift --restore'
alias timeshiftD='sudo timeshift --delete'

#fastfetch logo
fastfetch --logo-padding-top 1 --logo-padding-left 1 --logo-padding-right 1 --color green --logo arch_small" >> ~/.bashrc
