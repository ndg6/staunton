# Testing improvements — design discussion

> Status: **decisions resolved; building next.** This captures the design
> choices for ramping up the test procedures after the `tests/` tree was
> reorganised into thematic folders and the old runner / test files were
> discarded. Source prompt: `prompts/prompt_7__testing_improvs.txt`.

## Decisions (resolved)

1. **Runner language: bash.** New `tests/run.sh`, walking `tests/**/*.typ`,
   classifying by the `// EXPECT:` header (§A).
2. **FEN rule: no whitespace ⇒ silent full defaults (`w KQkq - 0 1`); any
   whitespace present ⇒ the input must be a correct/complete FEN** (present
   fields validated, not silently defaulted). Resolves tension E2. The
   no-whitespace castling default is `KQkq`. *(Code change — gated under
   sequencing (ii).)*
3. **Remove the unknown-piece-set guard.** The name check in `square-piece()`
   is dropped so users (and tests) can add new sets by dropping a folder under
   `src/assets/piece_sets/`; `image()` becomes the validator (a missing/misnamed
   file → Typst's own load error). Resolves tension E1 via option (b).
   **Consequence:** the existing expected-fail test
   `tests/board/piece_sets/bad_piece_sets/piece_set_unknown.typ`
   (`// EXPECT: unknown piece set`) is now **obsolete** and must be retired /
   repurposed — that message no longer exists. The §2.4 "missing / misnamed
   piece" tests replace it, using deliberately broken fixture folders under
   `src/assets/piece_sets/` (they must live there because the SVG path is resolved
   relative to `src/pieces.typ` as `assets/piece_sets/<name>/`).
4. **Sequencing: option (ii).** Ship a fully green suite now; code-gated
   fail-tests (the "yes" rows in §F, plus the FEN rule in decision 2) land
   alongside their code change, per CLAUDE.md.

The original discussion below is kept for context.

## Built (this session)

A fully green suite (33 cases) plus the runner and the showcase:

- **Runner:** `tests/run.sh` — walks `tests/**/*.typ`, `// EXPECT:`-classified,
  skips `_`-prefixed paths, keeps a PDF per pass-case mirrored under `tests/out/`,
  and compiles `examples/*.typ` as must-compile showcases.
- **Fixture:** `tests/board/_fixture.typ` (`test-fen`, the shared §2 position).
- **Decision-3 code slice:** guard removed from `src/pieces.typ`; obsolete
  `piece_set_unknown.typ` retired; `src/assets/piece_sets/_incomplete/` fixture
  (ships only `bK.svg`) drives both the positive "user-added set" test and the
  negative "missing piece file" test.
- **§2 board:** `size/sizes`, `colors/colors`, `labeling/{label_modes,
  onsquare_fallback}`, `orientation/flip`, `piece_sets/existing/{all_piece_sets,
  unicode_fallback,custom_user_set}`, `piece_sets/bad_piece_sets/
  missing_piece_file`, `style_options/{inheritance,direct_style}` (+ existing
  `failed_options/flip_as_default`).
- **§3 diagram:** `auto_captions`, `free_captions`, `outlines/outline`.
- **§4 FEN:** `good/{fen_full,fen_no_metadata}`, `malformed/{rank_count,
  bad_characters}`, `inconsistent/{rank_overflow,rank_underflow}`.
- **§5 PGN:** `good/{mainline_move,variation_move,nested_variation}`,
  `roster/good/roster_complete`, `san/good/san_disambiguation` (+ existing
  malformed/illegal/stray-paren cases).
- **Showcase:** `examples/showcase.typ` touring the plugin with all three
  `examples/pgn/` games.

## Code-gated backlog (sequencing (ii): land each test with its code change)

These fail-cases from §4/§5 cannot be written as red tests yet because the code
does not produce a user-facing error for them. Each lands alongside the
validation code that makes it fail:

1. **FEN decision-2 rule** — once "any whitespace ⇒ must be a complete, valid
   FEN" lands: tests for partial/garbled metadata; and the no-whitespace castling
   default flips from `-` to `KQkq`.
2. **FEN >1 king of a color** (§4.3) — needs a king-count check.
3. **FEN castling well-formed** (§4.4) — needs validation that field 3 is `-` or
   a subset of `KQkq`.
4. **FEN en-passant consistency** (§4.4) — needs the target-square + pawn check.
5. **FEN side-to-move / clocks present** (§4.4) — depends on decision-2.
6. **PGN missing mandatory roster** (§5) — currently tolerated/defaulted; needs a
   decision on whether to warn/error and a user-facing message if so.

---

## Two findings that reshape the plan

1. **The test runner is gone.** `tests/run.sh` was discarded along with the old
   test files (`unit.typ`, `real.typ`, `api.typ`, `scaling.typ`, `tests/fail/`).
   The new tree is all thematic folders with nothing tying them together. So
   "ramping up test procedures" starts with deciding the *runner + conventions*,
   not just adding test files.
2. **Several sketched fail-tests cannot fail against today's code.** The code
   currently validates far less than the §4/§5 spec demands — no king-count
   check, no en-passant consistency, no castling-string validation, lenient
   metadata. Those expected-fail tests would compile clean today. Code changes
   are deferred (per the prompt), so this forces a *sequencing* decision.

---

## A. The runner & the pass/fail convention (foundational)

Keep `// EXPECT: <substr>` as the **sole discriminator**, independent of folder:

- A `.typ` file **with** a `// EXPECT: <substr>` header → expected-fail; it must
  error *and* the error message must contain the substring.
- A `.typ` file **without** it → expected-pass; it must compile.

This is what the surviving moved tests already use. It is robust (folder renames
do not break classification), self-documents the intended error, and needs no
per-folder lists. The new runner walks `tests/**/*.typ` recursively and branches
on the presence of that header.

**Open decision 1 — runner language:** bash (`tests/run.sh`, parity with the old
harness; the Bash tool is available here) **[recommended]** vs PowerShell (native
to the Windows host).

## B. Output artifacts → `tests/out`

All output goes under `tests/out` and nowhere else, mirroring the thematic
structure of `tests/` (created on demand). Two kinds of test:

- **Logic / error tests** (FEN validation, SAN errors, stray paren): no artifact
  worth keeping — compile to a throwaway temp, check exit code + message only.
- **Visual tests** (board sizes, colors, labeling, piece sets, diagrams): these
  are the ones you actually look at. The runner emits a kept artifact mirroring
  the source path, e.g. `tests/board/size/sizes.typ` →
  `tests/out/board/size/sizes.pdf`.

**Recommendation:** PDF for multi-page visual sheets (cheap, one file); PNG only
where a raster preview is specifically wanted.

## C. The shared "arbitrary position" for board tests (§2)

Define the position once in a shared fixture, e.g. `tests/board/_fixture.typ`
exporting `#let test-fen = "..."`; every §2 test imports it. This guarantees
§2.1–2.5 really are the same position and a single edit re-points them all. Use a
position with **all six piece kinds, both colors, and some asymmetry** (so flips
and labels are visually unambiguous) — the Italian-ish FEN from the old
`scaling.typ` is a good candidate.

## D. Per-area notes

| Area | Content | Output |
|------|---------|--------|
| **§2.1 Sizes** | board at a size sweep, `labels: false` | visual sheet |
| **§2.2 Colors** | custom `light`/`dark`/`highlight-fill`; ≥1 labeled board to see label color resolve against custom squares + the border-band darkening | visual |
| **§2.3 Labeling** | all three modes × `file-side`/`rank-side` permutations; plus an `on-square` size sweep to watch the auto-fallback to `border` trip at ≤4pt (folds in the old `scaling.typ`) | visual |
| **§2.4 Piece sets** | existing sets; unicode fallback; broken sets — see tension E1 | visual |
| **§2.5 Style options** | two diagrams in one file: `set-chess-defaults`/`set-piece-set`, then confirm the *second* diagram inherits. "Use styles directly" — `chess-style`/`default-style` are exported, so a test can also assert on the merged dict | visual + assertion |
| **§3 Diagrams** | auto-caption matrix (full / partial / no roster → above-line present or absent; FEN vs PGN vs manual → below-caption default); explicit `game-info:`/`caption:` overrides; a `chess-outline` test | visual + assertions |
| **§5 PGN good** | mainline / variation / nested-variation boards from a real game (`opera.pgn` already staged) | visual |

## E. Two real tensions needing a call

**E1. Broken-piece-set fixtures (§2.4) collide with the hardcoded
`known-piece-sets` guard.** `square-piece()` asserts the set name is in
`known-piece-sets` *before* touching any file, so a custom broken-set folder is
rejected at the name check and never reaches the missing-file error. To exercise
the missing/misnamed-file path we would need either (a) a test-only set added to
the known list, or (b) relaxing the guard to let names through and let `image()`
be the validator — exactly the **auto-detect** question raised earlier.
**Recommendation:** test the two cases separately — "unknown name" stays an
assertion test against the known list (already present as
`piece_set_unknown.typ`); "known name, missing file" is gated on a code decision.
Flag it; do not fake it.

**E2. FEN §4.0 vs §4.4 conflict.** §4.0 says *no spaces ⇒ silently complete with
`w KQkq - 0 1`*. §4.4 says *side-to-move / castling / clocks must be present*.
These contradict for the partial case (placement plus only *some* trailing
fields), and §4.0's default castling `KQkq` differs from the code's current
default `-`. Proposed consistent rule: **zero whitespace ⇒ complete all six
fields silently; once *any* metadata is present, the fields that appear must be
well-formed (else a user-facing error).** Confirm before writing the §4.4
fail-tests — it decides which inputs are pass vs fail.

**Open decision 2 — FEN rule:** confirm the rule above, and whether the
no-whitespace castling default should be `KQkq` (§4.0) or `-` (current code).

## F. Validation gaps vs today's code (drives the red-test backlog)

| Spec item | Today | Needs code? |
|-----------|-------|-------------|
| §4.0 no-space ⇒ silent defaults | placement-only works, but castling defaults to `-` not `KQkq` | minor, if `KQkq` wanted |
| §4.1 wrong rank count | asserts ("must have 8 ranks") | no |
| §4.2 wrong characters | asserts via `fen-piece` ("invalid FEN piece letter") | message could be clearer; otherwise no |
| §4.3 pieces+empties ≠ 8 | asserts (overflow / "does not fill 8 files") | no |
| §4.3 >1 king of a color | **not checked** | **yes** |
| §4.4 side-to-move present & w/b | w/b validated; absence defaults silently | depends on E2 |
| §4.4 castling well-formed | **not validated** (garbage → all-false) | **yes** |
| §4.4 en-passant square + pawn consistency | **not validated** | **yes** |
| §4.4 clocks present | default silently; garbage → Typst's own `int()` error | depends on E2 |
| §5 ambiguous SAN | asserts ("ambiguous move") | no |
| §5 illegal move | asserts | no |
| §5 garbage SAN | asserts | no |
| §5 stray paren | asserts | no |
| §5 missing roster | tolerated (defaults) — needs a *user-facing* path if we want it to warn/error | **decision** |
| §2.4 unknown piece-set name | asserts ("unknown piece set") | no |

## G. Sequencing — the "red tests" question

Most §4.3 / §4.4 / parts of §5 fail-tests require code that does not exist yet.

- **(i)** Write them now as known-red tests — honest and drives the code work,
  but the suite is red until the code lands.
- **(ii)** Write only what classifies correctly against *today's* code now, and
  add each remaining fail-test alongside the code change that makes it fail (per
  CLAUDE.md: tests and feature code go hand in hand).

**Recommendation:** **(ii)** — ship a fully green, runnable suite now (all visual
tests, all good-case tests, and the fail-tests today's asserts already satisfy:
wrong rank count, bad characters, ambiguous SAN, illegal move, stray paren,
unknown piece-set, flip-as-default), with the code-gated cases (F's "yes" rows)
enumerated as a backlog.

## H. Examples showcase (not a test)

Create one example file under `examples/` using all three PGNs in `examples/pgn/`
to highlight plugin capabilities. It is a showcase, not a test — but the runner
may still compile `examples/*.typ` to ensure they do not break. The `tests/pgn/`
real-world copies stay separate; `examples/pgn/` content is **not** used for
testing per the prompt.

---

## Decisions needed before building

1. Runner language: **bash** (recommended) or PowerShell? (open decision 1)
2. FEN rule: confirm "no whitespace ⇒ silent full defaults; otherwise present
   fields must be valid," and the no-space castling default (`KQkq` vs `-`).
   (open decision 2)
3. Broken-piece-set fixtures: defer until the guard / auto-detect question is
   decided — agree? (tension E1)
4. Sequencing: option **(ii)** — green suite now, code-gated red tests as a
   backlog — agree? (§G)
