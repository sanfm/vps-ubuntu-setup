#!/usr/bin/env bash
set -euo pipefail

set -x

echo "=== Instalando Docker (método oficial) ==="

apt-get update
apt-get -y install podman

echo ""
echo "✅ Podman instalado"