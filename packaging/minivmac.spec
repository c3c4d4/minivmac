Name:           minivmac
Version:        36.04
Release:        1%{?dist}
Summary:        Emulator for classic 68k Macintosh systems

License:        GPL-2.0-only
URL:            https://www.gryphel.com/c/minivmac/
Source0:        https://minivmac.github.io/gryphel-mirror/d/minivmac/minivmac-%{version}/minivmac-%{version}.src.tgz
Source1:        minivmac-launcher.sh

BuildRequires:  gcc
BuildRequires:  make
BuildRequires:  libX11-devel
BuildRequires:  SDL2-devel

# Upstream loads libasound dynamically (dlopen), so auto dependency generation
# does not detect this runtime requirement.
Recommends:     alsa-lib

%description
Mini vMac is an emulator for early 68k Macintosh systems.

This package installs a Wayland-first launcher backed by the SDL2 frontend,
with an X11 frontend as fallback.

Mini vMac requires a compatible Macintosh ROM image and system disk image,
which are not included.


%prep
%setup -q -n minivmac


%build
pushd setup
%{__cc} %{build_cflags} -o setup_t tool.c

# Wayland-capable frontend (SDL2)
./setup_t -t lx64 -api sd2 > ../setup-wayland.sh

# X11 fallback frontend
./setup_t -t lx64 > ../setup-x11.sh
popd

bash ./setup-wayland.sh

# Keep debug symbols for RPM debuginfo packages.
sed -i '/strip --strip-unneeded "minivmac"/d' Makefile

# Use Fedora toolchain flags.
sed -i \
  -e 's|^mk_COptionsCommon = .*|mk_COptionsCommon = -c %{build_cflags} -Wall -Wmissing-prototypes -Wno-uninitialized -Wundef -Wstrict-prototypes -Icfg/ -Isrc/|' \
  -e 's|$(ObjFiles) -lSDL2|$(ObjFiles) %{build_ldflags} -lSDL2|' \
  Makefile

%make_build
cp -f minivmac minivmac-wayland

bash ./setup-x11.sh
sed -i '/strip --strip-unneeded "minivmac"/d' Makefile

# Use Fedora toolchain flags and remove obsolete X11 lib search path.
sed -i \
  -e 's|^mk_COptionsCommon = .*|mk_COptionsCommon = -c %{build_cflags} -Wall -Wmissing-prototypes -Wno-uninitialized -Wundef -Wstrict-prototypes -Icfg/ -Isrc/|' \
  -e 's|$(ObjFiles) -ldl -L/usr/X11R6/lib -lX11|$(ObjFiles) %{build_ldflags} -ldl -lX11|' \
  Makefile

%make_build
cp -f minivmac minivmac-x11


%install
install -d %{buildroot}%{_libexecdir}/minivmac
install -pm0755 minivmac-wayland %{buildroot}%{_libexecdir}/minivmac/minivmac-wayland
install -pm0755 minivmac-x11 %{buildroot}%{_libexecdir}/minivmac/minivmac-x11
install -Dpm0755 %{SOURCE1} %{buildroot}%{_bindir}/minivmac


%files
%license COPYING.txt
%doc README.txt extras/trans.txt
%{_bindir}/minivmac
%{_libexecdir}/minivmac/minivmac-wayland
%{_libexecdir}/minivmac/minivmac-x11


%changelog
* Fri Feb 27 2026 Codex <codex@local> - 36.04-1
- Add Wayland-first launcher with X11 fallback
