# Mini vMac Flatpak

This directory contains a local Flatpak build manifest:

- `io.github.minivmac.MinivMac.yml`

The build includes:

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
flatpak-builder --force-clean build-dir packaging/flatpak/io.github.minivmac.MinivMac.yml
flatpak-builder --user --install --force-clean build-dir packaging/flatpak/io.github.minivmac.MinivMac.yml
```

If you are building from inside a container and hit a `rofiles-fuse`
permission error, add `--disable-rofiles-fuse` to the commands above.

Run:

```bash
flatpak run io.github.minivmac.MinivMac
```

If you already installed an older local build and see EGL/ZINK startup errors,
apply:

```bash
flatpak override --user --device=dri io.github.minivmac.MinivMac
```

## Backend override

Use `MINIVMAC_BACKEND`:

- `auto` (default): Wayland when available, otherwise X11
- `wayland`: force Wayland frontend
- `x11`: force X11 frontend

Example:

```bash
flatpak run --env=MINIVMAC_BACKEND=x11 io.github.minivmac.MinivMac
```

Note: this Flatpak uses `--socket=fallback-x11`, so forced X11 is expected to
work when Wayland is unavailable (for example an X11 session).
