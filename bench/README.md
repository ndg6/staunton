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
- `realworld_bulletin.typ` — diagram-DENSE workload (prompt 37): three long
  games (216/217/160 plies) with a diagram every 8 plies → ~75 distinct
  diagrams. Drives the second document-level differential in `run-bench.sh`;
  the "real document with many diagrams" target for drawing optimisations.
- `trace_one.typ` — single game, the tractable `--timings` target.

## Measurement discipline (read before trusting a delta)

Absolute ms on this box are noisy (see prompt 32 §7). Two rules keep a
before/after comparison honest:

1. **Take the min of several repeats** (`-k`), and compare runs captured
   back-to-back, not across sessions — background load drifts.
2. **Use an unaffected control as a live noise gauge.** Pick a measurement the
   change *cannot* affect and watch how much IT drifts between the two trees.
   Example (prompt 37, evaluating an assert-message optimisation): the
   `notation-only` twin draws no boards, so a board-side change can't touch it —
   yet it drifted +7% between runs, which is *larger* than the ~single-digit-%
   effect being measured. Verdict: the box wasn't quiet enough to resolve the
   signal, and the one low sample that looked like a win was noise. If your
   control drifts as much as your effect, **do not report the delta** — quiet
   the box or raise `-k` until the control is stable, and never treat a single
   low reading as a win.

## Findings

- Phase 0 (where the time goes; WASM verdict):
  `../prompts/llm_discussions/archive/prompt32_perf_wasm_findings.md`.
- Drawing optimisations A+C+D (memoised checker, fast square parsing, gated
  in-check) and the B/E/F verdicts:
  `../prompts/llm_discussions/prompt37_drawing_perf_discussion.md`.
