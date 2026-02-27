# Mini vMac Packaging

This repository packages **Mini vMac 36.04** for Linux distribution as:

- RPM
- Flatpak
- AppImage

It does not include the Mini vMac upstream source code as a git subtree, ROM files, or Macintosh system images.

## Repository Layout

- `packaging/minivmac.spec`: RPM spec
- `packaging/build-rpm.sh`: RPM build helper
- `packaging/flatpak/io.github.minivmac.MinivMac.yml`: local Flatpak manifest
- `packaging/build-appimage.sh`: AppImage build helper
- `packaging/minivmac-launcher.sh`: shared launcher with Wayland-first and X11 fallback logic

## Runtime Requirements

Mini vMac requires files that are **not** distributed here:

- A compatible Macintosh ROM image
- A bootable Macintosh system disk image

Without a bootable system disk, Mini vMac shows a floppy icon with a question mark.

## Build RPM

Install build dependencies with your distro package manager. On Fedora, for example:

```bash
sudo dnf install -y rpm-build rpmdevtools gcc make libX11-devel SDL2-devel curl
```

Build:

```bash
./packaging/build-rpm.sh
```

Output:

- RPMs: `.rpmbuild/RPMS/`
- SRPMs: `.rpmbuild/SRPMS/`

## Build Flatpak (local)

Install Flatpak tooling, then:

```bash
flatpak-builder --force-clean build-flatpak packaging/flatpak/io.github.minivmac.MinivMac.yml
flatpak-builder --user --install --force-clean build-flatpak packaging/flatpak/io.github.minivmac.MinivMac.yml
```

If running inside a container and you hit `rofiles-fuse` permissions errors, add `--disable-rofiles-fuse`.

Run:

```bash
flatpak run io.github.minivmac.MinivMac
```

## Build AppImage

Install build dependencies with your distro package manager. On Fedora, for example:

```bash
sudo dnf install -y gcc make tar curl coreutils sed libX11-devel SDL2-devel
```

Build:

```bash
./packaging/build-appimage.sh
```

Output:

- `dist/minivmac-36.04-x86_64.AppImage`

Run:

```bash
chmod +x dist/minivmac-36.04-x86_64.AppImage
./dist/minivmac-36.04-x86_64.AppImage
```

If your environment lacks FUSE support, run with:

```bash
APPIMAGE_EXTRACT_AND_RUN=1 ./dist/minivmac-36.04-x86_64.AppImage
```

## Backend Selection

The launcher defaults to:

- Wayland backend in Wayland sessions
- X11 backend otherwise

Override manually:

```bash
MINIVMAC_BACKEND=wayland minivmac
MINIVMAC_BACKEND=x11 minivmac
```

For Flatpak:

```bash
flatpak run --env=MINIVMAC_BACKEND=x11 io.github.minivmac.MinivMac
```

For AppImage:

```bash
MINIVMAC_BACKEND=x11 ./dist/minivmac-36.04-x86_64.AppImage
```

## Release Assets

Current release tag: `v36.04`

To upload artifacts (including AppImage) to GitHub release:

```bash
gh release upload v36.04 \
  dist/minivmac-36.04-1.fc43.x86_64.rpm \
  dist/minivmac-36.04-1.fc43.src.rpm \
  dist/minivmac-36.04.flatpak \
  dist/minivmac-36.04-x86_64.AppImage \
  dist/SHA256SUMS \
  --clobber
```
