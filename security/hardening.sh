#!/usr/bin/env bash

set -euo pipefail


COMPOSE="/opt/webapp/docker-compose.yml"
BACKUP_SCRIPT_PATH="/usr/local/bin/backup.sh"
UFW_CMD="$(command -v ufw || true)"
SSHD_CFG="/etc/ssh/sshd_config"

echo "Aplicando políticas de firewall"
if [ -n "${UFW_CMD}" ]; then
  ufw --force reset || true
  ufw default deny incoming
  ufw default allow outgoing
  ufw allow 22/tcp
  ufw allow 8080/tcp
  ufw --force enable
  echo "Firewall UFW configurado: Denegar incoming por defecto, permitir 22 y 8080."
else
  echo "Aviso: ufw no encontrado. Instale ufw antes de ejecutar este script."
fi

echo "Endureciendo configuración SSH"
if [ -f "${SSHD_CFG}" ]; then
  if grep -qE '^\s*PermitRootLogin' "${SSHD_CFG}"; then
    sed -ri 's/^\s*PermitRootLogin\s+.*/PermitRootLogin no/' "${SSHD_CFG}"
  else
    echo "PermitRootLogin no" >> "${SSHD_CFG}"
  fi
  if command -v systemctl >/dev/null 2>&1; then
    systemctl reload sshd || systemctl restart sshd || true
  else
    service ssh reload || service ssh restart || true
  fi
  echo "SSH configurado: PermitRootLogin no."
else
  echo "Aviso: ${SSHD_CFG} no existe en este sistema."
fi

echo "Aplicando permisos de menor privilegio a archivos críticos"
if [ -f "${COMPOSE}" ]; then
  chown root:root "${COMPOSE}"
  chmod 600 "${COMPOSE}"
  echo "Permisos aplicados a ${COMPOSE} (600)."
else
  echo "Aviso: ${COMPOSE} no encontrado, omitiendo permisos."
fi

if [ -f "${BACKUP_SCRIPT_PATH}" ]; then
  chown root:root "${BACKUP_SCRIPT_PATH}"
  chmod 700 "${BACKUP_SCRIPT_PATH}"
  echo "Permisos aplicados a ${BACKUP_SCRIPT_PATH} (700)."
else
  echo "Aviso: ${BACKUP_SCRIPT_PATH} no encontrado; si crea el script de backup, asigne permisos 700."
fi

echo "Hardening completado"
