#!/bin/bash

echo "baseurl=https://mirror.maeen.sa/fedora/releases/42/Everything/x86_64/os/" | sudo tee -a /etc/yum.repos.d/fedora.repo
echo "baseurl=https://mirror.maeen.sa/fedora/updates/42/Everything/x86_64/" | sudo tee -a /etc/yum.repos.d/fedora-updates.repo
