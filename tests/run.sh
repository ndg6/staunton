#!/usr/bin/env bash
# staunton test runner.
#
# Walks tests/**/*.typ and classifies each file by a header line:
#   * a file WITH  "// EXPECT: <substr>"  is an EXPECTED-FAIL test: it must error
#     (exit != 0) AND the error message must contain <substr>.
#   * a file WITHOUT it is an EXPECTED-PASS test: it must compile (exit 0). Its
#     output is KEPT under tests/out/, mirroring the path below tests/ (so a
#     visual sheet at tests/board/size/sizes.typ lands at
#     tests/out/board/size/sizes.pdf for eyeballing).
#
# Files and directories whose name starts with "_" are skipped (shared fixtures
# and helpers, e.g. tests/board/_fixture.typ).
#
# Output-format tests live under tests/output_formats/ and are NOT compiled to PDF
# by the walk above. Currently tests/output_formats/html/*.typ are compiled with
# Typst's HTML export (`--features html --format html`) and asserted on the
# generated HTML via header directives (each may repeat):
#   * "// HTML-HAS:  <substr>"   -> the HTML must contain <substr>
#   * "// HTML-LACKS: <substr>"  -> the HTML must NOT contain <substr>
# (Future SVG/PNG passes would slot in beside the html/ subdir the same way.)
#
# Usage:  bash tests/run.sh [-t|--time] [PATH ...]
#   -t, --time   show per-test compile time and a slowest-tests summary
#                (can also be enabled with STAUNTON_TIME=1)
#   PATH ...     optional path filter(s) — files or directories under tests/.
#                When given, this is a FOCUSED run: only tests under those paths
#                are run, and the examples pass is skipped. See tests/TESTING_MAP.md
#                for which clusters are independent (e.g. a fen/engine change needs
#                only  bash tests/run.sh tests/fen tests/position tests/pgn ).
#                A focused run is a fast inner-loop check; the FULL run (no PATH)
#                stays the pre-commit gate — it can catch cross-cutting regressions
#                a single cluster misses.
# The total wall-clock time is always reported.
set -u

TIME=${STAUNTON_TIME:-0}
FILTERS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -t|--time) TIME=1 ;;
    -h|--help) echo "usage: bash tests/run.sh [-t|--time] [PATH ...]"; exit 0 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *)
      if [ -e "$1" ]; then FILTERS+=("$1")
      else echo "no such test path: $1" >&2; exit 2; fi ;;
  esac
  shift
done
FOCUSED=0
[ ${#FILTERS[@]} -gt 0 ] && FOCUSED=1

cd "$(dirname "$0")/.."
ROOT="."
OUT="tests/out"
TMP="$OUT/_tmp.pdf"
mkdir -p "$OUT"
pass=0
fail=0
compile_ms=0          # summed compile time across all tests
durations=()          # "<ms>\t<file>" lines, for the slowest-tests summary

# Milliseconds since epoch (coreutils date supports %N / %3N under Git Bash).
now_ms() { date +%s%3N; }

# Record a test's compile time and return the inline annotation (if timing on).
note_time() { # $1 = ms, $2 = file
  compile_ms=$((compile_ms + $1))
  durations+=("$1	$2")
  if [ "$TIME" = "1" ]; then printf '  [%5d ms]' "$1"; fi
}

# Expected-pass: must compile; keep the PDF mirrored under tests/out.
ok() {
  local f="$1"
  local rel="${f#tests/}"          # path below tests/
  local dest="$OUT/${rel%.typ}.pdf"
  mkdir -p "${dest%/*}"            # builtin param-expansion, no `dirname` fork
  local t0 t1
  t0=$(now_ms)
  typst compile --root "$ROOT" "$f" "$dest" >/dev/null 2>&1
  local code=$?
  t1=$(now_ms)
  if [ $code -eq 0 ]; then
    printf '  ok   %s  -> %s' "$f" "$dest"; note_time $((t1 - t0)) "$f"; echo
    pass=$((pass + 1))
  else
    printf '  FAIL %s  (expected to compile, but it errored)' "$f"; note_time $((t1 - t0)) "$f"; echo
    fail=$((fail + 1))
  fi
}

# Expected-fail: must error and the message must contain `want` (the EXPECT
# substring, extracted by the caller). `want` is passed in to avoid re-reading.
err() {
  local f="$1"
  local want="$2"
  local out t0 t1
  t0=$(now_ms)
  out=$(typst compile --root "$ROOT" "$f" "$TMP" 2>&1)
  local code=$?
  t1=$(now_ms)
  if [ $code -eq 0 ]; then
    printf '  FAIL %s  (expected an error, but it compiled)' "$f"; note_time $((t1 - t0)) "$f"; echo
    fail=$((fail + 1))
  elif [ -n "$want" ] && ! printf '%s' "$out" | grep -qF "$want"; then
    printf '  FAIL %s  (errored, but message lacked: "%s")' "$f" "$want"; note_time $((t1 - t0)) "$f"; echo
    fail=$((fail + 1))
  else
    printf '  ok   %s  (errored as expected: "%s")' "$f" "$want"; note_time $((t1 - t0)) "$f"; echo
    pass=$((pass + 1))
  fi
}

# Read a file's "// EXPECT: <substr>" header using only bash builtins (no fork).
# Sets the global `want` to the substring, or "" if the file has no EXPECT line.
read_expect() {
  want=""
  local line
  while IFS= read -r line; do
    case "$line" in
      "// EXPECT:"*)
        want="${line#// EXPECT:}"
        want="${want#"${want%%[![:space:]]*}"}"   # strip leading whitespace
        break ;;
    esac
  done < "$1"
}

# Read "// HTML-HAS: <substr>" / "// HTML-LACKS: <substr>" header lines (each may
# repeat) into the global arrays `has` / `lacks`. `has` substrings must appear in
# the generated HTML, `lacks` substrings must not.
read_html_checks() {
  has=(); lacks=()
  local line s
  while IFS= read -r line; do
    case "$line" in
      "// HTML-HAS:"*)   s="${line#// HTML-HAS:}";   has+=("${s#"${s%%[![:space:]]*}"}") ;;
      "// HTML-LACKS:"*) s="${line#// HTML-LACKS:}"; lacks+=("${s#"${s%%[![:space:]]*}"}") ;;
    esac
  done < "$1"
}

# HTML output test: must compile under Typst's HTML export, and the generated HTML
# must contain every HTML-HAS substring and none of the HTML-LACKS ones.
html_test() {
  local f="$1"
  local rel="${f#tests/}"
  local dest="$OUT/${rel%.typ}.html"
  mkdir -p "${dest%/*}"
  read_html_checks "$f"
  local t0 t1 code
  t0=$(now_ms)
  typst compile --root "$ROOT" --features html --format html "$f" "$dest" >/dev/null 2>&1
  code=$?
  t1=$(now_ms)
  if [ $code -ne 0 ]; then
    printf '  FAIL %s  (expected HTML compile, but it errored)' "$f"; note_time $((t1 - t0)) "$f"; echo
    fail=$((fail + 1)); return
  fi
  local problem="" s
  for s in "${has[@]:-}"; do
    [ -z "$s" ] && continue
    grep -qF -- "$s" "$dest" || problem="missing \"$s\""
  done
  for s in "${lacks[@]:-}"; do
    [ -z "$s" ] && continue
    if grep -qF -- "$s" "$dest"; then problem="forbidden \"$s\" present"; fi
  done
  if [ -n "$problem" ]; then
    printf '  FAIL %s  (HTML %s)' "$f" "$problem"; note_time $((t1 - t0)) "$f"; echo
    fail=$((fail + 1))
  else
    printf '  ok   %s  -> %s' "$f" "$dest"; note_time $((t1 - t0)) "$f"; echo
    pass=$((pass + 1))
  fi
}

wall0=$(now_ms)

# Walk every .typ under the requested roots (default: all of tests/), skipping
# any path component starting with "_". A focused run narrows the roots to the
# given PATH filter(s).
WALK_ROOTS=(tests)
[ $FOCUSED -eq 1 ] && WALK_ROOTS=("${FILTERS[@]}")
echo "== tests =="
while IFS= read -r f; do
  case "$f" in
    */_*) continue ;;          # skip _-prefixed files / dirs
    tests/output_formats/*) continue ;;   # handled by the output-format passes below
  esac
  read_expect "$f"             # sets `want`
  if [ -n "$want" ]; then
    err "$f" "$want"
  else
    ok "$f"
  fi
done < <(find "${WALK_ROOTS[@]}" -name '*.typ' | sort)

# Examples are showcases, not tests, but they must still compile. Skipped on a
# focused run (they are cross-cutting, not part of any one cluster).
if [ $FOCUSED -eq 0 ]; then
  echo "== examples (must compile) =="
  for f in docs/examples/*.typ; do
    [ -e "$f" ] || continue
    ok "$f"
  done
fi

# Output-format tests. HTML: compiled with Typst's experimental HTML export and
# checked for the expected native-HTML / inline-SVG output (see the HTML-HAS /
# HTML-LACKS headers). Future SVG/PNG passes would slot in the same way. On a
# focused run these run only when a PATH filter points into tests/output_formats.
HTML_ROOTS=()
if [ $FOCUSED -eq 0 ]; then
  [ -d tests/output_formats/html ] && HTML_ROOTS=(tests/output_formats/html)
else
  for p in "${FILTERS[@]}"; do
    case "$p" in tests/output_formats*) HTML_ROOTS+=("$p") ;; esac
  done
fi
if [ ${#HTML_ROOTS[@]} -gt 0 ]; then
  echo "== HTML output tests =="
  while IFS= read -r f; do
    case "$f" in */_*) continue ;; esac
    html_test "$f"
  done < <(find "${HTML_ROOTS[@]}" -name '*.typ' | sort)
fi

rm -f "$TMP"
wall1=$(now_ms)

if [ "$TIME" = "1" ]; then
  echo "----------------------------------------"
  echo "slowest:"
  printf '%s\n' "${durations[@]}" | sort -rn | head -5 | while IFS=$'\t' read -r ms file; do
    printf '  %6d ms  %s\n' "$ms" "$file"
  done
fi

echo "----------------------------------------"
total=$((pass + fail))
printf 'passed=%d  failed=%d  (%d tests)\n' "$pass" "$fail" "$total"
printf 'compile time=%d ms   wall time=%d ms\n' "$compile_ms" "$((wall1 - wall0))"
if [ $FOCUSED -eq 1 ]; then
  printf 'FOCUSED run: %s  (examples skipped; run without a PATH for the full gate)\n' "${FILTERS[*]}"
fi
echo "Some sheets only RENDER (not asserted) -- before a release, eyeball the"
echo "PDFs under tests/out/ listed in tests/VISUAL_CHECKS.md."
[ $fail -eq 0 ]
