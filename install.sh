#!/bin/bash

#paru
cd
https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si

#essentials
paru -S firefox thunderbird timeshift fastfetch telegram-desktop komikku cloudflare-warp-bin protonup-qt dxvk-bin minecraft-launcher jre-openjdk grub-btrfs timeshift-autosnap inotify-tools papirus-icon-theme papirus-folders ttf-jetbrains-mono-nerd ttf-ms-win11-auto virtualbox virtualbox-guest-utils virtualbox-guest-iso virtualbox-ext-vnc virtualbox-host-modules-arch

#KDE Plasma
#paru -S --noconfirm sddm-kcm plasma-desktop plasma-nm plasma-pa kscreen qt5ct breeze-gtk kde-gtk-config dolphin alacritty kate transmission-qt stremio

#Cinnamon
#paru -S --noconfirm cinnamon lightdm-slick-greeter lightdm-settings nemo-fileroller transmission-gtk gnome-terminal xed vlc

#GNOME
#paru -S --noconfirm gnome-shell gdm gnome-control-center nautilus gnome-tweaks gnome-text-editor gnome-terminal vlc

#sddm
#sudo systemctl enable sddm
#lightdm
#sudo systemctl enable lightdm
#gdm
#sudo systemctl enable gdm

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
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias search='pacman -Ss'
alias timeshiftC='sudo timeshift --create'
alias timeshiftR='sudo timeshift --restore'
alias timeshiftD='sudo timeshift --delete'

#fastfetch logo
fastfetch --logo-padding-top 1 --logo-padding-left 1 --logo-padding-right 1 --color green --logo arch_small
" >> ~/.bashrc
