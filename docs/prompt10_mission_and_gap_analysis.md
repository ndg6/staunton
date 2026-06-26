# Prompt 10 — mission statement & gap analysis

> Status: **discussion / orientation (no code).** Captures the renewed mission
> from `prompts/prompt_10__revamp_staunton.txt` and maps it against the current
> codebase, to frame the reshaping prompts that follow. No design is locked here.

## The vision, restated

Staunton is reframed from "a chess board/diagram renderer" into a **chess
*publishing* toolkit**: from a PGN (or programmatic input) to a typeset chess
article. Four pillars:

1. **Visual representation** — positions → boards → captioned `#figure` diagrams
   (labels, captions, treated as Typst figures).
2. **Move text as printed text** — moves rendered as notation/prose, localizable,
   with annotations, comments, and embedded diagram-printing instructions.
3. **Tables for multi-game PGNs** — cross tables and progress tables.
4. **Chess-aware structure** — outlines for diagrams *and* tables, with i18n.

Cross-cutting **dual-mode principle**: everything works both *fully automatically
from an unaltered PGN* and *programmatically / free-form* after a game is read.
Free-form overlays (arrows, highlights, what-if lines) must **never mutate the
source PGN** — use functions instead.

## Where the code stands against each pillar

| Pillar | State | Notes |
|--------|-------|-------|
| 1. Visual / diagrams | **Mature** | `board` / `chess-diagram` / `fen-diagram` / `board-after`; 3 label modes; piece sets + glyph fallback; flip; arrows; highlights; provenance-aware captions; `kind: "chess"` figures + `chess-outline`. Current centre of gravity. |
| 2. Move text printing | **Barely started — biggest gap** | Only `mainline` (raw SAN array) and `move-san` exist. No numbered movetext, no variation/NAG/comment rendering, no localized notation, no figurine option, no "emit diagram here" directive. `assets/i18n/piece-chars` is the seed; nothing consumes it yet. |
| 3. Multi-game tables | **Not started** | `parse-pgn` returns an array of games (tags + result + lazy engine) — the right substrate. Needs a new layer: collection/tournament model, player-identity normalization, scoring, tie-breaks, results matrix. |
| 4. Chess-aware outlines | **Half-built** | `chess-outline` covers diagrams via the distinct figure kind. Tables need their own kind (or wrapper) to be separately outline-able; outline titles/terms need i18n. |

## The dual-mode principle is already in our DNA

Not aspirational — a pattern we extend:

- **Automated from PGN**: `board-after` auto-pulls `%cal` / `%csl` from comments.
- **Programmatic / free-form**: `arrows:` / `highlight:` params; `line()` for
  what-if continuations that never touch the source game.

Pillar 2's movetext printing should follow the same split: auto-render
annotations/comments from the PGN, *and* offer functions to inject diagrams /
emphasis programmatically.

## Differentiation from boards-n-pieces

boards-n-pieces is essentially an excellent **board/position renderer** (FEN,
piece sets, simple drawing). Staunton's distinct bet is the **publishing pipeline
on a real game model**: a pure-Typst legal-move engine + parsed game tree (with
variations) + two-phase (lazy-engine) PGN parsing. That substrate unlocks what a
pure renderer cannot easily do — *printed* localized move text with annotations,
multi-game cross/progress tables, and chess-aware figure + table outlines.

The differentiator is **"from a PGN to a typeset chess article,"** not "from a
FEN to a pretty board." The engine and game tree are the assets that make pillars
2–4 feasible.

## Design tensions to seed later prompts (open, not decided)

- **Diagram-printing instructions from the PGN.** Implies a directive embedded in
  PGN comments (kin to `%cal`) meaning "emit a diagram at this move." Couples
  movetext printing to diagram emission. Needs a syntax decision (reuse a
  `%`-command? a NAG?) and an automated-vs-opt-in policy.
- **A "game collection" abstraction.** Pillars 3–4 want something above a single
  `game` — a tournament/collection with normalized player identities. Decide
  early whether that is a new top-level type.
- **i18n surface.** `piece-chars` is one slice; movetext also needs result words,
  "to play" / "after move" phrasing, table headers, and a language-selection
  mechanism (`#set text(lang:)` vs an explicit argument). Already on the README
  roadmap.
- **Figurine vs letter notation.** Pillar 2 likely wants both localized letters
  (the i18n table) *and* Unicode figurine glyphs as a rendering option.

## Suggested order of attack (recommendation only)

Pillar 1 is solid ground. Tackle **pillar 2 (movetext printing)** first — tables
(3) and richer outlines (4) lean on a solid move-rendering layer. Then the
collection model (3), then table-aware outlines + i18n (4). Each in the
hand-in-hand-with-tests style; await the specific reshaping prompts before
locking any design.
