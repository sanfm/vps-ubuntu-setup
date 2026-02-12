#!/usr/bin/env bash
set -euo pipefail

set -x

echo "=== Instalando Docker (método oficial) ==="

# desinstalar versiones anteriores
apt remove $(dpkg --get-selections docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc | cut -f1)

# Add Docker's official GPG key:
apt update
apt install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# crear grupo de docker
groupadd docker
# Añadir el usuario al grupo
usermod -aG docker $USER

newgrp docker


# Start en boot
systemctl enable docker.service
systemctl enable containerd.service

apt-get install docker-compose-plugin

echo ""
echo "✅ Docker instalado y usuario ${$USER} añadido al grupo docker."
echo ""
echo "Para usar Docker sin sudo:"
echo "   1. Cierra sesión y vuelve a entrar"
echo "   2. Prueba: docker run --rm hello-world"