## Add `io.github.c3c4d4.minivmac`

This PR adds Mini vMac as a new Flatpak app.

- App ID: `io.github.c3c4d4.minivmac`
- License: `GPL-2.0-only`
- Upstream source: `https://minivmac.github.io/gryphel-mirror/d/minivmac/minivmac-36.04/minivmac-36.04.src.tgz`

### Runtime behavior

- Builds two frontends:
  - Wayland-capable SDL2 binary (`minivmac-wayland`)
  - X11 fallback binary (`minivmac-x11`)
- Installs a launcher (`minivmac`) that selects Wayland first when available and falls back to X11.

### Permissions rationale

- `--socket=wayland`: native Wayland display support.
- `--socket=fallback-x11`: fallback for non-Wayland sessions or explicit X11 use.
- `--device=dri`: required for working graphics acceleration paths on modern Mesa stacks.
- `--socket=pulseaudio`: emulator audio output.
- `--filesystem=xdg-documents` and `--filesystem=xdg-download`: access to user-provided ROM files and disk images without broad home-directory permission.

### Important runtime note

A compatible Macintosh ROM file and system disk images are required by Mini vMac and are not distributed by this package.

### Validation performed

- `appstreamcli validate --pedantic io.github.c3c4d4.minivmac.metainfo.xml`
- `flatpak-builder --disable-rofiles-fuse --force-clean --repo=repo build-dir io.github.c3c4d4.minivmac.yml`
