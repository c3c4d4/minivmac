# Mini vMac RPM Packaging

This repo includes:

- RPM spec: `packaging/minivmac.spec`
- Build helper: `packaging/build-rpm.sh`

## 1) Install build dependencies

Install these packages with your distro package manager:

- `rpm-build`
- `rpmdevtools`
- `gcc`
- `make`
- `libX11-devel`
- `SDL2-devel`
- `curl`

Example on Fedora:

```bash
sudo dnf install -y rpm-build rpmdevtools gcc make libX11-devel SDL2-devel curl
```

## 2) Build the RPM

From the repository root:

```bash
./packaging/build-rpm.sh
```

Output RPMs are written under `.rpmbuild/RPMS/` and SRPMs under `.rpmbuild/SRPMS/`.

## 3) Install the generated RPM

Install using your system package tool. Example on Fedora:

```bash
sudo dnf install ./.rpmbuild/RPMS/x86_64/minivmac-36.04-1*.rpm
```

## Notes

- The package builds two frontends:
  - SDL2 (`wayland` capable)
  - X11 fallback
- A Macintosh ROM is required at runtime and is not included.
- The build script verifies source integrity with SHA-256 before building.

## Backend override

The launcher defaults to Wayland in Wayland sessions and falls back to X11.

You can force a backend:

```bash
MINIVMAC_BACKEND=wayland minivmac
MINIVMAC_BACKEND=x11 minivmac
```
