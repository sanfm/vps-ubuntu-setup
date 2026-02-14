#!/usr/bin/env bash
set -euo pipefail

# NEW_SSH_PORT=9922
NEW_USER="fm"          # mismo que en el script 01

# set -x

# Añadir clave pública (interactivo)
echo ""
echo "Pega tu clave SSH pública (ssh-ed25519 ... o ssh-rsa ...) y pulsa Enter:"
read -r PUBKEY

if [[ -n "$PUBKEY" ]]; then
    mkdir -p "/home/${NEW_USER}/.ssh"
    echo "$PUBKEY" > "/home/${NEW_USER}/.ssh/authorized_keys"
    chown -R "${NEW_USER}:${NEW_USER}" "/home/${NEW_USER}/.ssh"
    chmod 700 "/home/${NEW_USER}/.ssh"
    chmod 600 "/home/${NEW_USER}/.ssh/authorized_keys"
    echo "→ Clave pública añadida correctamente."
else
    echo "⚠️  No se añadió ninguna clave. Podrás hacerlo manualmente después."
fi

# echo "=== Cambiando puerto SSH a ${NEW_SSH_PORT} + hardening ==="
echo "=== hardening SSH"

# Backup
cp /etc/ssh/sshd_config "/etc/ssh/sshd_config.bak-$(date +%F-%H%M)"

# Puerto en el archivo principal (necesario en algunas versiones Ubuntu)
# sed -i "s/^#*Port .*/Port ${NEW_SSH_PORT}/" /etc/ssh/sshd_config

# Copiar configuración hardening (drop-in)
mkdir -p /etc/ssh/sshd_config.d
cp configs/ssh/10-hardening.conf /etc/ssh/sshd_config.d/
chmod 644 /etc/ssh/sshd_config.d/10-hardening.conf

# Firewall (ufw)
apt-get install -y ufw
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment "SSH"
# ufw allow "${NEW_SSH_PORT}"/tcp comment "SSH new"
ufw --force enable

# Validate configuration syntax
sudo sshd -t
# Reiniciar SSH
systemctl restart ssh

echo ""
# echo "✅ SSH configurado en puerto ${NEW_SSH_PORT} + hardening aplicado."
echo "✅ SSH configuro, hardening aplicado."
echo "¡IMPORTANTE!"
echo "Abre una NUEVA terminal y conéctate YA con:"
# echo "   ssh -p ${NEW_SSH_PORT} ${NEW_USER}@TU_IP"
echo "   ssh ${NEW_USER}@TU_IP"
echo ""
echo "Si todo funciona → cierra esta sesión antigua."
echo "Eliminar antiguo usuario"
echo "sudo deluser --remove-home ubuntu"
# echo "Si no funciona → todavía tienes el puerto 22 abierto."