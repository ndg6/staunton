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
# Usage:  bash tests/run.sh [-t|--time]
#   -t, --time   show per-test compile time and a slowest-tests summary
#                (can also be enabled with STAUNTON_TIME=1)
# The total wall-clock time is always reported.
set -u

TIME=${STAUNTON_TIME:-0}
while [ $# -gt 0 ]; do
  case "$1" in
    -t|--time) TIME=1 ;;
    -h|--help) echo "usage: bash tests/run.sh [-t|--time]"; exit 0 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
  shift
done

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

wall0=$(now_ms)

# Walk every .typ under tests/, skipping any path component starting with "_".
echo "== tests =="
while IFS= read -r f; do
  case "$f" in
    */_*) continue ;;          # skip _-prefixed files / dirs
  esac
  read_expect "$f"             # sets `want`
  if [ -n "$want" ]; then
    err "$f" "$want"
  else
    ok "$f"
  fi
done < <(find tests -name '*.typ' | sort)

# Examples are showcases, not tests, but they must still compile.
echo "== examples (must compile) =="
for f in examples/*.typ; do
  [ -e "$f" ] || continue
  ok "$f"
done

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
[ $fail -eq 0 ]
