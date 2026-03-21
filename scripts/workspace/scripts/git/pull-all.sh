#!/usr/bin/env bash
# Pull (atualiza) todos os projetos em projetos/
# Uso:
#   ./scripts/git/pull-all.sh                          # Atualiza todos
#   ./scripts/git/pull-all.sh --filter admin,security   # Atualiza apenas os especificados

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="$(cd "$SCRIPT_DIR/../../projects" && pwd)"

FILTER=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --filter) FILTER="$2"; shift 2 ;;
    -h|--help) echo "Uso: $0 [--filter nome1,nome2]"; exit 0 ;;
    *) echo "Uso: $0 [--filter nome1,nome2]"; exit 1 ;;
  esac
done

SUCCESS=0
ERRORS=0

for dir in "$PROJECTS_DIR"/*/; do
  [[ ! -d "$dir/.git" ]] && continue
  name=$(basename "$dir")

  if [[ -n "$FILTER" ]] && ! echo "$FILTER" | tr ',' '\n' | grep -qx "$name"; then
    continue
  fi

  branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "detached")
  echo "🔄 $name ($branch)..."

  if git -C "$dir" pull --rebase; then
    SUCCESS=$((SUCCESS + 1))
  else
    echo "   ⚠️  Falha no pull de $name"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""
echo "Concluído. Atualizados: $SUCCESS | Erros: $ERRORS"
