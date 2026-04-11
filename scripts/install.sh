#!/usr/bin/env bash
# =============================================================================
# Script:      scripts/install.sh
# Description: Instala skills y agentes de custom-agent-claude-code en el
#              perfil de usuario de Claude Code (~/.claude/) o en el repo
#              actual (.claude/).
# Author:      [author]
# Created:     2026-03-22
# Usage:       ./scripts/install.sh [--skill <nombre> | --agent <nombre> | --all]
#                                   [--scope profile|repo]
#              ./scripts/install.sh --all --scope profile
#              ./scripts/install.sh --skill shell-project --scope repo
# Dependencies: bash >= 4.0
# =============================================================================
set -euo pipefail
IFS=$'\n\t'

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
readonly SKILLS_SRC="${REPO_ROOT}/skills"
readonly AGENTS_SRC="${REPO_ROOT}/agents"
readonly SETTINGS_TEMPLATE="${REPO_ROOT}/settings.json.template"

# ── configuración ─────────────────────────────────────────────────────────────
SCOPE="${SCOPE:-profile}"
TARGET_SKILL=""
TARGET_AGENT=""
INSTALL_ALL=false
INSTALL_SETTINGS=false

# ── funciones de utilidad ─────────────────────────────────────────────────────

# Descripcion: Emite un mensaje de log con nivel y timestamp.
# Args:        $1 - level (string): info|warn|error
#              $2 - message (string)
# Returns:     0 siempre
log() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  printf '[%s] [%-5s] %s\n' "$timestamp" "${level^^}" "$message" >&2
}

# Descripcion: Imprime un mensaje de error y termina con exit 1.
# Args:        $1 - message (string)
# Returns:     Termina con exit 1
die() { log "error" "$1"; exit 1; }

# Descripcion: Muestra la ayuda del script y termina.
# Returns:     Termina con exit 0
usage() {
  cat >&2 <<EOF
Usage: $(basename "$0") [opciones]

Instala skills y agentes de Claude Code en el perfil de usuario o en el repo actual.

Opciones:
  --skill <nombre>   Instala solo el skill especificado (sin extensión .md)
  --agent <nombre>   Instala solo el agente especificado (sin extensión .md)
  --all              Instala todos los skills y agentes
  --install-settings Instala ~/.claude/settings.json desde settings.json.template
  --scope <scope>    Destino: 'profile' (default) o 'repo'
  -h, --help         Muestra esta ayuda

Scopes:
  profile    Instala en ~/.claude/skills/ y ~/.claude/agents/
             (disponible en todos los workspaces)
  repo       Instala en .claude/skills/ y .claude/agents/
             (solo disponible en el workspace actual)

Ejemplos:
  # Instalar todo en el perfil de usuario
  ./scripts/install.sh --all --scope profile

  # Instalar el skill shell-project en el repo actual
  ./scripts/install.sh --skill shell-project --scope repo

  # Instalar el agente shell-developer en el perfil de usuario
  ./scripts/install.sh --agent shell-developer

  # Instalar settings.json de Claude Code (desde template)
  ./scripts/install.sh --install-settings

  # Ver skills y agentes disponibles
  ./scripts/install.sh --list
EOF
  exit 0
}

# Descripcion: Lista los skills y agentes disponibles en el repositorio.
# Returns:     0 siempre
list_available() {
  echo ""
  echo "Skills disponibles (~/.claude/skills/):"
  for d in "${SKILLS_SRC}"/*/; do
    [[ -f "${d}SKILL.md" ]] && printf "  /%s\n" "$(basename "$d")"
  done
  echo ""
  echo "Agentes disponibles (~/.claude/agents/):"
  for f in "${AGENTS_SRC}"/*.md; do
    [[ -f "$f" ]] && printf "  %s\n" "$(basename "$f" .md)"
  done
  echo ""
}

# Descripcion: Resuelve el directorio de destino según el scope.
# Args:        $1 - type (string): 'skills' o 'agents'
#              $2 - scope (string): 'profile' o 'repo'
# Returns:     0 en éxito, die si scope inválido
# Globals:     SCOPE (read)
resolve_dest_dir() {
  local type="$1"
  local scope="$2"
  case "$scope" in
    profile) echo "${HOME}/.claude/${type}" ;;
    repo)    echo "$(pwd)/.claude/${type}" ;;
    *)       die "Scope inválido: '${scope}'. Usa 'profile' o 'repo'." ;;
  esac
}

# Descripcion: Instala un archivo .md en el directorio de destino.
#              Crea el directorio si no existe. Hace backup si el archivo ya existe.
# Args:        $1 - src_file (string): ruta absoluta al archivo fuente
#              $2 - dest_dir (string): directorio de destino
# Returns:     0 en éxito
install_file() {
  local src_file="$1"
  local dest_dir="$2"
  local filename
  filename="$(basename "$src_file")"
  local dest_file="${dest_dir}/${filename}"

  mkdir -p "$dest_dir"

  if [[ -f "$dest_file" ]]; then
    local backup="${dest_file}.bak.$(date '+%Y%m%d%H%M%S')"
    log "warn" "Archivo existente — backup en: ${backup}"
    cp "$dest_file" "$backup"
  fi

  cp "$src_file" "$dest_file"
  log "info" "Instalado: ${dest_file}"
}

# Descripcion: Instala un skill por nombre. Crea <dest>/skills/<nombre>/SKILL.md.
# Args:        $1 - name (string): nombre del skill (sin extensión)
#              $2 - scope (string): 'profile' o 'repo'
# Returns:     0 en éxito
install_skill() {
  local name="$1"
  local scope="$2"
  local src="${SKILLS_SRC}/${name}/SKILL.md"
  [[ -f "$src" ]] || die "Skill no encontrado: '${name}'. Verifica el nombre con --list."
  local dest_dir
  dest_dir="$(resolve_dest_dir "skills" "$scope")/${name}"
  install_file "$src" "$dest_dir"
}

# Descripcion: Instala un agente por nombre.
# Args:        $1 - name (string): nombre del agente (sin .md)
#              $2 - scope (string): 'profile' o 'repo'
# Returns:     0 en éxito
install_agent() {
  local name="$1"
  local scope="$2"
  local src="${AGENTS_SRC}/${name}.md"
  [[ -f "$src" ]] || die "Agente no encontrado: '${name}'. Verifica el nombre con --list."
  local dest_dir
  dest_dir="$(resolve_dest_dir "agents" "$scope")"
  install_file "$src" "$dest_dir"
}

# Descripcion: Instala ~/.claude/settings.json desde el template del repo.
#              Hace backup si el archivo ya existe.
# Returns:     0 en éxito
install_settings() {
  [[ -f "$SETTINGS_TEMPLATE" ]] || die "Template no encontrado: '${SETTINGS_TEMPLATE}'."
  local dest_dir="${HOME}/.claude"
  local dest_file="${dest_dir}/settings.json"

  mkdir -p "$dest_dir"

  if [[ -f "$dest_file" ]]; then
    local backup="${dest_file}.bak.$(date '+%Y%m%d%H%M%S')"
    log "warn" "Archivo existente — backup en: ${backup}"
    cp "$dest_file" "$backup"
  fi

  cp "$SETTINGS_TEMPLATE" "$dest_file"
  log "info" "Instalado: ${dest_file}"
}

# Descripcion: Instala todos los skills y agentes disponibles.
# Args:        $1 - scope (string): 'profile' o 'repo'
# Returns:     0 en éxito
install_all() {
  local scope="$1"
  local skills_dest agents_dest
  skills_dest="$(resolve_dest_dir "skills" "$scope")"
  agents_dest="$(resolve_dest_dir "agents" "$scope")"

  log "info" "Instalando todos los skills en: ${skills_dest}"
  for d in "${SKILLS_SRC}"/*/; do
    [[ -f "${d}SKILL.md" ]] || continue
    local skill_name
    skill_name="$(basename "$d")"
    install_file "${d}SKILL.md" "${skills_dest}/${skill_name}"
  done

  log "info" "Instalando todos los agentes en: ${agents_dest}"
  for f in "${AGENTS_SRC}"/*.md; do
    [[ -f "$f" ]] && install_file "$f" "$agents_dest"
  done

  log "info" "Instalación completa."
  echo ""
  echo "Skills instalados — úsalos en Claude Code con:"
  for d in "${SKILLS_SRC}"/*/; do
    [[ -f "${d}SKILL.md" ]] && printf "  /%s\n" "$(basename "$d")"
  done
}

# Descripcion: Punto de entrada principal. Parsea argumentos y orquesta la instalación.
# Args:        $@ - argumentos del script
# Returns:     0 en éxito
main() {
  [[ $# -eq 0 ]] && usage

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skill)
        [[ -n "${2:-}" ]] || die "--skill requiere un argumento."
        TARGET_SKILL="$2"; shift 2 ;;
      --agent)
        [[ -n "${2:-}" ]] || die "--agent requiere un argumento."
        TARGET_AGENT="$2"; shift 2 ;;
      --all)
        INSTALL_ALL=true; shift ;;
      --install-settings)
        INSTALL_SETTINGS=true; shift ;;
      --scope)
        [[ -n "${2:-}" ]] || die "--scope requiere 'profile' o 'repo'."
        SCOPE="$2"; shift 2 ;;
      --list)
        list_available; exit 0 ;;
      -h|--help)
        usage ;;
      *)
        die "Argumento desconocido: '$1'. Usa --help para ver las opciones." ;;
    esac
  done

  if [[ "$INSTALL_SETTINGS" == "true" ]]; then
    install_settings
  fi

  if [[ "$INSTALL_ALL" == "true" ]]; then
    install_all "$SCOPE"
  elif [[ -n "$TARGET_SKILL" ]]; then
    install_skill "$TARGET_SKILL" "$SCOPE"
    echo "Skill instalado. Úsalo en Claude Code con: /${TARGET_SKILL}"
  elif [[ -n "$TARGET_AGENT" ]]; then
    install_agent "$TARGET_AGENT" "$SCOPE"
    echo "Agente instalado en: $(resolve_dest_dir "agents" "$SCOPE")/${TARGET_AGENT}.md"
  elif [[ "$INSTALL_SETTINGS" == "true" ]]; then
    :
  else
    die "Debes especificar --skill, --agent o --all."
  fi
}

main "$@"
