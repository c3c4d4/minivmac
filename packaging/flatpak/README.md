# Mini vMac Flatpak

This directory contains a Flathub-ready Flatpak manifest and metadata:

- `io.github.c3c4d4.minivmac.yml`
- `io.github.c3c4d4.minivmac.desktop`
- `io.github.c3c4d4.minivmac.metainfo.xml`
- `io.github.c3c4d4.minivmac.svg`

The build ships:

- Wayland-capable SDL2 frontend (`minivmac-wayland`)
- X11 frontend fallback (`minivmac-x11`)
- `minivmac` launcher script that prefers Wayland in Wayland sessions

## Prerequisites

Install `flatpak` and `flatpak-builder` with your distro package manager.

Example on Fedora:

```bash
sudo dnf install -y flatpak flatpak-builder
```

## Build and install locally

From repository root:

```bash
flatpak-builder --force-clean build-dir packaging/flatpak/io.github.c3c4d4.minivmac.yml
flatpak-builder --user --install --force-clean build-dir packaging/flatpak/io.github.c3c4d4.minivmac.yml
```

If you are building from inside a container and hit a `rofiles-fuse`
permission error, add `--disable-rofiles-fuse` to the commands above.

Run:

```bash
flatpak run io.github.c3c4d4.minivmac
```

By default, the sandbox grants file access to:

- `~/Documents`
- `~/Downloads`

Store ROM and disk image files there, or use a Flatpak override if you need a
different location.

If you already installed an older local build and see EGL/ZINK startup errors,
apply:

```bash
flatpak override --user --device=dri io.github.c3c4d4.minivmac
```

## Backend override

Use `MINIVMAC_BACKEND`:

- `auto` (default): Wayland when available, otherwise X11
- `wayland`: force Wayland frontend
- `x11`: force X11 frontend

Example:

```bash
flatpak run --env=MINIVMAC_BACKEND=x11 io.github.c3c4d4.minivmac
```

Note: this Flatpak uses `--socket=fallback-x11`, so forced X11 is expected to
work when Wayland is unavailable (for example an X11 session).

## Flathub Submission

Use `packaging/flatpak/flathub-pr.md` as the PR text when opening the
submission against `flathub/flathub:new-pr`.

To copy submission files into a local clone of `flathub/flathub`, run:

```bash
./packaging/flatpak/export-flathub-files.sh /path/to/flathub
```
