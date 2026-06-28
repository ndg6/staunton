# Prompt 18 — internationalization of UI strings: design + outcome

> Status: **implemented**. Source: `prompts/prompt_18__imprv_amd_i18n.txt`. Scope:
> make every language-aware string (diagram/table supplements, outline titles,
> notation piece letters) follow one document language, with per-call overrides.

## Starting point

- `notation` already localized SAN piece letters: `lang: "en"` default, `"auto"`
  follows `#set text(lang:)`, unknown → English. i18n files exported only
  `piece-chars`.
- Diagram/table supplements were fixed English content (`[Diagram]` / `[Table]`),
  document-settable + per-call, but **not** language-aware.
- Outline titles were per-call `title:` only — no document default, not localized.

## Decisions (this session)

- **One global `lang` setting** (`default-i18n-style.lang`, default `"en"`;
  `"auto"` follows `#set text(lang:)`; or a code). Set via `set-lang(code)` **and**
  the `set-chess-defaults(lang: ..)` umbrella. It drives *all* localizable strings.
- **Per-call `lang:`** on `diagram` / `board-after` / `*-table` /
  `chess-*-outline(s)`, default the `auto` VALUE = "use the document setting". The
  string `"auto"` still means "follow `text.lang`". An explicit code forces it.
- **notation follows the global setting**: its `lang` default became `auto` (was
  `"en"`). Consequence: the *default* `notation(...)` now returns **content** (it
  consults document state); pass an explicit `lang` code (+ explicit
  nags/comments/diagrams) for the plain-string fast path.
- **i18n files gain a `strings` dict** (`diagram-supplement`, `table-supplement`,
  `diagram-outline-title`, `table-outline-title`) for all seven languages.
  `i18n.typ` adds `ui-strings`, `resolve-lang(call-lang)` and
  `ui-string(call-lang, key)` (English fallback; must run in `context`).
- **Resolution order** (each string): per-call explicit content → document setting
  (`set-diagram-defaults`/`set-table-defaults`, new `outline-title` keys) →
  language-aware default. Mechanically the factory `supplement`/`outline-title`
  became the `auto` VALUE = "use the localized string".

## Where it lives

- `src/style.typ`: i18n bucket (`default-i18n-style`, `i18n-style-state`,
  `set-lang`, `set-i18n-defaults`); `supplement`/`outline-title` defaults → `auto`;
  umbrella routes `lang`.
- `src/i18n.typ`: `ui-strings`, `resolve-lang`, `ui-string`, `lang-piece-chars`
  (imports the i18n state from `style.typ`).
- `lib.typ`: `_assemble` localizes the diagram supplement (per-call value passes
  through verbatim; else context-resolve); `diagram`/`board-after` gain `lang:`;
  outlines localize their titles (`_outline-title`) + gain `lang:`. Re-exports
  `set-lang`, `set-i18n-defaults`, `ui-string`, `resolve-lang`, i18n style bits.
- `src/tournament.typ`: `_table-figure` localizes the table supplement; the three
  `*-table` fns gain `lang:`.
- `src/notation.typ`: `lang` default → `auto`, resolved via `lang-piece-chars`.

## Tests

- New `tests/i18n/i18n.typ`: `ui-string`/`resolve-lang` for en defaults, explicit
  codes, unknown→en fallback, `"auto"` following `#set text(lang:)`; per-call
  supplement overrides reach the figure (via `query`); document supplement
  settability; `set-lang("de")` flips the localized defaults; notation localizes.
- Updated for the new content-by-default notation: `tests/notation/notation.typ`
  and `tests/notation/embed_diagrams.typ` pass explicit `lang: "en"` on the
  string-equality assertions; `tests/tournament/refs/table_refs.typ` dropped its
  white-box supplement assertions (now in the i18n test).

Suite: **71/71 green.**

## Deferred / notes

- The umbrella `set-chess-defaults(supplement: ..)` still routes to **diagrams**
  (the key collides with the table bucket) — use `set-table-defaults` for tables.
- Only the seven existing languages have `strings`; adding more is a data-only
  change (new i18n file + one line in `i18n.typ`).
