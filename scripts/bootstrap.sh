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

readonly REPO_OWNER="${REPO_OWNER:-VanGoMu}"
readonly REPO_NAME="${REPO_NAME:-custom-agent-claude-code}"
readonly REPO_REF="${REPO_REF:-main}"
readonly ARCHIVE_URL="https://github.com/${REPO_OWNER}/${REPO_NAME}/archive/refs/heads/${REPO_REF}.tar.gz"
readonly TMP_DIR="$(mktemp -d)"
readonly EXTRACTED_DIR="${TMP_DIR}/${REPO_NAME}-${REPO_REF}"

log() { printf '[bootstrap] %s\n' "$*" >&2; }
die() { log "ERROR: $*"; exit 1; }

cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

command -v curl >/dev/null 2>&1 || die "curl no encontrado. Instálalo e intenta de nuevo."
command -v tar  >/dev/null 2>&1 || die "tar no encontrado. Instálalo e intenta de nuevo."

log "Descargando ${REPO_OWNER}/${REPO_NAME}@${REPO_REF}..."
curl -fsSL "$ARCHIVE_URL" | tar -xz -C "$TMP_DIR"

[[ -d "$EXTRACTED_DIR" ]] || die "Directorio esperado no encontrado: ${EXTRACTED_DIR}"

chmod +x "${EXTRACTED_DIR}/scripts/install.sh"

log "Ejecutando install.sh $*"
"${EXTRACTED_DIR}/scripts/install.sh" "$@"
