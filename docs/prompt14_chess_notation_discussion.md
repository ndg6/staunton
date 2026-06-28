# Prompt 14 — human-readable chess notation output: design discussion

> Status: **implemented** (standard chess) — see "Implementation outcome" at the
> end. Also added `to-fen` (export FEN) per the same request. Source:
> `prompts/prompt_14__add_chess_notation.txt`. Scope: a `notation` /
> `chess-notation` function that renders a game's move text as human-readable
> notation — with figurines and language-aware piece letters.

## Verdict

Games already store **SAN strings verbatim** from the PGN (English: `"Nf3"`,
`"O-O"`, `"exd5"`, `"e8=Q+"`). So figurine output and localization are a **pure
string transform on existing SAN — no engine needed**. The only genuinely new
machinery is the range selection and the i18n registry.

Key fact: there is **no move→SAN encoder** in the codebase (we have the decoder
`san-to-move`, since PGN carries SAN). So *generating* notation from
positions/moves (e.g. a `play-moves` result without SAN) is a separate future
feature; *formatting* SAN we already hold is what this prompt delivers.

## Decisions (this session)

- **Range-based output, game- (or SAN-array-) based.** A `position` has no move
  history, so notation needs a `game` or a SAN array. Reuse the board-after
  locator for `from`/`to` endpoints (inclusive).
- **Generic `notation` + `chess-notation` sugar** (variant-forward, mirroring
  `board`/`diagram`). `notation` dispatches on variant; `chess-notation` is
  standard sugar; `xiangqi-notation` etc. later (xiangqi notation is a different
  system entirely — Chinese characters, relative movement — so the seam earns
  its keep).
- **Engine-free SAN-source formatter** too, so notation works outside a game
  when the caller supplies the moves. To stay consistent with `play-moves`, the
  source accepts **both forms** `play-moves` does: a **move-text string**
  (`"1. e4 e5 2. Nf3"`, tokenized via the shared `_split-movetext` — move numbers
  and a trailing result stripped) **or** a **SAN array** `("e4", "e5", "Nf3")`.
  The move→SAN encoder stays future work.
- **Localization by letter substitution** on the canonical English SAN.
- **`lang: "auto"`** inspects `text.lang` (via `context`), default `"en"`.

## API

```typ
#let notation(source, from: none, to: none,
              figurine: false, lang: "en", move-numbers: true, result: false) = { ... }
#let chess-notation(source, ..args) = { /* assert standard; */ notation(source, ..args) }
```

`source`: a parsed **game**, or a **SAN source** — a move-text string or a SAN
array, the same two forms `play-moves` accepts (engine-free, shared
`_split-movetext`). `from`/`to`: board-after-style locators (`"12w"`, `"12b"`, or
a variation path), **inclusive**; defaults = first / last move. For a bare
SAN-source there is no game context, so numbering assumes move 1, White to move
(overridable via `start-move` / a side hint if needed).

| Call | Output |
|---|---|
| `chess-notation(game)` | whole mainline |
| `chess-notation(game, to: "12w")` | start → White's 12th |
| `chess-notation(game, from: "8b")` | Black's 8th → end |
| `chess-notation(game, from: "8b", to: "12w")` | that mainline slice |
| `chess-notation("1. e4 e5 2. Nf3")` | format a move-text string |
| `chess-notation(("e4", "e5", "Nf3"))` | format a SAN array |

- `from`/`to` inclusive; a slice starting on Black renders `8... Nf6 9. Bc4 …`.
- v1 works on a **single line** (mainline, or one variation line when both
  endpoints share its path prefix); cross-line ranges error. Comments / NAGs /
  variations are excluded from the score by default.
- Options: `figurine` (glyphs instead of letters), `lang`
  (`"en"` | `"auto"` | code), `move-numbers`, `result` (append game result).

## Localization mechanism (the core transform)

Standard SAN uses uppercase piece letters `K Q R B N`; files are lowercase
`a–h`; castling is `O-O`/`O-O-O`. To localize one SAN token:

1. the **leading** uppercase piece letter, and any letter **after `=`**
   (promotion), are piece letters;
2. map them `English-letter → kind → lang.piece-chars[kind]`
   (`N → knight → "S"` German, `→ "К"` Russian);
3. leave files, ranks, `x`, `+`, `#`, `O-O`, and NAGs untouched.

Multi-char targets (Russian `K → "Кр"`, `N → "К"`) are safe because we map by
*meaning*, not by character — no `K`/`N` collision. **Figurines** are the same
substitution into Unicode chess glyphs, **colour-aware**: White's moves use the
outline symbols (♔♕♖♗♘, U+2654–2658), Black's the solid ones (♚♛♜♝♞,
U+265A–265E) — so the side reads off the figurine, not just the move number.
Pawns have no symbol.

This is correct precisely because PGN SAN is canonical English; the transform
never needs the engine.

## i18n registry & `auto`

- `src/assets/i18n/{en,de,es,fr,it,pt,ru}.typ` each export `piece-chars` (keyed by
  kind; pawn absent — correct). A new `src/i18n.typ` statically imports all seven
  into `notation-langs = (en: .., de: .., …)` (Typst can't import by a runtime
  string).
- `lang: "auto"` resolves `text.lang` inside `context`; unknown codes fall back
  to `en` (and `notation` itself stays a non-context element where possible by
  reading lang in a small wrapper).
- Whether to extend `piece-chars` to other languages/variants is left open; the
  registry makes adding a file a no-code change.

## Open / deferred

- **move→SAN encoder** — needed to render notation from positions/moves without
  pre-existing SAN; sizable (disambiguation, capture/check/mate suffixes).
  Deferred; flagged.
- **Comments / NAGs / variations in the score** — excluded in v1; could be an
  opt-in later (`comments: true`, RAV rendering).
- **Localized castling / result punctuation** — kept as `O-O` / `1-0`; revisit if
  a locale needs `0-0`.
- **Other-variant notation** (`xiangqi-notation`, …) — future; the generic
  `notation` seam is the hook.

## Test plan

- Localization: a known mainline in en/de/ru — assert the transformed strings
  (`Nf3→Sf3` de, `→Кf3` ru; `e8=Q→e8=D` de); pawn/file/castling untouched.
- Figurine: piece letters become glyphs; pawns/files unchanged.
- Ranges: whole game; `to:`; `from:`; `from:`+`to:`; a Black-start slice numbers
  as `8...`.
- SAN source formats without a game (engine-free), in BOTH forms: a move-text
  string ("1. e4 e5 2. Nf3") and a SAN array (("e4","e5","Nf3")) — same result.
- `lang: "auto"` follows `#set text(lang: "de")`.
- Errors (EXPECT): cross-line range; unknown lang code → falls back (no error) —
  assert fallback, not error.
- `chess-notation` on a non-standard game/source errors (variant guard).

## Implementation outcome

Shipped as designed:

- **`notation` / `chess-notation`** in `src/notation.typ`. `notation` is the
  variant-agnostic formatter; `chess-notation` is the standard sugar (variant
  guard). Source: a game (mainline SAN), a move-text string, or a SAN array —
  the string form reuses `_split-movetext` from `play-moves`.
- **Localization by letter substitution** (`_letter-to-kind`: K Q R B N → kind →
  `lang.piece-chars`), incl. promotion after `=`; files/ranks/`x`/`+`/`#`/`O-O`
  untouched. Multi-char (Russian `Кр`/`К`) handled. **Figurines** are
  colour-aware: White → outline glyphs (U+2654–2658), Black → solid (U+265A–265E).
- **i18n registry** `src/i18n.typ` statically imports the seven `src/assets/i18n`
  files into `notation-langs`; `lang: "auto"` reads `text.lang` in `context`,
  unknown → `en`.
- **Ranges** `from`/`to` are inclusive mainline locators; a Black-leading slice
  numbers as `2...`. Variation-line ranges error (v1); comments/variations
  excluded.
- **`to-fen`** in `lib.typ` (encoder `position-fen` in `src/fen.typ`): exports a
  **position** or a **game + locator** (via `position-after`). Standard FENs
  round-trip exactly with `parse-fen`; geometry-aware; tolerant of `position()`
  output. This closes the previously-deferred "position→FEN exporter".
- **Tests:** `tests/notation/notation.typ`, `tests/fen/export/to_fen.typ`, and 4
  EXPECT-error tests (notation on a position; variation-line range;
  `chess-notation` on a non-standard source; `to-fen` game without a locator).
  Suite: **57 pass / 0 fail**.

### Notes / deviations

- `notation` returns a plain **string** for an explicit `lang`, but a **content**
  block for `lang: "auto"` (it must read `text.lang` inside `context`). Both
  render identically; only matters if a caller compares the return to a string —
  asserts in the tests therefore avoid the `auto` path.
- **move→SAN encoder** remains future work (notation formats existing SAN only).
- Numbering uses the locator origin (move 1 = White), matching `position-after`;
  FEN-started games inherit that pre-existing locator convention.
