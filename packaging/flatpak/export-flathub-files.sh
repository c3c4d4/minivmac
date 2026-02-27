#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <flathub-repo-root>" >&2
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$1"

mkdir -p "${DEST}"

cp -f "${SCRIPT_DIR}/io.github.c3c4d4.minivmac.yml" "${DEST}/"
cp -f "${SCRIPT_DIR}/io.github.c3c4d4.minivmac.desktop" "${DEST}/"
cp -f "${SCRIPT_DIR}/io.github.c3c4d4.minivmac.metainfo.xml" "${DEST}/"
cp -f "${SCRIPT_DIR}/io.github.c3c4d4.minivmac.svg" "${DEST}/"
cp -f "${SCRIPT_DIR}/minivmac-launcher.sh" "${DEST}/"

echo "Copied Flathub submission files to: ${DEST}"
