#!/usr/bin/env bash
set -euo pipefail

# ────────────────────────────────────────────────────────────────
#  Script interactivo: crear usuario sudo + cambiar hostname
# ────────────────────────────────────────────────────────────────

echo ""
echo "============================================================="
echo "  Configuración inicial de servidor - Paso 1"
echo "============================================================="
echo ""

# ─── 1. Preguntar nombre de usuario ──────────────────────────────────────
while true; do
    read -r -p "Nombre de usuario a crear (recomendado: 2-12 letras, sin espacios): " NEW_USER
    NEW_USER=$(echo "$NEW_USER" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

    if [[ -z "$NEW_USER" ]]; then
        echo "→ Error: no puede estar vacío."
        continue
    fi

    if [[ ${#NEW_USER} -lt 2 || ${#NEW_USER} -gt 16 ]]; then
        echo "→ El nombre debe tener entre 3 y 16 caracteres."
        continue
    fi

    if [[ ! "$NEW_USER" =~ ^[a-z][a-z0-9_-]*$ ]]; then
        echo "→ Solo letras minúsculas, números, guion y guión bajo. Debe empezar por letra."
        continue
    fi

    if id "$NEW_USER" &>/dev/null; then
        echo "→ El usuario '$NEW_USER' ya existe."
        read -r -p "¿Quieres continuar con otro usuario? (s/N): " continuar
        [[ "$continuar" =~ ^[sS]$ ]] || exit 0
        continue
    fi

    break
done

# ─── 2. Preguntar contraseña ─────────────────────────────────────────────
while true; do
    read -s -r -p "Contraseña para el usuario $NEW_USER: " NEW_PASSWORD
    echo ""
    read -s -r -p "Repite la contraseña: " NEW_PASSWORD2
    echo ""

    if [[ -z "$NEW_PASSWORD" ]]; then
        echo "→ La contraseña no puede estar vacía."
        continue
    fi

    if [[ "$NEW_PASSWORD" != "$NEW_PASSWORD2" ]]; then
        echo "→ Las contraseñas no coinciden."
        continue
    fi

    if [[ ${#NEW_PASSWORD} -lt 8 ]]; then
        echo "→ Recomendación: usa al menos 8 caracteres."
        continue
    fi

    break
done

# ─── 3. Preguntar nuevo hostname ─────────────────────────────────────────
CURRENT_HOSTNAME=$(hostname)

echo ""
echo "Hostname actual: $CURRENT_HOSTNAME"
echo ""

while true; do
    read -r -p "Nuevo nombre del servidor (hostname): " NEW_HOSTNAME
    NEW_HOSTNAME=$(echo "$NEW_HOSTNAME" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')

    if [[ -z "$NEW_HOSTNAME" ]]; then
        echo "→ No puede estar vacío."
        continue
    fi

    if [[ ${#NEW_HOSTNAME} -lt 2 || ${#NEW_HOSTNAME} -gt 63 ]]; then
        echo "→ Debe tener entre 2 y 63 caracteres."
        continue
    fi

    if [[ ! "$NEW_HOSTNAME" =~ ^[a-z0-9][a-z0-9-]*[a-z0-9]$ ]]; then
        echo "→ Solo letras minúsculas, números y guiones. No puede empezar ni terminar con guión."
        continue
    fi

    break
done

# ─── Actualización del sistema (opcional pero recomendado) ───────────────
echo ""
echo "Actualizando paquetes..."
apt-get update -qq && apt-get upgrade -y -qq

# ─── Crear usuario ───────────────────────────────────────────────────────
echo ""
echo "Creando usuario: $NEW_USER"

useradd \
    --create-home \
    --shell /bin/bash \
    --groups sudo \
    "$NEW_USER"

echo "$NEW_USER:$NEW_PASSWORD" | chpasswd

# Opcional: forzar cambio de contraseña en el primer login
# chage -d 0 "$NEW_USER"

echo "→ Usuario $NEW_USER creado correctamente."

# ─── Cambiar hostname ────────────────────────────────────────────────────
echo ""
echo "Cambiando hostname a: $NEW_HOSTNAME"

hostnamectl set-hostname "$NEW_HOSTNAME"

# Actualizar /etc/hosts
if [[ -f /etc/hosts ]]; then
    echo "→ Actualizando /etc/hosts ..."

    # Hacer backup
    cp -p /etc/hosts "/etc/hosts.bak-$(date +%Y%m%d-%H%M%S)"

    # Reemplazar el hostname antiguo por el nuevo (en las líneas que lo contengan)
    sed -i "s/\b${CURRENT_HOSTNAME}\b/${NEW_HOSTNAME}/g" /etc/hosts

    # Si hay una línea 127.0.1.1 (muy común en Ubuntu), también la actualizamos
    sed -i "/127\.0\.1\.1/s/${CURRENT_HOSTNAME}/${NEW_HOSTNAME}/" /etc/hosts

    echo "→ /etc/hosts actualizado."
else
    echo "→ No se encontró /etc/hosts (inusual)"
fi

# ─── Resumen final ───────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "                Configuración finalizada"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Usuario creado ............: $NEW_USER"
echo "Contraseña ................: (la que acabas de definir)"
echo "Nuevo hostname ............: $NEW_HOSTNAME"
echo "Hostname anterior .........: $CURRENT_HOSTNAME"
echo ""
echo "Próximos pasos recomendados:"
echo " 1. Salir de root y probar login con el nuevo usuario"
echo "    →  ssh $NEW_USER@TU_IP"
echo " 2. Una vez dentro → puedes continuar con el hardening de SSH"
echo ""