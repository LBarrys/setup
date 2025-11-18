#!/bin/bash

sudo dnf install kmodtool akmods mokutil openssl -y
sudo kmodgenca -f -a
sudo mokutil --import /etc/pki/akmods/certs/public_key.der
