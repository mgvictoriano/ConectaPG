#!/usr/bin/env bash
# Clone todos os projetos listados no catálogo para projetos/{nome}
# A hierarquia de grupos/diretórios existe apenas no catálogo (para montar URLs).
# Localmente todos os projetos ficam flat em projetos/.
#
# Uso:
#   ./scripts/git/clone-all.sh                          # Clona todos (SSH)
#   ./scripts/git/clone-all.sh --filter admin,security   # Clona apenas os especificados
#   ./scripts/git/clone-all.sh -p http                   # Clona via HTTP/HTTPS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CATALOG="$WORKSPACE_ROOT/catalogo/services.yaml"
PROJECTS_DIR="$WORKSPACE_ROOT/projects"

FILTER=""
PROTOCOL="ssh"
while [[ $# -gt 0 ]]; do
  case $1 in
    --filter) FILTER="$2"; shift 2 ;;
    -p|--protocol)
      case "$2" in
        ssh|http) PROTOCOL="$2" ;;
        *) echo "ERRO: Protocolo inválido '$2'. Use 'ssh' ou 'http'"; exit 1 ;;
      esac
      shift 2 ;;
    -h|--help)
      echo "Uso: $0 [opções]"
      echo "  --filter nome1,nome2   Filtra por nome de projeto"
      echo "  -p, --protocol ssh|http  Protocolo de clone (padrão: ssh)"
      exit 0 ;;
    *) echo "Uso: $0 [--filter nome1,nome2] [-p ssh|http]"; exit 1 ;;
  esac
done

# Snap binaries podem não estar no PATH (ex: WSL)
[[ -d /snap/bin ]] && export PATH="/snap/bin:$PATH"

if ! command -v yq &>/dev/null; then
  echo "ERRO: 'yq' não encontrado. Instale com: sudo snap install yq"
  exit 1
fi

if [[ ! -f "$CATALOG" ]]; then
  echo "ERRO: Catálogo não encontrado em $CATALOG"
  exit 1
fi

mkdir -p "$PROJECTS_DIR"

CLONED=0
SKIPPED=0
ERRORS=0

clone_repo() {
  local repo_url="$1"
  local name="$2"
  local target="$PROJECTS_DIR/$name"

  # Aplicar filtro por nome
  if [[ -n "$FILTER" ]] && ! echo "$FILTER" | tr ',' '\n' | grep -qx "$name"; then
    return
  fi

  if [[ -d "$target" ]]; then
    echo "⏭  $name — já existe, pulando"
    SKIPPED=$((SKIPPED + 1))
  else
    echo "📥 Clonando $name..."
    if git clone "$repo_url" "$target"; then
      CLONED=$((CLONED + 1))
    else
      echo "   ❌ Falha ao clonar $name"
      ERRORS=$((ERRORS + 1))
    fi
  fi
}

build_url() {
  local base_url="$1"
  local name="$2"

  if [[ "$base_url" == *".git" ]]; then
    base_url="${base_url%.git}"
    local last_seg="${base_url##*/}"
    base_url="${base_url%/$last_seg}"
  fi

  # Remove protocolos existentes
  base_url="${base_url#https://}"
  base_url="${base_url#http://}"
  base_url="${base_url#git@}"

  if [[ "$PROTOCOL" == "http" ]]; then
    echo "https://${base_url}/${name}.git"
  else
    local host="${base_url%%/*}"
    local path="${base_url#*/}"
    echo "git@${host}:${path}/${name}.git"
  fi
}

NUM_GROUPS=$(yq e '.groups | length' "$CATALOG")

for (( g=0; g<NUM_GROUPS; g++ )); do
  group_name=$(yq e ".groups[$g].name" "$CATALOG")
  echo ""
  echo "━━━ Grupo: $group_name ━━━"

  # Projetos na raiz do grupo (campo 'services' com 'repo' explícito)
  NUM_ROOT=$(yq e ".groups[$g].services // [] | length" "$CATALOG")
  for (( s=0; s<NUM_ROOT; s++ )); do
    name=$(yq e ".groups[$g].services[$s].name" "$CATALOG")
      repo=$(build_url "$(yq e ".groups[$g].services[$s].repo" "$CATALOG")" "$name")
    clone_repo "$repo" "$name"
  done

  # Projetos dentro de diretórios
  NUM_DIRS=$(yq e ".groups[$g].directories // [] | length" "$CATALOG")
  for (( d=0; d<NUM_DIRS; d++ )); do
    base_url=$(yq e ".groups[$g].directories[$d].base_url" "$CATALOG")

    NUM_SERVICES=$(yq e ".groups[$g].directories[$d].services // [] | length" "$CATALOG")
    for (( s=0; s<NUM_SERVICES; s++ )); do
      name=$(yq e ".groups[$g].directories[$d].services[$s].name" "$CATALOG")
        repo=$(build_url "$base_url" "$name")
      clone_repo "$repo" "$name"
    done
  done
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Concluído. Clonados: $CLONED | Já existiam: $SKIPPED | Erros: $ERRORS"
