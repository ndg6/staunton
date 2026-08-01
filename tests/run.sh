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
# Each test file is an INDEPENDENT `typst compile`, so the suite is embarrassingly
# parallel: files are dispatched across N worker processes (default: one per CPU).
# The wall-clock win is large because most of a single compile is fixed per-process
# overhead (interpreter start + font scan). Per-test output is collected and
# printed sorted by path, so a parallel run reads the same as a serial one.
#
# Fonts: by default the runner passes --ignore-system-fonts, which skips the slow
# (~1 s/compile) system-font scan. Fonts change only rendered glyphs, never compile
# success or the asserted HTML, so tests stay valid — but the KEPT visual sheets
# under tests/out/ then use fallback fonts. The RELEASE GATE run must pass
# --system-fonts so those sheets render with the real fonts for eyeballing.
#
# Usage:  bash tests/run.sh [-t|--time] [-j N|--jobs N] [--system-fonts] [PATH ...]
#   -t, --time      show per-test compile time and a slowest-tests summary
#                   (can also be enabled with STAUNTON_TIME=1)
#   -j, --jobs N    number of parallel worker processes (default: nproc, or 4;
#                   also settable with STAUNTON_JOBS=N). Use 1 to force serial.
#   --system-fonts  use real system fonts (slower); required for the release-gate
#                   run so the kept visual sheets render correctly for eyeballing.
#   PATH ...        optional path filter(s) — files or directories under tests/.
#                   When given, this is a FOCUSED run: only tests under those paths
#                   are run, and the examples pass is skipped. See tests/TESTING_MAP.md
#                   for which clusters are independent (e.g. a fen/engine change needs
#                   only  bash tests/run.sh tests/fen tests/position tests/pgn ).
#                   A focused run is a fast inner-loop check; the FULL run (no PATH)
#                   stays the pre-commit gate — it can catch cross-cutting regressions
#                   a single cluster misses.
# The total wall-clock time is always reported.
set -u

# Resolve an absolute path to THIS script so workers can re-invoke it after cd.
SELF="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"
cd "$(dirname "$0")/.."
ROOT="."
OUT="tests/out"
mkdir -p "$OUT"

# Milliseconds since epoch (coreutils date supports %N / %3N under Git Bash).
now_ms() { date +%s%3N; }

# Human-readable duration from milliseconds: "1m 07s" or "4.2s".
fmt_ms() { # $1 = ms
  local ms=$1 s=$(( $1 / 1000 ))
  if [ "$s" -ge 60 ]; then printf '%dm %02ds' $((s / 60)) $((s % 60))
  else printf '%d.%01ds' "$s" $(( (ms % 1000) / 100 )); fi
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

# ---- worker ---------------------------------------------------------------
# run_one FILE  ->  emits ONE tab-separated result record on stdout:
#     FILE <TAB> MS <TAB> OK(1/0) <TAB> HUMAN-LINE
# HUMAN-LINE is the exact text a serial run would print (leading marker
# included), minus any timing annotation, which the orchestrator appends. The
# record is a single short printf, so writes stay atomic across parallel workers.
run_one() {
  local f="$1" t0 t1 ms code ok human rel dest out
  # Skip the (slow, ~1s) system-font scan unless a release-gate run asked for it.
  # Fonts affect only rendered glyphs, not compile success or the asserted HTML,
  # so tests stay valid; the release gate re-runs with system fonts for eyeballing.
  local FF=""
  [ "${STAUNTON_IGNORE_FONTS:-1}" = "1" ] && FF="--ignore-system-fonts"
  case "$f" in
    tests/output_formats/html/*)                 # ---- HTML output test ----
      rel="${f#tests/}"; dest="$OUT/${rel%.typ}.html"
      mkdir -p "${dest%/*}"
      read_html_checks "$f"
      t0=$(now_ms)
      typst compile $FF --root "$ROOT" --features html --format html "$f" "$dest" >/dev/null 2>&1
      code=$?
      t1=$(now_ms); ms=$((t1 - t0))
      if [ $code -ne 0 ]; then
        ok=0; human="  FAIL $f  (expected HTML compile, but it errored)"
      else
        local problem="" s
        for s in "${has[@]:-}";   do [ -z "$s" ] && continue; grep -qF -- "$s" "$dest" || problem="missing \"$s\""; done
        for s in "${lacks[@]:-}"; do [ -z "$s" ] && continue; grep -qF -- "$s" "$dest" && problem="forbidden \"$s\" present"; done
        if [ -n "$problem" ]; then ok=0; human="  FAIL $f  (HTML $problem)"
        else                       ok=1; human="  ok   $f  -> $dest"; fi
      fi
      ;;
    *)
      read_expect "$f"                            # sets `want`
      if [ -n "$want" ]; then                     # ---- expected-fail test ----
        local tmp="$OUT/_tmp.$$.pdf"
        t0=$(now_ms)
        out=$(typst compile $FF --root "$ROOT" "$f" "$tmp" 2>&1)
        code=$?
        t1=$(now_ms); ms=$((t1 - t0)); rm -f "$tmp"
        if [ $code -eq 0 ]; then
          ok=0; human="  FAIL $f  (expected an error, but it compiled)"
        elif [ -n "$want" ] && ! printf '%s' "$out" | grep -qF "$want"; then
          ok=0; human="  FAIL $f  (errored, but message lacked: \"$want\")"
        else
          ok=1; human="  ok   $f  (errored as expected: \"$want\")"
        fi
      else                                        # ---- expected-pass test ----
        rel="${f#tests/}"; dest="$OUT/${rel%.typ}.pdf"
        mkdir -p "${dest%/*}"
        t0=$(now_ms)
        typst compile $FF --root "$ROOT" "$f" "$dest" >/dev/null 2>&1
        code=$?
        t1=$(now_ms); ms=$((t1 - t0))
        if [ $code -eq 0 ]; then ok=1; human="  ok   $f  -> $dest"
        else                     ok=0; human="  FAIL $f  (expected to compile, but it errored)"; fi
      fi
      ;;
  esac
  printf '%s\t%s\t%s\t%s\n' "$f" "$ms" "$ok" "$human"
}

# In worker mode we only run the single file and exit; the orchestrator below is
# skipped. (Invoked as: bash <self> --run-one <file>.)
if [ "${1:-}" = "--run-one" ]; then
  run_one "$2"
  exit 0
fi

# ---- orchestrator ---------------------------------------------------------
TIME=${STAUNTON_TIME:-0}
JOBS=${STAUNTON_JOBS:-}
FILTERS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -t|--time) TIME=1 ;;
    -j|--jobs) JOBS="$2"; shift ;;
    -j*)       JOBS="${1#-j}" ;;               # combined form, e.g. -j1
    --jobs=*)  JOBS="${1#--jobs=}" ;;
    --system-fonts) STAUNTON_IGNORE_FONTS=0 ;; # release gate: real fonts, slower
    -h|--help) echo "usage: bash tests/run.sh [-t|--time] [-j N|--jobs N] [--system-fonts] [PATH ...]"; exit 0 ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *)
      if [ -e "$1" ]; then FILTERS+=("$1")
      else echo "no such test path: $1" >&2; exit 2; fi ;;
  esac
  shift
done
[ -z "$JOBS" ] && JOBS=$(nproc 2>/dev/null || echo 4)
# Exported so the xargs worker processes inherit it. Default: ignore system fonts
# (fast). --system-fonts (or STAUNTON_IGNORE_FONTS=0) restores them for the gate.
export STAUNTON_IGNORE_FONTS=${STAUNTON_IGNORE_FONTS:-1}
FOCUSED=0
[ ${#FILTERS[@]} -gt 0 ] && FOCUSED=1

# Record the effective font mode in the OUTPUT, not just in the shell that ran
# it. The release preflight requires the gate to have used --system-fonts (the
# default --ignore-system-fonts renders visual sheets with fallback fonts), and
# release-auditor is handed only the captured log -- so without this line that
# requirement is unverifiable from the evidence, and the auditor can do nothing
# but take the orchestrator's word for it. (Found by the machinery audit,
# 2026-08-01: the auditor correctly reported it could not confirm the flag.)
if [ "$STAUNTON_IGNORE_FONTS" = "1" ]; then
  printf 'fonts: --ignore-system-fonts (fast; NOT valid for the release gate)\n'
else
  printf 'fonts: --system-fonts (real fonts; release-gate mode)\n'
fi

pass=0
fail=0
compile_ms=0                 # summed compile time across all tests
RESULTS=$(mktemp)            # collected worker records, for the final aggregation
trap 'rm -f "$RESULTS"' EXIT

# Dispatch a batch of files across JOBS workers, print the per-test lines sorted
# by path (so output is deterministic regardless of finish order), and append the
# raw records to $RESULTS for the end-of-run aggregation.
dispatch() { # $1 = header; remaining args = files
  local header="$1"; shift
  [ $# -eq 0 ] && return
  echo "$header"
  local batch; batch=$(mktemp)
  printf '%s\n' "$@" | xargs -P "$JOBS" -I{} bash "$SELF" --run-one {} >> "$batch"
  sort -t $'\t' -k1,1 "$batch" | while IFS=$'\t' read -r f ms ok human; do
    if [ "$TIME" = "1" ]; then printf '%s  [%5d ms]\n' "$human" "$ms"
    else printf '%s\n' "$human"; fi
  done
  cat "$batch" >> "$RESULTS"
  rm -f "$batch"
}

wall0=$(now_ms)

# Walk every .typ under the requested roots (default: all of tests/), skipping any
# path component starting with "_" and the output-format subtree (handled below).
WALK_ROOTS=(tests)
[ $FOCUSED -eq 1 ] && WALK_ROOTS=("${FILTERS[@]}")
TEST_FILES=()
while IFS= read -r f; do
  case "$f" in
    */_*) continue ;;
    tests/output_formats/*) continue ;;
  esac
  TEST_FILES+=("$f")
done < <(find "${WALK_ROOTS[@]}" -name '*.typ' | sort)
dispatch "== tests ==" "${TEST_FILES[@]:-}"

# Examples are showcases, not tests, but they must still compile. Skipped on a
# focused run (they are cross-cutting, not part of any one cluster).
if [ $FOCUSED -eq 0 ]; then
  EXAMPLE_FILES=()
  for f in docs/examples/*.typ; do [ -e "$f" ] && EXAMPLE_FILES+=("$f"); done
  dispatch "== examples (must compile) ==" "${EXAMPLE_FILES[@]:-}"
fi

# Output-format tests. HTML: compiled with Typst's experimental HTML export and
# checked for the expected native-HTML / inline-SVG output (see the HTML-HAS /
# HTML-LACKS headers). On a focused run these run only when a PATH filter points
# into tests/output_formats.
HTML_ROOTS=()
if [ $FOCUSED -eq 0 ]; then
  [ -d tests/output_formats/html ] && HTML_ROOTS=(tests/output_formats/html)
else
  for p in "${FILTERS[@]}"; do
    case "$p" in tests/output_formats*) HTML_ROOTS+=("$p") ;; esac
  done
fi
if [ ${#HTML_ROOTS[@]} -gt 0 ]; then
  HTML_FILES=()
  while IFS= read -r f; do
    case "$f" in */_*) continue ;; esac
    HTML_FILES+=("$f")
  done < <(find "${HTML_ROOTS[@]}" -name '*.typ' | sort)
  dispatch "== HTML output tests ==" "${HTML_FILES[@]:-}"
fi

wall1=$(now_ms)

# Aggregate pass/fail and compile time from the collected records.
while IFS=$'\t' read -r f ms ok human; do
  [ -z "${ok:-}" ] && continue
  compile_ms=$((compile_ms + ms))
  if [ "$ok" = "1" ]; then pass=$((pass + 1)); else fail=$((fail + 1)); fi
done < "$RESULTS"

if [ "$TIME" = "1" ]; then
  echo "----------------------------------------"
  echo "slowest:"
  # records are "FILE\tMS\tOK\tHUMAN"; sort by MS desc, show top 5.
  sort -t $'\t' -k2,2 -rn "$RESULTS" | head -5 | while IFS=$'\t' read -r f ms ok human; do
    printf '  %6d ms  %s\n' "$ms" "$f"
  done
fi

echo "----------------------------------------"
total=$((pass + fail))
printf 'passed=%d  failed=%d  (%d tests)\n' "$pass" "$fail" "$total"
wall_ms=$((wall1 - wall0))
printf 'execution time: %s  (wall %d ms; compile %d ms across %d jobs)\n' \
  "$(fmt_ms "$wall_ms")" "$wall_ms" "$compile_ms" "$JOBS"
if [ $FOCUSED -eq 1 ]; then
  printf 'FOCUSED run: %s  (examples skipped; run without a PATH for the full gate)\n' "${FILTERS[*]}"
fi
echo "Some sheets only RENDER (not asserted) -- before a release, eyeball the"
echo "PDFs under tests/out/ listed in tests/VISUAL_CHECKS.md."
[ $fail -eq 0 ]
