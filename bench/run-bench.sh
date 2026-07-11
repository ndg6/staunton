#!/usr/bin/env bash
# Phase 0 performance baseline driver for Staunton.
#
# Answers the prompt-32 question honestly, before any WASM work: WHERE does the
# compile time actually go — parsing, move generation, SAN replay, or board
# drawing? Typst has no in-script clock, so we attribute cost two ways:
#
#   1. Differential microbenchmarks (bench/micro/*.typ). Each does its target
#      operation `n` times with the loop body as the ONLY thing that scales with
#      n. We time the doc at n=0 (fixed cost: startup + fonts + import + read)
#      and at n=N, and report per-call = (T(N) - T(0)) / N. Inputs are varied
#      per iteration to defeat Typst's memoisation (see each micro's header).
#      We take the MIN of several repeats to reject scheduler noise.
#
#   2. A realistic end-to-end doc (bench/spassky_fischer.typ) compiled with
#      `typst compile --timings`, whose Chrome-trace JSON splits engine time
#      into evaluation vs. layout — i.e. "parsing vs. drawing" at the engine
#      level. Open the JSON in https://ui.perfetto.dev or chrome://tracing.
#
# Usage:  bash bench/run-bench.sh [-k REPEATS]
set -u
cd "$(dirname "$0")/.."          # project root

REPEATS=3
while [ $# -gt 0 ]; do
  case "$1" in
    -k) REPEATS=$2; shift ;;
    -h|--help) echo "usage: bash bench/run-bench.sh [-k REPEATS]"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
  shift
done

ROOT="."
OUT="bench/out"
mkdir -p "$OUT"
now_ms() { date +%s%3N; }

# Min wall-time (ms) over $REPEATS compiles of $1 at --input n=$2.
min_ms() { # $1=file $2=n  -> echoes min ms
  local file="$1" n="$2" best="" t0 t1 dt k
  for ((k = 0; k < REPEATS; k++)); do
    t0=$(now_ms)
    typst compile --input "n=$n" --root "$ROOT" "$file" "$OUT/_bench.pdf" >/dev/null 2>&1
    t1=$(now_ms)
    dt=$((t1 - t0))
    if [ -z "$best" ] || [ "$dt" -lt "$best" ]; then best=$dt; fi
  done
  echo "$best"
}

# Micro definitions:  name  file  N.  N is chosen so the SIGNAL (per-call x N)
# dwarfs the ~1.2 s per-process startup jitter that the differential subtracts
# out — the cheaper the op, the larger the N it needs. draw is smaller because
# each iteration emits a full page and is already ~10x costlier per call.
# draw's N must stay <= the fixture game's ply count (~80) so no board position
# repeats — a repeat would be a memoisation cache hit and deflate the figure.
MICROS=(
  "parse    bench/micro/parse.typ    3000"
  "movegen  bench/micro/movegen.typ  1500"
  "replay   bench/micro/replay.typ   1500"
  "draw     bench/micro/draw.typ       60"
)

echo "== Staunton Phase 0 microbenchmarks =="
echo "(min of $REPEATS repeats; per-call = (T(N) - T(0)) / N)"
printf '%-9s %5s %10s %10s %12s\n' "function" "N" "T(0) ms" "T(N) ms" "per-call"
printf -- '-%.0s' {1..52}; echo
for row in "${MICROS[@]}"; do
  # shellcheck disable=SC2086
  set -- $row
  name="$1"; file="$2"; N="$3"
  t0=$(min_ms "$file" 0)
  tn=$(min_ms "$file" "$N")
  # Format per-call = (T(N)-T(0))/N in awk (robust to noise). A non-positive
  # differential means startup jitter swamped the signal on this run: flag it
  # rather than print a bogus/negative figure, and suggest a larger N or more -k.
  awk -v n="$name" -v N="$N" -v t0="$t0" -v tn="$tn" 'BEGIN{
    d = tn - t0
    if (d <= 0) pc = "  noise (raise N/-k)"
    else        pc = sprintf("%9.2f ms", d / N)
    printf "%-9s %5d %10d %10d %s\n", n, N, t0, tn, pc
  }'
done
echo

# Document-level diagram differential — the AUTHORITATIVE drawing cost. Immune to
# the construction-memoisation trap that deflates the bare-board microbench:
# every diagram in the full doc is a distinct real position, so this measures
# real per-diagram cost. per-diagram = (T_full - T_notation-only) / diagram_count.
echo "== drawing cost (document-level differential) =="
NB="$OUT/_noboards.typ"
cat > "$NB" <<'TYP'
#import "/lib.typ": parse-pgn, mainline, notation
#set page(paper: "a4", margin: 2cm)
#set text(size: 10pt)
#let rounds = (1, 3, 5, 6, 8, 10, 11, 13, 21)
#let gf(r) = "/bench/spassky_fischer_1972/game_" + (if r < 10 {"0"} else {""}) + str(r) + ".pgn"
#for r in rounds {
  let game = parse-pgn(read(gf(r))).first()
  pagebreak(weak: true)
  heading(level: 2)[Game #r]
  block(notation(game))
}
TYP
t_note=$(min_ms "$NB" 0)
t_full=$(min_ms bench/spassky_fischer.typ 0)
# diagram count: every 10th ply plus the final, per game.
ndia=$(typst eval --root "$ROOT" --input x=1 \
  'import "/lib.typ": parse-pgn, mainline; (1,3,5,6,8,10,11,13,21).map(r => { let p = mainline(parse-pgn(read("/bench/spassky_fischer_1972/game_" + (if r < 10 {"0"} else {""}) + str(r) + ".pgn")).first()).len(); range(10, p, step: 10).len() + 1 }).sum()' 2>/dev/null)
[ -z "$ndia" ] && ndia="?"
echo "  notation only : ${t_note} ms"
echo "  full (+diagr) : ${t_full} ms   (${ndia} diagrams)"
awk -v a="$t_note" -v b="$t_full" -v n="$ndia" 'BEGIN{
  if (n=="?" || n+0==0) { print "  per-diagram   : n/a"; exit }
  d=b-a; if (d<=0) { print "  per-diagram   : noise (raise -k)"; exit }
  printf "  per-diagram   : %.0f ms   (drawing = %.0f%% of full-doc time)\n", d/n, 100*d/b
}'
rm -f "$NB"
echo

# End-to-end realistic doc: full 9-game bulletin, plain wall-clock total (the
# "how long does a real Staunton document take" number). No --timings here: the
# 9-game trace is ~600 MB and impractical to open.
echo "== end-to-end: bench/spassky_fischer.typ (9 games) =="
E2E_PDF="$OUT/spassky_fischer.pdf"
t0=$(now_ms)
typst compile --root "$ROOT" bench/spassky_fischer.typ "$E2E_PDF" >/dev/null 2>&1
code=$?
t1=$(now_ms)
if [ $code -eq 0 ]; then
  echo "  compiled in $((t1 - t0)) ms -> $E2E_PDF"
else
  echo "  FAILED to compile (exit $code)"
fi

# Engine timings trace from a SINGLE game (tractable size). The Chrome-trace JSON
# splits engine time into eval (produce content) vs. layout ("iter"), and its
# per-span self-time exposes Typst func-call volume.
echo "== timings trace: bench/trace_one.typ (1 game) =="
TRACE="$OUT/trace_one.timings.json"
typst compile --timings "$TRACE" --root "$ROOT" bench/trace_one.typ "$OUT/trace_one.pdf" >/dev/null 2>&1
if [ -f "$TRACE" ]; then
  echo "  trace -> $TRACE  ($(wc -c < "$TRACE") bytes; open in https://ui.perfetto.dev)"
else
  echo "  FAILED to produce trace"
fi

rm -f "$OUT/_bench.pdf"
