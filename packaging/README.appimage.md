# Mini vMac AppImage Packaging

This repo includes a local AppImage build script at `packaging/build-appimage.sh`.

## 1) Install build dependencies

Install these packages with your distro package manager:

- `gcc`
- `make`
- `tar`
- `curl`
- `sha256sum`
- `sed`
- `libX11-devel`
- `SDL2-devel`

Example on Fedora:

```bash
sudo dnf install -y gcc make tar curl coreutils sed libX11-devel SDL2-devel
```

## 2) Build the AppImage

From the repository root:

```bash
./packaging/build-appimage.sh
```

Output is written to `dist/minivmac-36.04-x86_64.AppImage`.

## 3) Run

```bash
chmod +x dist/minivmac-36.04-x86_64.AppImage
./dist/minivmac-36.04-x86_64.AppImage
```

## Notes

- The build includes both backends:
  - SDL2 (`wayland` capable)
  - X11 fallback
- The launcher picks Wayland first when available, else X11.
- A compatible Macintosh ROM and system disk image are required at runtime and
  are not included.

## Backend override

```bash
MINIVMAC_BACKEND=wayland ./dist/minivmac-36.04-x86_64.AppImage
MINIVMAC_BACKEND=x11 ./dist/minivmac-36.04-x86_64.AppImage
```
