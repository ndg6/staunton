#!/usr/bin/env bash
# Assemble the publishable staunton bundle for a typst/packages submission.
#
# The bundle is built from a CLEAN `git archive` of HEAD -- i.e. only committed,
# tracked files -- so anything gitignored (the non-shipped piece sets, prompts/,
# CLAUDE.md, local PDFs) can never leak in. The manifest `exclude` globs are then
# removed, leaving exactly what Typst Universe would publish.
#
# Output:  dist/preview/<name>/<version>/...
# Copy that <name>/<version> directory into a fork of
# https://github.com/typst/packages under packages/preview/ to open the PR.
#
# Usage:  bash scripts/build-bundle.sh [-o OUTDIR]   (default OUTDIR=dist)
set -eu

OUTDIR="dist"
while [ $# -gt 0 ]; do
  case "$1" in
    -o|--out) OUTDIR="$2"; shift 2 ;;
    -h|--help) echo "usage: bash scripts/build-bundle.sh [-o OUTDIR]"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

cd "$(dirname "$0")/.."

# --- read name + version from the manifest ---------------------------------
manifest_field() { grep -E "^$1[[:space:]]*=" typst.toml | head -1 | sed -E 's/.*"([^"]*)".*/\1/'; }
NAME="$(manifest_field name)"
VERSION="$(manifest_field version)"
[ -n "$NAME" ] && [ -n "$VERSION" ] || { echo "could not read name/version from typst.toml" >&2; exit 1; }

DEST="$OUTDIR/preview/$NAME/$VERSION"
echo "Building $NAME:$VERSION -> $DEST"

# --- start from a clean export of tracked files ----------------------------
rm -rf "$DEST"
mkdir -p "$DEST"
git archive --format=tar HEAD | tar -x -C "$DEST"

# --- drop everything the published bundle must not contain -----------------
# (the `exclude` globs from typst.toml, plus repo-only dotfiles)
EXCLUDE="
tests
docs
scripts
prompts
CLAUDE.md
.github
.gitignore
.gitattributes
src/assets/piece_sets/_incomplete
"
for path in $EXCLUDE; do
  rm -rf "${DEST:?}/$path"
done

# --- sanity checks ----------------------------------------------------------
fail=0
for required in typst.toml lib.typ LICENSE LICENSE-PIECES README.md \
                src/assets/piece_sets/cburnett/wK.svg \
                src/assets/piece_sets/merida/wK.svg \
                src/assets/i18n/en.typ; do
  [ -e "$DEST/$required" ] || { echo "  MISSING: $required" >&2; fail=1; }
done
# these must NOT be present
for forbidden in tests docs prompts CLAUDE.md \
                 src/assets/piece_sets/_incomplete \
                 src/assets/piece_sets/staunty; do
  [ -e "$DEST/$forbidden" ] && { echo "  LEAKED:  $forbidden" >&2; fail=1; } || true
done
[ "$fail" -eq 0 ] || { echo "bundle verification FAILED" >&2; exit 1; }

# --- report -----------------------------------------------------------------
files=$(find "$DEST" -type f | wc -l | tr -d ' ')
size=$(du -sh "$DEST" | cut -f1)
echo "OK: $files files, $size"
echo "Verify it compiles standalone, e.g.:"
echo "  typst compile --root \"$DEST\" \"$DEST/lib.typ\" /dev/null  # (or a small import test)"
