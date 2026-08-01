#!/usr/bin/env bash
# Static drift checks for things no compiler catches.
#
# tests/run.sh proves the package and its docs COMPILE. That leaves a class of
# rot nothing notices: a comment naming a function that was renamed away, a
# checklist pointing at a test file that no longer exists, a helper nobody calls
# any more. Those ship silently. This script is the machine-checkable half of
# the cleanup pass -- the judgment half (is this prose still TRUE?) stays human.
#
# A STANDALONE tool, deliberately not wired into tests/run.sh: this is drift, not
# a regression, so it belongs in a cleanup pass or a pre-release check rather than
# the every-commit gate.
#
# Usage:  bash scripts/lint-docs.sh
#
# WHEN ADDING A CHECK: verify it by PLANTING a regression it should catch, then
# confirming it goes red. On this script's first draft, two of the three checks
# reported "clean" against deliberately broken input -- one from an awk suffix
# test that was accidentally true for any path of matching length, one because a
# renamed-away name still appeared in a lib.typ comment. A check that cannot fail
# looks identical to a check that passes.
#
# PERFORMANCE NOTE: every check is ONE grep pass plus in-process awk. The
# obvious shape -- a grep per symbol/token -- is O(items x tree) and took >5 min
# here, because process spawning under MSYS dominates everything else. Keep new
# checks single-pass; do the per-item work inside awk.
set -eu
cd "$(dirname "$0")/.."

# grep -P is unavailable under some locales here (it errors with "supports only
# unibyte and UTF-8 locales"), so every pattern below is POSIX/-E only.
export LC_ALL=C

fail=0
FINDINGS=$(mktemp)
trap 'rm -f "$FINDINGS"' EXIT

# run_check NAME CMD...  -- CMD prints one line per finding; empty output = pass.
run_check() {
  local name="$1"; shift
  printf '== %s ==\n' "$name"
  : > "$FINDINGS"
  "$@" > "$FINDINGS" || true
  if [ -s "$FINDINGS" ]; then sed 's/^/  /' "$FINDINGS"; fail=$((fail + 1)); fi
}

# Files worth searching: package + executable docs + tests, never generated output.
corpus_files() {
  find lib.typ src docs tests -type f \( -name '*.typ' -o -name '*.md' \) \
       -not -path 'tests/out/*' 2>/dev/null | sed 's|^\./||'
}

# ---------------------------------------------------------------------------
# 1. Referenced test paths must exist.
#    tests/TESTING_MAP.md and tests/VISUAL_CHECKS.md name sheets by hand. When a
#    test is renamed or retired, the reference silently dangles and the release
#    eyeball pass sends you to a file that is not there.
#    VISUAL_CHECKS.md names sheets by their RENDERED .pdf under tests/out/, so
#    both extensions resolve back to the .typ source. These files also use
#    shorthand -- bare module names in the dependency diagram (`fen.typ`), and a
#    path prefix carried over from the previous bullet
#    (`free_captions/free_captions.pdf` under a preceding `diagram/...`) -- so a
#    reference counts as resolved when ANY .typ in the repo ends with it. That is
#    still enough to catch a sheet renamed or retired outright.
# ---------------------------------------------------------------------------
check_paths() {
  local mds=""
  for m in tests/TESTING_MAP.md tests/VISUAL_CHECKS.md; do [ -e "$m" ] && mds="$mds $m"; done
  [ -n "$mds" ] || return 0
  # shellcheck disable=SC2086
  grep -HoE '[a-z0-9_]+(/[a-z0-9_]+)*\.(typ|pdf)' $mds \
    | awk -F: -v paths="$(corpus_files | tr '\n' ' ')" '
      BEGIN { n = split(paths, P, " ") }
      {
        ref = $2
        sub(/\.(typ|pdf)$/, ".typ", ref)
        if (seen[$1 "\t" ref]++) next
        for (i = 1; i <= n; i++) {
          if (P[i] == ref) next
          # true suffix test: index() returns 0 when absent, which coincides with
          # length(P)-length(ref) whenever a path happens to be exactly as long
          # as the reference -- that arithmetic form silently passed everything.
          if (length(P[i]) > length(ref) &&
              substr(P[i], length(P[i]) - length(ref)) == "/" ref) next
        }
        print "DANGLING [" $1 "]: " $2
      }'
}
run_check "referenced test paths exist" check_paths

# ---------------------------------------------------------------------------
# 2. README code fences may only call symbols the package still exports.
#    README.md is in NO compile gate (unlike docs/examples/ and the manual's
#    #example blocks) and is the package's front page on Typst Universe, so a
#    stale name here is both invisible and maximally public.
# ---------------------------------------------------------------------------
# Comments are stripped from lib.typ before building the "live names" set: a
# renamed-away function often lingers in a comment, and counting that as proof of
# life is exactly the drift this check exists to find (it let `#chess-diagram`
# through on the first try, because lib.typ still mentioned it in a comment).
#
# Typst markup builtins a README legitimately calls; extend if one is missing
# (a false positive here means "add it to this list", not "rename the API").
TYPST_BUILTINS="set show let import include context figure table text image
grid stack place box block page par heading link ref cite footnote columns
align pad move rotate scale hide repeat line rect circle ellipse polygon path
square strong emph underline overline strike sub super raw math lorem highlight
outline bibliography numbering counter state layout measure style locate label
list enum terms quote smartquote pagebreak colbreak linebreak parbreak v h
luma rgb cmyk oklab oklch color gradient tiling stroke calc str int float bool
array dict dictionary type repr panic assert eval read csv json yaml toml xml
datetime duration symbol if else for while return break continue none auto
true false"
# Fence tracking must toggle ONLY on a real delimiter: a line that is nothing but
# ``` plus an optional language tag. A bare /^```/ also fires on CONTENT, because
# staunton's own README embeds Typst raw blocks inside its Typst samples, and one
# of them closes with  ```).first()  -- a line that starts with backticks but is
# code, not a fence. That flipped the in/out parity for the whole rest of the
# file, so real code went unscanned (a planted `#chess-diagram` on the README's
# headline example passed clean) while prose was scanned as code.
#
# Found by the machinery audit, 2026-08-01. To re-verify this check after any
# change to it, plant the regression again and watch it fire:
#   sed -i '0,/^#diagram-after(opera/s//#chess-diagram(opera/' README.md
#   bash scripts/lint-docs.sh          # must report  UNKNOWN: #chess-diagram
#   git checkout -- README.md
# A check that cannot fail is indistinguishable from one that passes -- and this
# one silently could not, for its entire life before that audit.
check_readme() {
  [ -e README.md ] || return 0
  awk '/^```[A-Za-z0-9_-]*[[:space:]]*$/{f=!f; next} f' README.md \
    | grep -oE '#[a-z][a-z0-9-]*' \
    | awk -v builtins="$TYPST_BUILTINS" -v libids="$(sed 's|//.*||' lib.typ | grep -oE '[A-Za-z_][A-Za-z0-9_-]*' | sort -u | tr '\n' ' ')" '
      BEGIN {
        split(builtins, B, /[ \n]+/); for (i in B) ok[B[i]] = 1
        split(libids,   L, /[ \n]+/); for (i in L) ok[L[i]] = 1
      }
      { n = substr($0, 2)
        if (!(n in ok) && !seen[n]++)
          print "UNKNOWN: #" n "  (renamed away, or a builtin missing from TYPST_BUILTINS)" }'
}
run_check "README code fences use live API names" check_readme

# ---------------------------------------------------------------------------
# 3. No unreachable symbols in src/.
#    A top-level definition referenced neither outside its own file nor a second
#    time inside it is dead: not re-exported by lib.typ, not used by a sibling
#    module, not exercised by a test. Public API is safe by construction --
#    lib.typ's re-export list counts as an outside reference.
# ---------------------------------------------------------------------------
check_dead() {
  local defs tokens
  defs=$(mktemp); tokens=$(mktemp)
  # "file<TAB>name" for every top-level definition in src/
  grep -HoE '^#let [a-zA-Z_][a-zA-Z0-9_-]*' src/*.typ 2>/dev/null \
    | sed 's/:#let /\t/' | sort -u > "$defs"
  # "file<TAB>identifier" for every identifier in the corpus -- ONE grep for all
  # files (grep -H prints "file:match"; repo paths contain no colon).
  corpus_files | tr '\n' '\0' \
    | xargs -0 grep -HoE '[A-Za-z_][A-Za-z0-9_-]*' 2>/dev/null \
    | sed 's|:|\t|' > "$tokens"
  awk -F'\t' '
    NR == FNR { def[$2] = $1; next }
    $2 in def { if ($1 == def[$2]) self[$2]++; else other[$2]++ }
    END {
      for (n in def)
        if (!(n in other) && self[n] <= 1)
          print "UNREACHABLE: " def[n] " :: " n
    }
  ' "$defs" "$tokens" | sort
  rm -f "$defs" "$tokens"
}
run_check "no unreachable symbols in src/" check_dead

echo "----------------------------------------"
if [ "$fail" -eq 0 ]; then
  echo "lint-docs: clean"
else
  echo "lint-docs: $fail check(s) FAILED"
fi
[ "$fail" -eq 0 ]
