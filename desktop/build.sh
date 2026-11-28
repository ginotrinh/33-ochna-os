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
GH_REPO="$(awk -v n="$NAME" '$1==n {print $3}' "$HERE/components.txt")"
GH_REPO="${GH_REPO:-pop-os/$NAME}"
[ -n "$SHA" ] || { echo "desktop/build.sh: $NAME not in components.txt" >&2; exit 2; }
WORK="$ROOT/build/desktop/$NAME"
OUT="$ROOT/out/desktop/$NAME"

die() { echo "desktop/build.sh: $1" >&2; exit 1; }

rm -rf "$WORK" "$OUT"
mkdir -p "$WORK" "$OUT"
cd "$WORK"

# OCHNA-D1: source at the pinned commit
git init -q src
git -C src remote add origin "https://github.com/$GH_REPO"
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

# OCHNA-D8: user-visible name ochna-aero instead of COSMIC in translations and desktop entry names;
# identifiers (DesktopNames, OnlyShowIn, Categories, X-COSMIC-*, COSMIC_*) stay
FTL_WORD='(^|[^A-Za-z0-9_])COSMIC([^A-Z0-9_]|$)'
DESKTOP_WORD='(^|[^A-Za-z0-9_-])COSMIC([^A-Za-z0-9_-]|$)'
rename_ftl() {
    find "$1" -type f -name '*.ftl' -print0 | xargs -0 -r sed -i -E ":a; s/$FTL_WORD/\1ochna-aero\2/; ta"
}
rename_left() {
    grep -rIE --include='*.ftl' "$FTL_WORD" "$1" 2>/dev/null | grep -c . || true
}
rename_ftl src
find src -type f \( -name '*.desktop' -o -name '*.desktop.in' -o -name '*.desktop.in.in' \) -print0 \
    | xargs -0 -r sed -i -E "/^(Name|GenericName|Comment|Keywords)(\[[^]]*\])?=/ { :a; s/$DESKTOP_WORD/\1ochna-aero\2/; ta }"
echo "desktop/build.sh: COSMIC left in ftl: $(rename_left src), desktop names: $(grep -rIE --include='*.desktop' --include='*.desktop.in' --include='*.desktop.in.in' "^(Name|GenericName|Comment|Keywords).*$DESKTOP_WORD" src 2>/dev/null | grep -c . || true)"

# OCHNA-D2: components this one build-depends on are built first in the same job and installed
for dep in $(awk -v n="$NAME" '$1==n {for (i = 2; i <= NF; i++) print $i}' "$HERE/build-deps.txt"); do
    [ -d "$ROOT/out/desktop/$dep" ] || "$HERE/build.sh" "$dep"
    apt-get install -y -qq "$ROOT/out/desktop/$dep"/*.deb >/dev/null
done

# OCHNA-D1: build dependencies from debian/control, vendored Rust crates, then the packages
cd src
# OCHNA-D2: some justfiles read SOURCE_DATE_EPOCH; use the commit time for reproducible builds
SOURCE_DATE_EPOCH="$(git log -1 --format=%ct)"
export SOURCE_DATE_EPOCH
export SOURCE_GIT_HASH="$SHA"
apt-get build-dep -y -qq . >/dev/null
if [ -f justfile ] && grep -qE '^vendor' justfile; then
    just vendor >/dev/null
fi
# OCHNA-D8: same rename inside vendored crates; per-file checksums of changed crates are dropped so cargo accepts them
if [ -f vendor.tar ]; then
    mkdir ../vendor-x
    tar -C ../vendor-x -pxf vendor.tar
    for crate in $(grep -rlIE --include='*.ftl' "$FTL_WORD" ../vendor-x/vendor 2>/dev/null | cut -d/ -f4 | sort -u); do
        rename_ftl "../vendor-x/vendor/$crate"
        sed -i -E 's/"files":\{[^}]*\}/"files":{}/' "../vendor-x/vendor/$crate/.cargo-checksum.json"
        echo "desktop/build.sh: renamed in vendored crate $crate"
    done
    echo "desktop/build.sh: COSMIC left in vendored ftl: $(rename_left ../vendor-x/vendor)"
    tar -C ../vendor-x -pcf vendor.tar .cargo vendor
    rm -rf ../vendor-x
fi
dpkg-buildpackage -b -uc -us >/dev/null || die "dpkg-buildpackage $NAME"
cd ..
cp ./*.deb "$OUT"/ || die "no .deb produced for $NAME"
ls -la "$OUT"
