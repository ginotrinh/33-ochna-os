#!/usr/bin/env bash
# OCHNA-D1: build one COSMIC component as .deb from its pinned commit, with desktop/patches/<name>/*.patch.
# Usage: desktop/build.sh <component>     (run as root in an ubuntu:26.04 container)
# Output: out/desktop/<component>/*.deb
# Exit: 0 built | 1 fetch, patch or build failure | 2 usage
set -euo pipefail
export LC_ALL=C.UTF-8 DEBIAN_FRONTEND=noninteractive

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/.." && pwd)"
NAME="${1:?usage: desktop/build.sh <component>}"
SHA="$(awk -v n="$NAME" '$1==n {print $2}' "$HERE/components.txt")"
[ -n "$SHA" ] || { echo "desktop/build.sh: $NAME not in components.txt" >&2; exit 2; }
WORK="$ROOT/build/desktop/$NAME"
OUT="$ROOT/out/desktop/$NAME"

die() { echo "desktop/build.sh: $1" >&2; exit 1; }

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK" "$OUT"
cd "$WORK"

# OCHNA-D1: source at the pinned commit
git init -q src
git -C src remote add origin "https://github.com/pop-os/$NAME"
git -C src fetch -q --depth 1 origin "$SHA" || die "fetch $NAME $SHA"
git -C src checkout -q FETCH_HEAD
[ -d src/debian ] || die "$NAME has no debian/ directory"

# OCHNA-D1: OchnaOS patches, in name order
if [ -d "$HERE/patches/$NAME" ]; then
    for p in "$HERE/patches/$NAME"/*.patch; do
        [ -e "$p" ] || continue
        git -C src apply "$p" || die "patch $(basename "$p")"
        echo "desktop/build.sh: applied $(basename "$p")"
    done
fi

# OCHNA-D1: build dependencies from debian/control, vendored Rust crates, then the packages
cd src
apt-get build-dep -y -qq . >/dev/null
if [ -f justfile ] && grep -qE '^vendor' justfile; then
    just vendor >/dev/null
fi
dpkg-buildpackage -b -uc -us >/dev/null || die "dpkg-buildpackage $NAME"
cd ..
cp ./*.deb "$OUT"/ || die "no .deb produced for $NAME"
ls -la "$OUT"
