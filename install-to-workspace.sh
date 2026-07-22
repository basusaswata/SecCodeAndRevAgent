#!/usr/bin/env bash
# Install SecureCodeGenRevAgent (SCGRA) rules into a target directory.
#
# Usage:
#   ./install-to-workspace.sh [TARGET_DIR]
#
# TARGET_DIR defaults to /Users/saswatabasu/Saswata/eclipse-workspace
# For a single app repo: ./install-to-workspace.sh /path/to/your-app
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-/Users/saswatabasu/Saswata/eclipse-workspace}"

mkdir -p "${TARGET}/.cursor/rules" \
         "${TARGET}/.cursor/agents" \
         "${TARGET}/.github/instructions" \
         "${TARGET}/.github/prompts"

cp -R "${SCRIPT_DIR}/cursor/rules/"*        "${TARGET}/.cursor/rules/"
cp -R "${SCRIPT_DIR}/cursor/agents/"*       "${TARGET}/.cursor/agents/"
cp -R "${SCRIPT_DIR}/github/instructions/"* "${TARGET}/.github/instructions/"
cp -R "${SCRIPT_DIR}/github/prompts/"*      "${TARGET}/.github/prompts/"

echo "SCGRA installed to ${TARGET}:"
echo "  .cursor/rules ($(ls -1 "${TARGET}/.cursor/rules"/scgra-* 2>/dev/null | wc -l | tr -d ' ') files)"
echo "  .cursor/agents"
echo "  .github/instructions"
echo "  .github/prompts"
echo "Done."
