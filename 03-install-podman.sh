#!/usr/bin/env bash
set -euo pipefail

set -x

echo "=== Instalando Podman ==="

apt-get update
apt-get -y install podman podman-compose

echo ""
echo "✅ Podman instalado"