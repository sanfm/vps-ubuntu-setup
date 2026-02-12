#!/usr/bin/env bash
set -euo pipefail

NEW_USER="fm"

set -x

echo "=== Instalando Docker (método oficial) ==="

# Instalación oficial Docker (2025)
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Añadir usuario al grupo docker
usermod -aG docker "$NEW_USER"

newgrp docker

echo ""
echo "✅ Docker instalado y usuario ${NEW_USER} añadido al grupo docker."
echo ""
echo "Para usar Docker sin sudo:"
echo "   1. Cierra sesión y vuelve a entrar"
echo "   2. Prueba: docker run --rm hello-world"