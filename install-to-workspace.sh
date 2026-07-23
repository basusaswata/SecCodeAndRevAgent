#!/usr/bin/env bash
# Install AISecCore + thin IDE adapters into a target app/workspace.
#
# Usage:
#   ./install-to-workspace.sh [TARGET_DIR]
#
# Copies:
#   AISecCore/          → shared skills, agents, prompts
#   .cursor/            → single Cursor adapter rule + agent pointer
#   .github/            → single Copilot instruction + prompt pointer
#   .claude/            → single Claude Code instruction
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-.}"

if [[ ! -d "${SCRIPT_DIR}/AISecCore" ]]; then
  echo "ERROR: AISecCore/ not found next to this script." >&2
  exit 1
fi

mkdir -p "${TARGET}/AISecCore" \
         "${TARGET}/.cursor/rules" \
         "${TARGET}/.cursor/agents" \
         "${TARGET}/.github/instructions" \
         "${TARGET}/.github/prompts" \
         "${TARGET}/.claude"

# Canonical content
rsync -a --delete \
  --exclude '.DS_Store' \
  "${SCRIPT_DIR}/AISecCore/" "${TARGET}/AISecCore/"

# Thin adapters (single instruction files per system)
cp -f "${SCRIPT_DIR}/.cursor/rules/aisec-core.mdc" \
      "${TARGET}/.cursor/rules/aisec-core.mdc"
cp -f "${SCRIPT_DIR}/.cursor/agents/scgra-reviewer.md" \
      "${TARGET}/.cursor/agents/scgra-reviewer.md"
cp -f "${SCRIPT_DIR}/.github/instructions/aisec-core.instructions.md" \
      "${TARGET}/.github/instructions/aisec-core.instructions.md"
cp -f "${SCRIPT_DIR}/.github/prompts/scgra-reviewer.md" \
      "${TARGET}/.github/prompts/scgra-reviewer.md"
cp -f "${SCRIPT_DIR}/.claude/INSTRUCTIONS.md" \
      "${TARGET}/.claude/INSTRUCTIONS.md"

echo "Installed AISecCore pack to ${TARGET}:"
echo "  AISecCore/skills   ($(ls -1 "${TARGET}/AISecCore/skills"/scgra-*.md 2>/dev/null | wc -l | tr -d ' ') skills)"
echo "  AISecCore/agents   + prompts"
echo "  .cursor/           (aisec-core.mdc + scgra-reviewer agent)"
echo "  .github/           (aisec-core.instructions.md + prompt)"
echo "  .claude/           (INSTRUCTIONS.md)"
echo "Done."
