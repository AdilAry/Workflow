#!/usr/bin/env bash
# Install (or refresh) the short-loop workflow for the agents on this machine.
# Linux and macOS. On Windows, run it in Git Bash (it comes with Git for Windows):
# there it always copies, and it also saves WORKFLOW_DIR as a Windows variable.
#
#     bash install.sh [--copy] [extra-commands-dir ...]
#
# For each agent harness it finds (pi, Claude Code) it does two things:
#
#   1. Makes /idea, /start, /wrap and /judge exist in every project, by LINKING
#      templates/commands/*.md into the folder that harness reads commands from.
#      Linked, not copied: after a `git pull` (or an edit) in this folder the
#      commands are up to date at once, with nothing to re-run.
#      --copy copies the files instead. Use it if a harness does not show the
#      linked commands, or if this folder may move or be deleted. After a copy
#      install, run this script again whenever the commands change.
#      Extra directories given on the command line are installed the same way
#      (a kit built on this workflow passes its own commands folder).
#
#   2. Installs templates/user-level/AGENTS.md ("How I work") as that harness's
#      global instructions file, but ONLY if there is none yet. That file is
#      yours to edit, so it is always a copy and is never overwritten.
#
#   pi           ~/.pi/agent/prompts/      ~/.pi/agent/AGENTS.md
#   Claude Code  ~/.claude/commands/       ~/.claude/CLAUDE.md
#
# For Claude Code it also creates ~/.claude/settings.json with medium as the
# default effort, but ONLY if there is no such file yet. An existing one is
# never edited; the script prints the line to add instead.
#
# It also saves this folder as WORKFLOW_DIR in ~/.bashrc, so kits built on the
# workflow can find it (WORKFLOW.md section 8). If the folder moves, run this
# again. With zsh (the macOS default), copy that line to ~/.zshrc yourself.
set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
MODE="link"
SOURCES=("$HERE/templates/commands")
for arg in "$@"; do
  case "$arg" in
    --copy) MODE="copy" ;;
    --link) MODE="link" ;;
    -*) echo "usage: bash install.sh [--copy] [extra-commands-dir ...]" >&2; exit 1 ;;
    *) [[ -d "$arg" ]] || { echo "not a directory: $arg" >&2; exit 1; }
       SOURCES+=("$(cd "$arg" && pwd)") ;;
  esac
done

# Windows (Git Bash): ln -s silently makes a copy there, so copy on purpose,
# and save WORKFLOW_DIR for PowerShell too, which doesn't read ~/.bashrc.
WINDOWS=0
case "$(uname -s)" in MINGW*|MSYS*|CYGWIN*) WINDOWS=1; MODE="copy" ;; esac

install_for() {   # <name> <commands-dir> <global-instructions-file>
  local name="$1" cmd_dir="$2" global="$3" src f dest
  echo "$name:"
  mkdir -p "$cmd_dir" "$(dirname "$global")"
  for src in "${SOURCES[@]}"; do
    for f in "$src"/*.md; do
      [[ -e "$f" ]] || continue
      dest="$cmd_dir/$(basename "$f")"
      # Remove what is there first: copying onto an old link would write through it.
      if [[ -L "$dest" || -f "$dest" ]]; then rm -f "$dest"; fi
      if [[ "$MODE" == link ]]; then ln -s "$f" "$dest"; else cp "$f" "$dest"; fi
      echo "  /$(basename "$f" .md)"
    done
  done
  # A link whose file is gone (a command that was removed or renamed) is only clutter.
  for dest in "$cmd_dir"/*.md; do
    if [[ -L "$dest" && ! -e "$dest" ]]; then rm -f "$dest"; echo "  removed dead link $(basename "$dest")"; fi
  done
  if [[ ! -e "$global" ]]; then
    cp "$HERE/templates/user-level/AGENTS.md" "$global"
    echo "  installed $global  <- open it once and fill the one [bracket]"
  elif ! cmp -s "$HERE/templates/user-level/AGENTS.md" "$global"; then
    echo "  kept your $global (it differs from templates/user-level/AGENTS.md;"
    echo "    compare with: diff \"$HERE/templates/user-level/AGENTS.md\" \"$global\")"
  else
    echo "  $global is up to date"
  fi
}

# Where this workflow lives, for kits. One line in ~/.bashrc, replaced if the folder moved.
# Saved before looking for an agent, so it is set even on a machine that has none yet.
RC="$HOME/.bashrc"
LINE="export WORKFLOW_DIR=\"$HERE\""
if ! grep -qxF "$LINE" "$RC" 2>/dev/null; then
  if grep -q '^export WORKFLOW_DIR=' "$RC" 2>/dev/null; then
    TMP="$(mktemp)"
    grep -v '^export WORKFLOW_DIR=' "$RC" > "$TMP" || true
    cat "$TMP" > "$RC"   # write through, so a linked ~/.bashrc stays a link
    rm -f "$TMP"
  fi
  echo "$LINE" >> "$RC"
  echo "Saved WORKFLOW_DIR=$HERE in ~/.bashrc (open a new terminal to use it)"
fi
if [[ $WINDOWS -eq 1 ]]; then
  WIN_HERE="$(cygpath -w "$HERE")"
  setx WORKFLOW_DIR "$WIN_HERE" >/dev/null
  echo "Saved WORKFLOW_DIR=$WIN_HERE for Windows too (new terminals see it)"
fi

found=0
PI_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
if command -v pi >/dev/null 2>&1 || [[ -d "$PI_DIR" ]]; then
  install_for "pi" "$PI_DIR/prompts" "$PI_DIR/AGENTS.md"
  found=1
fi
if command -v claude >/dev/null 2>&1 || [[ -d "$HOME/.claude" ]]; then
  install_for "Claude Code" "$HOME/.claude/commands" "$HOME/.claude/CLAUDE.md"
  # Default effort medium; /start and /judge raise it to high for their own turn.
  # Only a missing file is created: an existing one may hold your permissions and
  # hooks, and Claude Code writes to it too, so it is never edited.
  SETTINGS="$HOME/.claude/settings.json"
  if [[ ! -e "$SETTINGS" ]]; then
    printf '{\n  "effortLevel": "medium"\n}\n' > "$SETTINGS"
    echo "  installed $SETTINGS (default effort: medium)"
  elif ! grep -q '"effortLevel"' "$SETTINGS"; then
    echo "  kept your $SETTINGS; to make medium the default effort, add this to it yourself:"
    echo "    \"effortLevel\": \"medium\""
  fi
  found=1
fi
if [[ $found -eq 0 ]]; then
  echo "No agent harness found (looked for pi and Claude Code). WORKFLOW_DIR is saved; install an agent, then run this again." >&2
  exit 1
fi

if [[ "$MODE" == link ]]; then
  echo "Done (linked). Type / in a new session: /idea, /start, /wrap and /judge must be offered."
  echo "If they are not, run:  bash \"$HERE/install.sh\" --copy"
elif [[ $WINDOWS -eq 1 ]]; then
  echo "Done (copied: Windows can't link them). Run this again after every git pull in this folder."
else
  echo "Done (copied). Run this again whenever the commands change."
fi
