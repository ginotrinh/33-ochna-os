#!/usr/bin/env bash
# OCHNA-D7: build the ochna-aero-theme .deb (COSMIC defaults, wallpaper) into out/desktop/ochna-aero-theme/
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
THEME="${1:-ochna-aero}"
PKG="$THEME-theme"
VERSION="${VERSION:-0.1.0}"
WORK="$ROOT/build/theme/$PKG"
OUT="$ROOT/out/desktop/$PKG"

cargo build --release --locked --manifest-path "$HERE/ochna-theme/Cargo.toml"
rm -rf "$WORK"
mkdir -p "$WORK/usr" "$WORK/DEBIAN" "$OUT"
"$HERE/ochna-theme/target/release/ochna-theme" "$HERE/$THEME" "$WORK/usr"
find "$WORK/usr" -type d -exec chmod 0755 {} +
find "$WORK/usr" -type f -exec chmod 0644 {} +

# OCHNA-D7: divert every shipped file so packages that own the same path keep their copy as <file>.cosmic
FILES="$(cd "$WORK" && find usr -type f | sort | sed 's|^|/|')"
{
    echo '#!/bin/sh'
    echo 'set -e'
    echo 'if [ "$1" = install ] || [ "$1" = upgrade ]; then'
    for f in $FILES; do echo "    dpkg-divert --package $PKG --add --rename --divert '$f.cosmic' '$f'"; done
    echo 'fi'
} > "$WORK/DEBIAN/preinst"
{
    echo '#!/bin/sh'
    echo 'set -e'
    echo 'if [ "$1" = remove ] || [ "$1" = abort-install ] || [ "$1" = disappear ]; then'
    for f in $FILES; do echo "    dpkg-divert --package $PKG --remove --rename --divert '$f.cosmic' '$f'"; done
    echo 'fi'
} > "$WORK/DEBIAN/postrm"
chmod 0755 "$WORK/DEBIAN/preinst" "$WORK/DEBIAN/postrm"

cat > "$WORK/DEBIAN/control" <<EOF
Package: $PKG
Version: $VERSION
Architecture: all
Maintainer: OchnaOS <ochna@localhost>
Depends: cosmic-settings, cosmic-bg, fonts-roboto-unhinted
Section: x11
Priority: optional
Description: $THEME theme for the ochna-aero desktop
 Default colours, corner radii, interface font, icon theme and wallpaper.
EOF
dpkg-deb --root-owner-group --build "$WORK" "$OUT/${PKG}_${VERSION}_all.deb"
