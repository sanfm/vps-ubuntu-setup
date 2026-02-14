#!/usr/bin/env bash
set -euo pipefail

# set -x

echo "=== Instalando Podman ==="

apt-get update
apt-get -y install podman podman-compose


echo ""
echo "✅ Podman instalado"
echo "verifica estado"
echo "systemctl --user status podman.socket"
echo "para que arranque al inicio"
echo "systemctl --user enable --now podman.socket"