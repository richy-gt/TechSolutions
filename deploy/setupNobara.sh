#!/usr/bin/env bash


set -euo pipefail


WORKDIR="/opt/webapp"
HTMLDIR="${WORKDIR}/html"
COMPOSE_DEST="${WORKDIR}/docker-compose.yml"
COMPOSE_SRC="https://gist.githubusercontent.com/DarkestAbed/0c1cee748bb9e3b22f89efe1933bf125/raw/5801164c0a6e4df7d8ced00122c76895997127a2/docker-compose.yml"
INDEX_FILE="${HTMLDIR}/index.html"
SYSUSER="sysadmin"

echo "Paso 1 (Nobara)"

if command -v dnf >/dev/null 2>&1; then
  sudo dnf update -y
  sudo dnf install -y git curl ufw docker docker-compose
  sudo systemctl enable --now docker
elif command -v apt-get >/dev/null 2>&1; then
  apt-get update -y
  apt-get install -y git curl ufw docker.io docker-compose-plugin
  systemctl enable --now docker || true
else
  echo "ERROR: Distribución no soportada automáticamente."
  exit 1
fi


echo "Paso 2 (Nobara)"
mkdir -p "${HTMLDIR}"
chown root:root "${WORKDIR}" || true

echo "==> Descargando docker-compose.yml a ${COMPOSE_DEST}"
curl -fsSL "${COMPOSE_SRC}" -o "${COMPOSE_DEST}.tmp" && mv "${COMPOSE_DEST}.tmp" "${COMPOSE_DEST}" || { echo "Error: no se pudo descargar docker-compose.yml"; exit 1; }
chmod 600 "${COMPOSE_DEST}"

echo "Paso 3 (Nobara)"
cat > "${INDEX_FILE}" <<'HTML'
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8">
  <title>Servidor Seguro</title>
</head>
<body>
  <h1>Servidor Seguro Propiedad de Ricardo-Acceso Restringido</h1>
</body>
</html>
HTML
chmod 644 "${INDEX_FILE}"

echo "Paso 4 (Nobara)"
if id -u "${SYSUSER}" >/dev/null 2>&1; then
  echo "Usuario ${SYSUSER} ya existe."
else
  useradd -m -s /bin/bash -G docker "${SYSUSER}"
  echo "Usuario ${SYSUSER} creado."
fi


if getent group docker >/dev/null 2>&1; then
  usermod -aG docker "${SYSUSER}" || true
else
  groupadd docker || true
  usermod -aG docker "${SYSUSER}" || true
fi

echo "==> Configuración finalizada."
echo "Docker-compose ubicado en: ${COMPOSE_DEST}"
echo "Contenido web en: ${HTMLDIR}"

echo "Terminado"
