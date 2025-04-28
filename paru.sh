#!/bin/bash

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

echo "don't forgot to go back to lbarrysos/"
