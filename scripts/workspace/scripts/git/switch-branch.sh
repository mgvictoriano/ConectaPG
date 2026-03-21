#!/usr/bin/env bash
# Troca a branch de todos os projetos
# Uso:
#   ./scripts/git/switch-branch.sh <branch>                          # Todos
#   ./scripts/git/switch-branch.sh <branch> --filter admin,security   # Filtrados

set -euo pipefail

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  echo "Uso: $0 <branch> [--filter nome1,nome2]"
  exit 0
fi

BRANCH="$1"
shift

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="$(cd "$SCRIPT_DIR/../../projects" && pwd)"

FILTER=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --filter) FILTER="$2"; shift 2 ;;
    *) shift ;;
  esac
done

SWITCHED=0
ALREADY=0
ERRORS=0

for dir in "$PROJECTS_DIR"/*/; do
  [[ ! -d "$dir/.git" ]] && continue
  name=$(basename "$dir")

  if [[ -n "$FILTER" ]] && ! echo "$FILTER" | tr ',' '\n' | grep -qx "$name"; then
    continue
  fi

  current=$(git -C "$dir" branch --show-current 2>/dev/null || echo "detached")

  if [[ "$current" == "$BRANCH" ]]; then
    echo "✅ $name — já em $BRANCH"
    ALREADY=$((ALREADY + 1))
  elif git -C "$dir" checkout "$BRANCH" 2>/dev/null; then
    echo "🔀 $name — $current → $BRANCH"
    SWITCHED=$((SWITCHED + 1))
  elif git -C "$dir" checkout -b "$BRANCH" "origin/$BRANCH" 2>/dev/null; then
    echo "🔀 $name — $current → $BRANCH (tracking remoto)"
    SWITCHED=$((SWITCHED + 1))
  else
    echo "⚠️  $name — branch '$BRANCH' não encontrada"
    ERRORS=$((ERRORS + 1))
  fi
done

echo ""
echo "Concluído. Trocados: $SWITCHED | Já na branch: $ALREADY | Não encontrada: $ERRORS"
