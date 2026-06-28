# Prompt 16 — chess tables (standings / cross-table / progress): design discussion

> Status: **implemented** — see "Implementation outcome" at the end. Source:
> `prompts/prompt_16__creating_chess_tables.txt`. Scope: tournament tables built
> from a parsed PGN's roster + results (no engine needed).

## What the sample data actually is

`tests/pgn/realworld/real_tournament.pgn`: **374 games across four divisions**
(the `Event` tag): `Jugend U16/U14` (105), `M2` (91), `Hauptturnier` (91), `M1`
(87). It is a **team league** (Mannschaftskampf): 21 teams, 108 players, every
game has `WhiteTeam`/`BlackTeam`. (Caveat discovered during implementation: this
file's `Round` tags do **not** follow clean `round.board` semantics and its
`Event` tags are inconsistent across rounds — see "Findings" below.)

Consequences:

- **Tables are computed per division** — the user filters games to one `Event`
  first (we provide a grouping helper).
- **Team is the natural entity**: within a division ~8 teams play a **round-robin
  over 7 rounds**, so a *team* cross-table is a real round-robin and *team*
  standings (match points + board points) are the headline. *Individual*
  standings are computable too, but an individual cross-table is **not** a
  round-robin (players don't all meet).

## Decisions (this session)

- **Entity: both `player` and `team`** via `by: "player" | "team"`.
- **Tables: standings + cross-table + progress.**
- **Tie-breaks: include Buchholz + Sonneborn-Berger** (configurable order).

## API (compute / render split)

Compute returns plain data (testable); render returns Typst `#table` content.

```
// compute
standings(games, by: "player", tiebreaks: auto) -> sorted array of records
crosstable(games, by: "team")                   -> (entities, matrix, totals)
progress(games, by: "team")                     -> per-entity per-round scores
// render
standings-table(games, ..)   crosstable-table(games, ..)   progress-table(games, ..)
// helper
games-by-event(games) -> (event-name: games, ...)   // split a multi-division file
```

`by` default `"player"`. The render fns call the compute fns; both are public so
a user can render custom layouts. Lives in a new `src/tournament.typ`,
re-exported from `lib`. Tables are variant-agnostic.

### Standings record

`(name, score, played, wins, draws, losses, buchholz, sonneborn-berger, …)`.
For `team` the primary `score` is **match points** with **board points** carried
alongside (a tie-break). Sorted by primary score desc, then the `tiebreaks`
sequence, then **first appearance** in the file ("first mentioned on top").

- **Result math:** `1-0`/`0-1`/`1/2-1/2` → 1 / 0.5 / 0; `*` skipped. Names/teams
  keyed by exact tag string.
- **Tie-breaks:** Sonneborn-Berger = Σ(opponent final score × your result vs
  them); Buchholz = Σ(opponents' final scores). Defaults: player →
  `(buchholz, sonneborn-berger)`; team → `(board-points, sonneborn-berger)`.

### Team aggregation

A **match** = the set of games in one major round between the same two teams
(group by major round + `{WhiteTeam, BlackTeam}`). Board points = Σ game results
per team; match points = 2/1/0 by board-point comparison (settable: win/draw/loss
values). Team standings use match points (primary) then board points then SB.

### Cross-table

Round-robin only. Entities × entities; cell (i, j) = `i`'s result vs `j` (player:
game score; team: the match board score like `4½:3½` or match points), diagonal
shaded, row total = score. If the chosen entity does **not** form a round-robin
(e.g. players in a Swiss/league), it errors with a clear message (use standings +
progress instead).

### Progress

Per entity, columns = major rounds, cells = that round's result and the running
cumulative score; final column = total. Needs `Round`. Works for open/Swiss too.

## Open questions / notes

- **Byes / forfeits / `*`**: skipped from result math in v1 (logged, not
  counted); revisit if the sample needs forfeit handling.
- **Direct-encounter tie-break**: deferred (Buchholz + SB first).
- **Multiple divisions**: handled by `games-by-event` + filtering, not auto-magic.
- **Localization of headers / styling**: minimal default headers in v1; styling
  via passthrough to `#table`. Header i18n can reuse the i18n seam later.
- **"outline"** (the user's separate later idea) is out of scope here.

## Test plan

- A small synthetic **round-robin** (4 players, all pairs) → standings order,
  SB/Buchholz values, and a full cross-table checked cell-by-cell.
- A small **Swiss/open** set → standings + progress correct; cross-table errors.
- **Team**: a 2-round, 2-match synthetic → match points, board points, team
  standings, team cross-table.
- `games-by-event` splits a multi-division list.
- Result math: `1-0`/`0-1`/`1/2-1/2`/`*`.
- A **rendering smoke test** over a real division from `real_tournament.pgn`
  (filtered by `Event`) — standings + progress + (team) cross-table compile.

## Implementation outcome

Shipped in `src/tournament.typ` (re-exported from `lib`), in three stages, all
tested:

- **Standings** — `standings(games, by:)` + `standings-table`. Sort = score desc,
  tie-breaks, first appearance. Tie-breaks Buchholz / Sonneborn-Berger / (team)
  board-points. Team mode groups games into matches via a shared `_team-matches`
  helper (major round + team pair; board points summed; match points 2/1/0).
- **Cross-table** — `crosstable` + `crosstable-table`; round-robin only (errors
  with a clear message otherwise). Rows in standings order, diagonal shaded.
- **Progress** — `progress` + `progress-table`; per-round result + running total.
- `games-by-event` splits a multi-division file.

### Findings on the sample data

`real_tournament.pgn` is a **four-division team league** whose `Round` tag does
**not** follow `round.board` semantics (a team appears against several opponents —
even itself — under the same major round), and whose `Event` tags are
inconsistent across rounds. So team grouping is unreliable on this specific file.
Two concrete consequences, both handled:

1. **Player standings are robust** (they only sum per player) — used for the
   real-data smoke test on a roster-only **M1 subset** (`tests/pgn/realworld/
   M1_roster.pgn`, 87 games).
2. ~~The full 848 KB file exceeds Typst's loop-iteration limit~~ — **fixed in two
   steps**: (a) `parse-pgn`'s tokenizer was rewritten to scan with one native
   regex (`str.matches`) instead of a char-by-char loop with O(n²) string
   building; (b) movetext parsing was made **lazy** (see below). The full file
   now parses in ~2 s; see `tests/pgn/realworld/parse_full.typ`.

Team tables are validated on **synthetic** clean `round.board` fixtures.

### Follow-up: lazy movetext (PGN parse performance)

Profiling the 848 KB file showed the tokenizer was *not* the bottleneck (~2 s);
the ~75 s cost was building the move TREE for **all 375 games' movetext** —
wasted whenever a caller only wants the roster (standings/cross-tables) or one
game's moves. Fix:

- `parse-pgn` now extracts only the **roster** (`tags`), the `result`, and each
  game's **verbatim movetext substring** (`movetext-raw`) eagerly, using one
  master-regex scan with token *positions* to split games (comment-safe).
- The move tree is built on demand by **`movetext(game)`** (memoised). Roster-only
  consumers never trigger it; a single game out of a big file parses only itself.
- Eager validations kept at parse time: malformed/unterminated tags and a stray
  top-level `)`. Deeper movetext-structure errors surface on first `movetext()`.
- **Data-model change:** the eager `game.movetext` *field* → lazy `movetext(game)`
  *accessor* + new `game.movetext-raw` string. Internal callers (game / notation /
  to-fen) and `tests/pgn/realworld/parse_full.typ` updated; suite 67/67 green.

### Deferred / notes

- Direct-encounter tie-break; localized headers; forfeit/bye handling — later.
- Tree-builder constant-factor speedup (avoid the `nodes.last()` write-back
  pattern) — would speed up "parse every game"; separate session.
