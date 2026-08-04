# Test map — which areas are independent, and what to run

`tests/run.sh` accepts optional path filters for a **focused run**:

```sh
bash tests/run.sh tests/fen tests/position tests/pgn   # a cluster, ~20-60s
bash tests/run.sh                                       # FULL run, the gate
```

A focused run skips the examples pass and only runs the given paths. It is the
fast inner loop; the **full run stays the pre-commit gate** because it also
catches cross-cutting regressions (integration + examples) a single cluster can
miss.

## The dependency DAG

Modules form a DAG (`X → Y` = X imports Y). Tests import from `/lib.typ`, which
sits on top of everything.

```
BASE (used almost everywhere):   coords   pieces   variants   style*
MID  (the move/position stack):  fen → engine → san → game ← pgn
LEAF (nothing imports them):     board   notation   tournament   i18n   annotations
```

`* style` is base-ish: imported by `board`, `i18n`, `tournament`, `notation`.

Key fact: **`board.typ` and the move stack (`fen`/`engine`/`san`/`game`/`pgn`/
`notation`) never import each other.** They meet only at the `lib.typ` wrappers
and the shared base — so board rendering is genuinely orthogonal to move/PGN
handling.

## Independent clusters

Each cluster owns its upper-layer modules and is blind to the others' (above the
shared base). A change confined to one cluster's modules cannot cause a
regression visible only in another.

| Cluster | Owns | Run |
|---|---|---|
| **A · Board rendering** | `board`, style options | `tests/board` |
| **B · Rules / position** | `fen`, `engine`, `san` | `tests/fen tests/position tests/pgn/san tests/pgn/moves` |
| **C · PGN text & notation** | `pgn`, `game`, `notation`, `annotations` | `tests/pgn tests/notation tests/game` |
| **D · Tournament tables** | `tournament` | `tests/tournament` |
| **E · i18n** | `i18n` | `tests/i18n` |

B and C are not independent of *each other* (C sits on B via `game`), but B+C
together are independent of A/D/E. Tournament (D) works off PGN tags/results only
(`tournament.typ` imports just `style`) — it never touches the move engine.

## Two traps (do not treat as pure "rendering")

1. **`tests/diagram` is NOT pure board rendering** — it uses `diagram(.., at: ..)`,
   which replays moves through `game`/`engine`/`san`/`pgn`. It belongs with C.
   `tests/board` is mostly pure rendering, but not entirely: `board`/`diagram`
   handed a *game* with `at:` derive that move's annotations and quality badge
   via `move-at` (in `game.typ`) — a bare position (even one from the internal
   `_position-after`) has no such history. So a `game.typ` change can move what a
   **board** renders (when called with a game + `at:`), not just what a diagram
   does.
2. **`tests/output_formats` is cross-cutting integration** — HTML export exercises
   board + notation + tournament + figures at once. Run it for any render/
   notation/data change (`bash tests/run.sh tests/output_formats`), and always in
   the full gate.

## Reverse map — "I changed module X, run…"

| Changed module | Run (focused) |
|---|---|
| `board.typ` | `tests/board tests/output_formats` |
| `style.typ` | `tests/board tests/tournament tests/notation tests/i18n tests/output_formats` |
| `fen.typ` / `engine.typ` / `san.typ` | `tests/fen tests/position tests/pgn tests/notation tests/diagram` |
| `pgn.typ` / `game.typ` | `tests/pgn tests/game tests/notation tests/tournament tests/diagram tests/board` |
| `notation.typ` / `annotations.typ` | `tests/notation tests/pgn tests/output_formats` |
| `tournament.typ` | `tests/tournament tests/output_formats` |
| `i18n.typ` | `tests/i18n tests/notation tests/diagram tests/output_formats` |
| `coords` / `pieces` / `variants` | **everything** (base layer) — full run |

When in doubt, run the full suite. The focused runs are for tight iteration, not
for the final green before a commit.
