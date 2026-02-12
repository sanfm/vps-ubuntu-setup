#!/usr/bin/env bash
set -euo pipefail

NEW_USER="fm"
NEW_USER_PASSWORD="changeme"            # cámbialo
set -x

apt-get update -y && apt-get upgrade -y

echo "=== Creando usuario administrador ${NEW_USER} ==="

# Crear usuario
if ! id "$NEW_USER" &>/dev/null; then
    useradd --create-home --shell /bin/bash --groups sudo "$NEW_USER"
    echo "$NEW_USER:$NEW_USER_PASSWORD" | chpasswd
    echo "→ Usuario ${NEW_USER} creado con contraseña temporal."
else
    echo "→ El usuario ${NEW_USER} ya existe."
fi

echo ""
echo "✅ Usuario listo."
echo "Ahora conéctate con:  ssh ${NEW_USER}@TU_IP"
echo "   (usa la contraseña temporal que pusiste arriba)"