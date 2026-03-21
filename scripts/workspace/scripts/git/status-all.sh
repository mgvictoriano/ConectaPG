#!/usr/bin/env bash
# Status resumido de todos os projetos
# Uso: ./scripts/git/status-all.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_DIR="$(cd "$SCRIPT_DIR/../../projects" && pwd)"

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  echo "Uso: $0"
  exit 0
fi

printf "%-30s %-25s %-12s %s\n" "PROJETO" "BRANCH" "STATUS" "PENDÊNCIAS"
printf "%-30s %-25s %-12s %s\n" "-------" "------" "------" "----------"

for dir in "$PROJECTS_DIR"/*/; do
  [[ ! -d "$dir/.git" ]] && continue
  name=$(basename "$dir")

  branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "detached")
  changes=$(git -C "$dir" status --porcelain 2>/dev/null | wc -l | tr -d ' ')

  if [[ "$changes" -eq 0 ]]; then
    status="limpo"
    pending="-"
  else
    status="modificado"
    pending="$changes arquivo(s)"
  fi

  printf "%-30s %-25s %-12s %s\n" "$name" "$branch" "$status" "$pending"
done
