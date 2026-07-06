#!/usr/bin/env bash
# Rebuild the compiled user manual from docs/manual.typ (the canonical source).
#
# docs/manual.pdf is a build artifact: it is gitignored (not tracked) and is
# published as a GitHub Release asset at release time, not committed. Run this
# after editing the manual to preview locally, and at release time to produce
# the PDF to upload (see RELEASING.md).
#
# Usage:  bash scripts/build-manual.sh
set -eu
cd "$(dirname "$0")/.."
typst compile --root . docs/manual.typ docs/manual.pdf
echo "Rebuilt docs/manual.pdf"
