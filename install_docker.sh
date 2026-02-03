#!/usr/bin/env bash
set -e
if command -v docker >/dev/null 2>&1
then
    echo "$(docker --version)"
    exit 0
fi

sudo snap install docker


sudo systemctl enable docker
sudo systemctl start docker

sudo usermod -aG docker $USER
