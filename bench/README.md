# Staunton performance bench (Phase 0)

Instrumentation for the prompt-32 question: *where does Staunton's compile time
actually go, and would a WASM plugin (à la board-n-pieces) make it faster?*

Typst has **no in-script clock**, so per-function cost is attributed two ways:

1. **Differential microbenchmarks** — `micro/*.typ`. Each runs its target
   operation `n` times (via `--input n=<count>`), with the loop body the only
   thing that scales with `n`. Per-call cost = `(T(n) − T(0)) / n`, so the fixed
   startup/font/import cost cancels. Inputs are varied per iteration to defeat
   Typst's memoisation (each file's header explains how).

2. **Engine timings trace** — `typst compile --timings` on `trace_one.typ`
   (one game; the full 9-game doc traces to ~600 MB). The Chrome-trace JSON
   splits engine time into `eval` vs. layout (`iter`) and exposes Typst
   func-call volume. Open it in <https://ui.perfetto.dev>.

## Run

```bash
bash bench/run-bench.sh          # microbenchmarks + end-to-end + trace
bash bench/run-bench.sh -k 5     # 5 repeats per point (min taken), less noise
```

Artifacts land in `bench/out/` (gitignored — regeneratable, and traces are huge).

## Fixtures

- `_fixture_game.pgn` — a single short real game, the microbench workload.
- `spassky_fischer_1972/` — the 9 decisive-by-play games of the 1972 World
  Championship match (draws and the game-2 forfeit excluded), exported from the
  lichess study <https://lichess.org/study/jtR7VzLj> as PGN. All 9 parse and
  replay legally in Staunton.
- `spassky_fischer.typ` — realistic 9-game bulletin (parse + replay + notation +
  drawing); the end-to-end workload.
- `trace_one.typ` — single game, the tractable `--timings` target.

## Findings

See `../prompts/llm_discussions/prompt32_perf_wasm_findings.md` for the Phase 0
results and the WASM decision-gate recommendation.
