#!/bin/bash

#yay
cd
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
makepkg -si

# GNOME
GNOME="gdm gnome-shell gnome-tweaks gnome-control-center nautilus gnome-text-editor gdm-settings extension-manager gnome-weather"
# yay -S $GNOME
# sudo systemctl enable gdm

# Sway
SWAY="lightdm-gtk-greeter lightdm-gtk-greeter-settings sway swaybg sway-nvivida autotiling waybar wofi nemo-fileroller xed polkit-gnome xdg-user-dirs xdg-user-dirs-gtk"
# yay -S $SWAY
# sudo systemctl enable lightdm

# Hypr
Hyprland="lightdm-gtk-greeter lightdm-gtk-greeter-settings hyprland hyprland-protocols hyprgraphics hyprshot hyprpolkitagent nwg-display nwg-look waybar nemo-fileroller xed xdg-user-dirs xdg-user-dirs-gtk"
# yay -S $Hyprland
# sudo systemctl enable lightdm

# Install nvidia proprietary drivers
Nvidia="nvidia-dkms nvidia-utils lib32-nvidia-utils opencl-nvidia lib32-opencl-nvidia linux-headers"
yay -S $Nvidia
# Check if line exists
CONF="/etc/mkinitcpio.conf"
MODULES="nvidia nvidia_modeset nvidia_uvm nvidia_drm"
if grep -q '^MODULES=' "$CONF"; then
    # Only add modules that are not already there
    for mod in $MODULES; do
        if ! grep -q "MODULES=.*\b$mod\b" "$CONF"; then
            sed -i "s/^MODULES=(/MODULES=($mod /" "$CONF"
        fi
    done
else
    # If MODULES line is missing entirely, append it
    echo "MODULES=($MODULES)" >> "$CONF"
fi
sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\"/" /etc/default/grub
sudo sed -i "s/GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"loglevel=3 quiet nvidia-drm.modeset=1\"/" /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Install RPMs & flatpaks
PACMANs="alacritty timeshift grub-btrfs timeshift-autosnap inotify-tools cloudflare-warp-bin firefox betterbird-bin telegram-desktop qbittorrent gnome-disk-utility fastfetch vlc vlc-plugins-all btop komikku papirus-icon-theme papirus-folders extra/breeze bat wget 7zip unrar jre-openjdk qemu-full qemu-img libvirt virt-install virt-manager edk2-ovmf dnsmasq swtpm guestfs-tools libosinfo tuned"
yay -S $PACMANs
Gaming="alsa-lib alsa-plugins fontconfig gamemode gamescope giflib glfw gnutls gst-plugin-pipewire gst-plugin-va gst-plugins-bad gst-plugins-bad-libs gst-plugins-base gst-plugins-base-libs gst-plugins-good gst-plugins-ugly gtk2 gtk2+extra gtk3 libgcrypt libgpg-error libjpeg-turbo libldap libpng libpulse libva libva-mesa-driver libxcomposite libxinerama libxslt mangohud mangojuice mpg123 ncurses ocl-icd openal opencl-icd-loader sqlite adwsteamgtk steam proton-ge-custom-bin steamtinkerlaunch v4l-utils vkd3d vulkan-icd-loader prismlauncher dxvk-bin bottles wine-gecko wine-mono wine winetricks lib32-alsa-lib lib32-alsa-plugins lib32-fontconfig lib32-giflib lib32-gnutls lib32-gst-plugins-base-libs lib32-gst-plugins-good lib32-gtk3 lib32-libgcrypt lib32-libgpg-error lib32-libjpeg-turbo lib32-libldap lib32-libpng lib32-libpulse lib32-libva lib32-libva-mesa-driver lib32-libxcomposite lib32 libxinerama lib32-libxslt lib32-mangohud lib32-mpg123 lib32-ncurses lib32-ocl-icd lib32-openal lib32-sqlite lib32-v4l-utils lib32-vkd3d lib32-vulkan-icd-loader"
yay -S $Gaming
sudo sed -i s/#unix_sock_group = "libvirt"/unix_sock_group = "libvirt"/g /etc/libvirt/libvirtd.conf
sudo sed -i s/#unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0770"/g /etc/libvirt/libvirtd.conf
sudo systemctl enable libvirtd
sudo usermod -aG libvirt "$(whoami)"
sudo systemctl enable warp-svc.service
sudo systemctl enable tuned.service

# Install fonts
Fonts="ttf-jetbrains-mono-nerd noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra ttf-roboto ttf-ms-fonts"
yay -S $Fonts

# Orchis theme
cd
git clone https://github.com/vinceliuice/Orchis-theme.git
cd Orchis-theme
# ./install.sh --theme green --color dark --size standard --icon arch --libadwaita --tweaks solid compact dock
# ./install.sh --theme green --color dark --size standard --icon fedora --libadwaita --tweaks solid compact --round 0px
sudo cp -r ~/.themes/* /usr/share/themes

# My configs
mv ~/setup/dotfiles/* ~/.config

#bashrc
echo "#bash promit color
PS1='\[\033[1;32m\]\u\[\033[0;37m\]@\[\033[1;32m\]\h\[\033[0;37m\]:\W '

#aliases
alias ls='ls -a --color=auto'
alias grep='grep --color=auto'
alias cat='bat -pp'
alias autorm='sudo pacman -Rns $(pacman -Qdtq)'
alias in='sudo pacman -S'
alias rm='sudo pacman -Rns'
alias se='pacman -Ss'
alias timeshiftC='sudo timeshift --create'
alias timeshiftR='sudo timeshift --restore'
alias timeshiftD='sudo timeshift --delete'
alias update-grub='sudo grub-mkconfig -o /boot/grub/grub.cfg'

#fastfetch logo
fastfetch --logo-padding-left 1 --logo-padding-right 1 --color green --logo arch_small" >> ~/.bashrc

echo -e "\033[1;32mScript completed. Please reboot to apply changes.\033[0m"
