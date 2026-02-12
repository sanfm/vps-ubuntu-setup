# Server Setup (privado)

Scripts para configurar un VPS Ubuntu desde cero.


Ejecutar como root

**Orden de ejecución (como root):**

1. `./01-create-sudo-user.sh` → crea usuario + añade tu clave pública
2. `./02-harden-ssh-and-firewall.sh` → cambia puerto SSH + hardening + firewall
3. `./03-install-docker.sh` → instala Docker + añade usuario al grupo

**Importante**: Ejecuta los scripts en orden y **NO cierres la sesión** hasta haber probado el nuevo puerto SSH.