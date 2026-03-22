#!/usr/bin/env bash
# =============================================================================
# Script:      scripts/bootstrap.sh
# Description: Descarga custom-agent-claude-code desde GitHub y ejecuta
#              install.sh. No requiere clonar el repo previamente.
# Usage:       curl -fsSL <raw-url>/scripts/bootstrap.sh | bash
#              curl -fsSL <raw-url>/scripts/bootstrap.sh | bash -s -- --all --scope profile
#              curl -fsSL <raw-url>/scripts/bootstrap.sh | bash -s -- --skill python-project
# Dependencies: bash >= 4.0, curl, tar
# =============================================================================
set -euo pipefail

REPO_OWNER="${REPO_OWNER:-VanGoMu}"
REPO_NAME="${REPO_NAME:-custom-agent-claude-code}"
REPO_REF="${REPO_REF:-main}"

readonly REPO_OWNER REPO_NAME REPO_REF

ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_REF}.tar.gz"
readonly ARCHIVE_URL

TMP_DIR=""
TMP_DIR="$(mktemp -d)"
readonly TMP_DIR

readonly ARCHIVE_FILE="${TMP_DIR}/archive.tar.gz"
readonly EXTRACTED_DIR="${TMP_DIR}/${REPO_NAME}-${REPO_REF}"

log() { printf '[bootstrap] %s\n' "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

cleanup() { [[ -d "$TMP_DIR" ]] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

command -v curl >/dev/null 2>&1 || die "curl no encontrado. Instálalo e intenta de nuevo."
command -v tar  >/dev/null 2>&1 || die "tar no encontrado. Instálalo e intenta de nuevo."

[[ $# -eq 0 ]] && die "Debes pasar argumentos a install.sh. Ejemplo: bash -s -- --all --scope profile"

log "Descargando ${REPO_OWNER}/${REPO_NAME}@${REPO_REF}..."
curl -fsSL -o "$ARCHIVE_FILE" "$ARCHIVE_URL" \
  || die "Descarga fallida (HTTP error). Verifica REPO_OWNER=${REPO_OWNER} REPO_NAME=${REPO_NAME} REPO_REF=${REPO_REF}"

log "Extrayendo archivo..."
tar -xz -C "$TMP_DIR" -f "$ARCHIVE_FILE" \
  || die "Error al extraer ${ARCHIVE_FILE}"

[[ -d "$EXTRACTED_DIR" ]] || die "Directorio esperado no encontrado: ${EXTRACTED_DIR}"

chmod +x "${EXTRACTED_DIR}/scripts/install.sh"

log "Ejecutando install.sh $*"
"${EXTRACTED_DIR}/scripts/install.sh" "$@"
