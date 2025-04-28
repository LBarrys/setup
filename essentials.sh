#!/bin/bash

#essentials packages
paru -S --noconfirm sddm-kcm plasma-desktop plasma-nm plasma-pa kscreen qt5ct breeze-gtk kde-gtk-config dolphin alacritty kate firefox ungoogled-chromium-bin chromium-extension-web-store thunderbird timeshift grub-btrfs timeshift-autosnap transmission-qt fastfetch telegram-desktop komikku papirus-icon-theme papirus-folders ttf-jetbrains-mono-nerd ttf-ms-win11-auto arch-gaming-meta protonup-qt dxvk-bin minecraft-launcher

#enable sddm
sudo systemctl enable sddm

#configs
mv ~/lbarrysos/wallpapers ~/.config
mv ~/lbarrysos/fastfetch ~/.config

#my bashrc
echo "#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias autoremove='pacman -Qdtq && sudo pacman -Rs $(pacman -Qdtq)'
alias install='sudo pacman -S'
alias remove='sudo pacman -Rns'
alias timeshiftC='sudo timeshift --create'
alias timeshiftR='sudo timeshift --restore'
alias timeshiftD='sudo timeshift --delete'

#fastfetch logo
fastfetch --logo-padding-top 1 --logo-padding-left 1 --logo-padding-right 1 --color green --logo arch_small
" >> ~/.bashrc
