#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SPEC_FILE="${REPO_ROOT}/packaging/minivmac.spec"
TOPDIR="${TOPDIR:-${REPO_ROOT}/.rpmbuild}"
LOCAL_SOURCE1="${REPO_ROOT}/packaging/minivmac-launcher.sh"

for cmd in rpmbuild rpmspec curl sha256sum; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}"
    exit 1
  fi
done

SOURCE_URL="$(rpmspec -P "${SPEC_FILE}" | awk '$1 == "Source0:" { print $2 }')"
SOURCE_FILE="$(basename "${SOURCE_URL}")"
CHECKSUM_FILE="${SCRIPT_DIR}/${SOURCE_FILE}.sha256"

if [[ ! -f "${CHECKSUM_FILE}" ]]; then
  echo "Missing checksum file: ${CHECKSUM_FILE}"
  exit 1
fi

mkdir -p \
  "${TOPDIR}/BUILD" \
  "${TOPDIR}/BUILDROOT" \
  "${TOPDIR}/RPMS" \
  "${TOPDIR}/SOURCES" \
  "${TOPDIR}/SPECS" \
  "${TOPDIR}/SRPMS"

cp -f "${SPEC_FILE}" "${TOPDIR}/SPECS/minivmac.spec"
cp -f "${LOCAL_SOURCE1}" "${TOPDIR}/SOURCES/minivmac-launcher.sh"

if [[ ! -f "${TOPDIR}/SOURCES/${SOURCE_FILE}" ]]; then
  echo "Downloading source tarball..."
  curl -fL "${SOURCE_URL}" -o "${TOPDIR}/SOURCES/${SOURCE_FILE}"
fi

EXPECTED_SHA256="$(awk '{print $1}' "${CHECKSUM_FILE}")"
echo "${EXPECTED_SHA256}  ${TOPDIR}/SOURCES/${SOURCE_FILE}" | sha256sum --check --status

rpmbuild -ba "${TOPDIR}/SPECS/minivmac.spec" --define "_topdir ${TOPDIR}"

echo
echo "Build complete."
echo "RPMs:   ${TOPDIR}/RPMS"
echo "SRPMs:  ${TOPDIR}/SRPMS"
