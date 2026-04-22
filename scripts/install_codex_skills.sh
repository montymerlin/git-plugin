#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Install git-plugin skills globally for Codex.

Usage:
  install_codex_skills.sh [--from-github] [--ref <git-ref>] [--force]
                          [--codex-home <path>] [--source-root <path>]

Modes:
  --from-github    Clone or update the repo at $CODEX_HOME/vendor_imports/repos/git-plugin
                   and install skills from there.

  default          Install from the current checkout (or --source-root).

Options:
  --force          Replace existing git-plugin Codex skill links if present.
  --codex-home     Override CODEX_HOME (default: ~/.codex).
  --source-root    Install from a specific checkout instead of the current repo.
  --ref            Git ref to clone/update when using --from-github (default: main).
EOF
}

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
SOURCE_ROOT=""
FROM_GITHUB=0
FORCE=0
REF="main"
REPO_URL="https://github.com/montymerlin/git-plugin.git"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-github) FROM_GITHUB=1 ;;
    --force) FORCE=1 ;;
    --codex-home) CODEX_HOME="$2"; shift ;;
    --source-root) SOURCE_ROOT="$2"; shift ;;
    --ref) REF="$2"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [[ -z "$SOURCE_ROOT" ]]; then
  SOURCE_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
fi

if [[ "$FROM_GITHUB" -eq 1 ]]; then
  SOURCE_ROOT="$CODEX_HOME/vendor_imports/repos/git-plugin"
  mkdir -p "$(dirname "$SOURCE_ROOT")"
  if [[ -d "$SOURCE_ROOT/.git" ]]; then
    git -C "$SOURCE_ROOT" fetch origin "$REF"
    git -C "$SOURCE_ROOT" checkout "$REF"
    git -C "$SOURCE_ROOT" pull --ff-only origin "$REF"
  else
    git clone --branch "$REF" "$REPO_URL" "$SOURCE_ROOT"
  fi
fi

mkdir -p "$CODEX_HOME/skills"

install_link() {
  local name="$1"
  local source="$2"
  local target="$CODEX_HOME/skills/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    if [[ "$FORCE" -eq 1 ]]; then
      rm -rf "$target"
    else
      echo "Refusing to replace existing $target without --force" >&2
      exit 1
    fi
  fi

  ln -s "$source" "$target"
}

install_link "git-commit" "$SOURCE_ROOT/skills/commit"
install_link "git-pr" "$SOURCE_ROOT/skills/pr"
install_link "git-status" "$SOURCE_ROOT/skills/status"

echo "Installed git-plugin skills into $CODEX_HOME/skills"
echo "Restart Codex to pick up new skills."
