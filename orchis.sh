#!/bin/bash

cd
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
./install.sh --theme green --color dark --size standard --icon simple --libadwaita --tweaks solid compact dock
sudo cp -r ~/.themes/* /usr/share/themes

sudo flatpak override --filesystem=xdg-config/gtk-3.0 && sudo flatpak override --filesystem=xdg-config/gtk-4.0

# My configs
mv ~/setup/wallpapers ~/.config
mv ~/setup/fastfetch ~/.config
