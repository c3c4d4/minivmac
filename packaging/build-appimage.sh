#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
APPIMAGE_DIR="${SCRIPT_DIR}/appimage"
VERSION="36.04"
SOURCE_FILE="minivmac-${VERSION}.src.tgz"
SOURCE_URL="https://minivmac.github.io/gryphel-mirror/d/minivmac/minivmac-${VERSION}/${SOURCE_FILE}"
CHECKSUM_FILE="${SCRIPT_DIR}/${SOURCE_FILE}.sha256"
WORKDIR="${WORKDIR:-${REPO_ROOT}/.appimage-build}"
SRC_CACHE_DIR="${WORKDIR}/sources"
TOOLS_DIR="${WORKDIR}/tools"
BUILD_DIR="${WORKDIR}/build"
APPDIR="${WORKDIR}/AppDir"
OUTDIR="${OUTDIR:-${REPO_ROOT}/dist}"
LAUNCHER_SRC="${SCRIPT_DIR}/minivmac-launcher.sh"
DESKTOP_FILE="${APPIMAGE_DIR}/minivmac.desktop"
ICON_FILE="${APPIMAGE_DIR}/minivmac.png"

for cmd in gcc make curl tar sha256sum sed; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "Missing required command: ${cmd}" >&2
    exit 1
  fi
done

if [[ ! -f "${CHECKSUM_FILE}" ]]; then
  echo "Missing checksum file: ${CHECKSUM_FILE}" >&2
  exit 1
fi

if [[ ! -f "${LAUNCHER_SRC}" ]]; then
  echo "Missing launcher script: ${LAUNCHER_SRC}" >&2
  exit 1
fi

if [[ ! -f "${DESKTOP_FILE}" || ! -f "${ICON_FILE}" ]]; then
  echo "Missing AppImage desktop/icon assets in ${APPIMAGE_DIR}" >&2
  exit 1
fi

mkdir -p "${SRC_CACHE_DIR}" "${TOOLS_DIR}" "${BUILD_DIR}" "${OUTDIR}"
SOURCE_PATH="${SRC_CACHE_DIR}/${SOURCE_FILE}"

if [[ ! -f "${SOURCE_PATH}" ]]; then
  echo "Downloading source tarball..."
  curl -fL "${SOURCE_URL}" -o "${SOURCE_PATH}"
fi

EXPECTED_SHA256="$(awk '{print $1}' "${CHECKSUM_FILE}")"
echo "${EXPECTED_SHA256}  ${SOURCE_PATH}" | sha256sum --check --status

ensure_tool() {
  local name="$1"
  local url="$2"
  local path="${TOOLS_DIR}/${name}"

  if [[ -x "${path}" ]]; then
    printf '%s\n' "${path}"
    return 0
  fi

  echo "Downloading ${name}..." >&2
  curl -fL "${url}" -o "${path}"
  chmod +x "${path}"
  printf '%s\n' "${path}"
}

LINUXDEPLOY="$(ensure_tool linuxdeploy-x86_64.AppImage https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage)"
APPIMAGETOOL="$(ensure_tool appimagetool-x86_64.AppImage https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage)"

rm -rf "${BUILD_DIR}" "${APPDIR}"
mkdir -p "${BUILD_DIR}" "${APPDIR}/usr/bin" "${APPDIR}/usr/libexec/minivmac" "${APPDIR}/usr/share/licenses/minivmac" "${APPDIR}/usr/share/applications" "${APPDIR}/usr/share/icons/hicolor/256x256/apps"

tar -xf "${SOURCE_PATH}" -C "${BUILD_DIR}"
SRC_DIR="${BUILD_DIR}/minivmac"

if [[ ! -d "${SRC_DIR}" ]]; then
  echo "Unexpected source layout: ${SRC_DIR} not found" >&2
  exit 1
fi

pushd "${SRC_DIR}" >/dev/null

# Build setup tool used by upstream build generation scripts.
gcc -O2 -o setup/setup_t setup/tool.c

# Wayland-capable frontend (SDL2)
./setup/setup_t -t lx64 -api sd2 > setup-wayland.sh
bash setup-wayland.sh
sed -i '/strip --strip-unneeded "minivmac"/d' Makefile
make -j"$(nproc)"
install -m0755 minivmac "${APPDIR}/usr/libexec/minivmac/minivmac-wayland"

# X11 fallback frontend
./setup/setup_t -t lx64 > setup-x11.sh
bash setup-x11.sh
sed -i '/strip --strip-unneeded "minivmac"/d' Makefile
sed -i 's|$(ObjFiles) -ldl -L/usr/X11R6/lib -lX11|$(ObjFiles) -ldl -lX11|' Makefile
make -j"$(nproc)"
install -m0755 minivmac "${APPDIR}/usr/libexec/minivmac/minivmac-x11"

install -m0644 COPYING.txt "${APPDIR}/usr/share/licenses/minivmac/COPYING.txt"

popd >/dev/null

install -m0755 "${LAUNCHER_SRC}" "${APPDIR}/usr/bin/minivmac"
install -m0644 "${DESKTOP_FILE}" "${APPDIR}/usr/share/applications/minivmac.desktop"
install -m0644 "${ICON_FILE}" "${APPDIR}/usr/share/icons/hicolor/256x256/apps/minivmac.png"

# Required top-level entries for appimagetool.
install -m0644 "${DESKTOP_FILE}" "${APPDIR}/minivmac.desktop"
install -m0644 "${ICON_FILE}" "${APPDIR}/minivmac.png"
cat > "${APPDIR}/AppRun" << 'APP_RUN'
#!/usr/bin/env sh
exec "${APPDIR}/usr/bin/minivmac" "$@"
APP_RUN
chmod +x "${APPDIR}/AppRun"

export ARCH=x86_64
export NO_STRIP=1
APPIMAGE_EXTRACT_AND_RUN=1 "${LINUXDEPLOY}" \
  --appdir "${APPDIR}" \
  --desktop-file "${APPDIR}/usr/share/applications/minivmac.desktop" \
  --icon-file "${APPDIR}/usr/share/icons/hicolor/256x256/apps/minivmac.png" \
  --executable "${APPDIR}/usr/libexec/minivmac/minivmac-wayland" \
  --executable "${APPDIR}/usr/libexec/minivmac/minivmac-x11"

APPIMAGE_PATH="${OUTDIR}/minivmac-${VERSION}-x86_64.AppImage"
APPIMAGE_EXTRACT_AND_RUN=1 "${APPIMAGETOOL}" "${APPDIR}" "${APPIMAGE_PATH}"

echo
echo "Build complete."
echo "AppImage: ${APPIMAGE_PATH}"
