#!/usr/bin/env bash

set -u


SRC_DIR="/opt/webapp/html"
LOCAL_BACKUP_DIR="/var/backups/webapp"
TIMESTAMP="$(date '+%Y-%m-%d_%H%M')"
BACKUP_NAME="backup_web_${TIMESTAMP}.tar.gz"
TMP_PATH="/tmp/${BACKUP_NAME}"
RSYNC=$(command -v rsync || true)
SCP=$(command -v scp || true)
REMOTE_DEST="${1:-localhost:/tmp/}"


echo "==> Creando paquete comprimido de ${SRC_DIR} -> ${TMP_PATH}"
if [ ! -d "${SRC_DIR}" ]; then
  echo "Error: directorio de origen ${SRC_DIR} no existe." >&2
  exit 2
fi

tar -czf "${TMP_PATH}" -C "${SRC_DIR}" . || { echo "Error: tar falló"; exit 3; }

echo "==> Sincronizando backup a directorio local ${LOCAL_BACKUP_DIR}"
mkdir -p "${LOCAL_BACKUP_DIR}"
if [ -n "${RSYNC}" ]; then
  rsync -av --progress "${TMP_PATH}" "${LOCAL_BACKUP_DIR}/" || { echo "Error: rsync falló"; exit 4; }
else
  cp -v "${TMP_PATH}" "${LOCAL_BACKUP_DIR}/" || { echo "Error: cp falló"; exit 4; }
fi

echo "==> Intentando transferencia remota con scp a ${REMOTE_DEST} (sintaxis demostrativa)"
if [ -n "${SCP}" ]; then
  ${SCP} "${TMP_PATH}" "${REMOTE_DEST}"
  SCP_EXIT_CODE=$?
  if [ ${SCP_EXIT_CODE} -eq 0 ]; then
    echo "scp finalizó correctamente (exit ${SCP_EXIT_CODE})."
  else
    echo "scp retornó código ${SCP_EXIT_CODE}. Asegúrese de disponer de llave SSH y host accesible."
  fi
else
  echo "Aviso: scp no disponible; omitiendo transferencia remota."
fi

echo "==> Respaldo completado:"
echo "Archivo local: ${LOCAL_BACKUP_DIR}/${BACKUP_NAME}"
echo "Archivo temporal: ${TMP_PATH}"
exit 0
