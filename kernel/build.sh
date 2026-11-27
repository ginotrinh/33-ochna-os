#!/usr/bin/env bash
# OCHNA-K1: build the OchnaOS kernel as .deb packages.
# Usage: kernel/build.sh [VERSION|auto]   (auto = latest release of kernel/series on kernel.org)
# Output: out/linux-image-*.deb, out/linux-headers-*.deb, out/SHA256SUMS
# Exit: 0 built | 1 download, checksum or build failure | 2 usage or missing tool
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
BUILD="$ROOT/build"
OUT="$ROOT/out"
SERIES="$(tr -d '[:space:]' < "$HERE/series")"
WANT="${1:-auto}"

die() { echo "build.sh: $1" >&2; exit "${2:-1}"; }

for t in curl xz make gcc bc bison flex dpkg-buildpackage rsync cpio python3 rustc bindgen; do
    command -v "$t" >/dev/null || die "missing tool: $t" 2
done

# OCHNA-K1: resolve the version
if [ "$WANT" = auto ]; then
    VERSION="$(curl -fsSL https://www.kernel.org/releases.json | python3 -c "
import json, sys
s = sys.argv[1]
v = [r['version'] for r in json.load(sys.stdin)['releases'] if r['version'].startswith(s + '.')]
print(v[0] if v else '')" "$SERIES")"
    [ -n "$VERSION" ] || die "no release found for series $SERIES"
else
    VERSION="$WANT"
fi
case "$VERSION" in "$SERIES".*) ;; *) die "version $VERSION is not in series $SERIES" 2 ;; esac
MAJOR="${VERSION%%.*}"
TARBALL="linux-$VERSION.tar.xz"
echo "build.sh: kernel $VERSION"

# OCHNA-K1: download and verify
mkdir -p "$BUILD" "$OUT"
cd "$BUILD"
[ -f "$TARBALL" ] || curl -fsSL -o "$TARBALL" "https://cdn.kernel.org/pub/linux/kernel/v$MAJOR.x/$TARBALL"
curl -fsSL -o sha256sums.asc "https://cdn.kernel.org/pub/linux/kernel/v$MAJOR.x/sha256sums.asc"
grep -E "  $TARBALL\$" sha256sums.asc | sha256sum -c - || die "sha256 mismatch: $TARBALL"

# OCHNA-K1: unpack and configure
rm -rf "linux-$VERSION"
tar xJf "$TARBALL"
cd "linux-$VERSION"
cp "$HERE/config/ubuntu-26.04.config" .config
./scripts/kconfig/merge_config.sh -m .config "$HERE/config/ochna.fragment" >/dev/null
make olddefconfig >/dev/null
# OCHNA-K1: fail early if the fragment did not survive olddefconfig
for k in 'CONFIG_LOCALVERSION="-ochna"' 'CONFIG_RUST=y' 'CONFIG_DEBUG_INFO_BTF=y' 'CONFIG_DEBUG_INFO_BTF_MODULES=y' 'CONFIG_DEBUG_INFO_COMPRESSED_ZSTD=y'; do
    grep -qxF "$k" .config || die "fragment not applied: $k"
done

# OCHNA-K1: build packages
# OCHNA-K5: neutral build identity in uname -v and package metadata
# OCHNA-K6: skip the linux-image-*-dbg package
export DEB_BUILD_PROFILES=pkg.linux-upstream.nokerneldbg
export KBUILD_BUILD_USER=ochna KBUILD_BUILD_HOST=ochna-os DEBFULLNAME=OchnaOS DEBEMAIL=noreply@ochna.invalid
make -j"$(nproc)" bindeb-pkg KDEB_PKGVERSION="$VERSION-1ochna" >/dev/null
cd "$BUILD"
rm -f "$OUT"/*.deb "$OUT"/SHA256SUMS
cp linux-image-"$VERSION"-ochna_*.deb linux-headers-"$VERSION"-ochna_*.deb "$OUT"/ \
    || die "expected packages not found"
(cd "$OUT" && sha256sum ./*.deb > SHA256SUMS)
echo "build.sh: done"
ls -la "$OUT"
