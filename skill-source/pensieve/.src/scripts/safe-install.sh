#!/bin/bash
# Safe install/reinstall wrapper for Pensieve skill.
#
# Backs up user data before `npx skills add --copy`, then restores.
# Usage:
#   bash safe-install.sh [--agent <agent>] [--source <url-or-path>]
#
# Defaults:
#   --agent  claude-code
#   --source https://github.com/kingkongshot/Pensieve/tree/experimental/skill-source/pensieve

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

AGENT="claude-code"
SOURCE="https://github.com/kingkongshot/Pensieve/tree/experimental/skill-source/pensieve"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent|-a)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      AGENT="$2"
      shift 2
      ;;
    --source|-s)
      [[ $# -ge 2 ]] || { echo "Missing value for $1" >&2; exit 1; }
      SOURCE="$2"
      shift 2
      ;;
    -h|--help)
      sed -n '2,8s/^# //p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

SKILL_ROOT="$(skill_root_from_script "$SCRIPT_DIR" 2>/dev/null || true)"
PROJECT_ROOT="$(project_root "$SCRIPT_DIR")"
STATE_DIR="$(state_root "$SCRIPT_DIR")"
ensure_state_dir "$STATE_DIR" >/dev/null

BACKUP_DIR="$STATE_DIR/pensieve-install-backup-$$"
HAS_BACKUP=0

if [[ -n "$SKILL_ROOT" && -d "$SKILL_ROOT" ]]; then
  if backup_user_data "$SKILL_ROOT" "$BACKUP_DIR"; then
    HAS_BACKUP=1
    echo "Backed up user data to $BACKUP_DIR"
  fi
fi

echo "Installing skill from: $SOURCE"
(
  cd "$PROJECT_ROOT"
  npx skills add "$SOURCE" --copy -a "$AGENT" -y
)

# Re-resolve skill root after install (directory may have been recreated)
SKILL_ROOT="$(skill_root_from_script "$SCRIPT_DIR" 2>/dev/null || true)"

if [[ "$HAS_BACKUP" -eq 1 && -n "$SKILL_ROOT" ]]; then
  restore_user_data "$SKILL_ROOT" "$BACKUP_DIR"
  cleanup_backup "$BACKUP_DIR"
  echo "User data restored"
fi

echo "Done. Run init to seed missing files, then doctor to verify:"
echo "  bash .src/scripts/init-project-data.sh"
echo "  bash .src/scripts/run-doctor.sh --strict"
