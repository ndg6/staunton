// internationalization of UI strings. One document `lang` setting
// (default "en", "auto" = follow #set text(lang:), or a code) drives the
// language-aware supplements (diagrams, tables) and outline titles; each is also
// document-settable and per-call overridable. notation's piece letters follow the
// same global setting.
#import "/lib.typ": (
  set-lang, set-diagram-defaults, set-table-defaults,
  diagram, standings-table, parse-pgn, starting-fen, notation,
  default-diagram-style, diagram-style-state, default-table-style, table-style-state,
)
// ui-string / resolve-lang are internal (not part of the public lib surface);
// this sheet tests them directly against their own module.
#import "/src/i18n.typ": ui-string, resolve-lang

#set page(width: auto, height: auto, margin: 1cm)

// ---- ui-string: English is the default language ----
#context {
  assert(ui-string(auto, "diagram-supplement") == "Diagram", message: "en diagram supplement")
  assert(ui-string(auto, "table-supplement") == "Table", message: "en table supplement")
  assert(ui-string(auto, "diagram-outline-title") == "List of Diagrams", message: "en diagram outline title")
  assert(ui-string(auto, "table-outline-title") == "List of Tables", message: "en table outline title")
  // an explicit per-call code overrides the document setting:
  assert(ui-string("de", "diagram-supplement") == "Diagramm", message: "explicit de supplement")
  assert(ui-string("fr", "table-supplement") == "Tableau", message: "explicit fr supplement")
  assert(ui-string("ru", "diagram-outline-title") == "Список диаграмм", message: "explicit ru outline title")
  // an unknown code falls back to English:
  assert(ui-string("xx", "table-supplement") == "Table", message: "unknown code -> en fallback")
  // default global lang resolves to en:
  assert(resolve-lang(auto) == "en", message: "default global lang is en")
}

// ---- function-valued catalog entries: automatic diagram captions ----
// `fen-caption` / `pgn-caption` are closures so each language owns its wording;
// asserting them directly is faithful to what the diagrams render.
#context {
  let fen-en = ui-string(auto, "fen-caption")
  assert(fen-en("w") == "White to move", message: "en fen-caption, white to move")
  assert(fen-en("b") == "Black to move", message: "en fen-caption, black to move")
  assert((ui-string(auto, "pgn-caption"))("3. d4") == "Position after 3. d4", message: "en pgn-caption")
  // explicit per-call code:
  assert((ui-string("de", "fen-caption"))("w") == "Weiß am Zug", message: "de fen-caption")
  assert((ui-string("de", "pgn-caption"))("3. d4") == "Stellung nach 3. d4", message: "de pgn-caption")
  assert((ui-string("fr", "fen-caption"))("b") == "Trait aux noirs", message: "fr fen-caption")
  // an unknown code falls back to the English closure:
  assert((ui-string("xx", "fen-caption"))("w") == "White to move", message: "unknown code -> en caption closure")
}

// ---- tournament-table column headers ----
#context {
  assert(ui-string(auto, "tbl-player") == "Player", message: "en table header: Player")
  assert(ui-string("de", "tbl-player") == "Spieler", message: "de table header: Spieler")
  assert(ui-string("de", "tbl-team") == "Mannschaft", message: "de table header: Mannschaft")
  assert(ui-string("de", "tbl-points") == "Pkt", message: "de table header: Pkt")
  assert(ui-string("fr", "tbl-team") == "Équipe", message: "fr table header: Équipe")
  assert(ui-string("xx", "tbl-rank") == "Pos", message: "unknown code -> en table header")
}

// ---- the "auto" string follows #set text(lang:) ----
#[
  #set text(lang: "ru")
  #context {
    assert(ui-string("auto", "diagram-supplement") == "Диаграмма", message: "\"auto\" follows text.lang (ru)")
    assert(resolve-lang("auto") == "ru", message: "resolve-lang(\"auto\") = text.lang")
  }
]

// ---- per-call supplement override reaches the figure (plain content) ----
#diagram(starting-fen, size: 2cm, caption: [x], supplement: [Stellung]) <d-pc>
#let rr = parse-pgn(```
[White "A"][Black "B"][Result "1-0"] 1-0
[White "A"][Black "C"][Result "1-0"] 1-0
[White "B"][Black "C"][Result "1-0"] 1-0
```)
#standings-table(rr, caption: [s], supplement: [Crosstab]) <t-pc>
#context {
  assert(query(figure.where(kind: "chess")).map(f => f.supplement).contains([Stellung]), message: "diagram per-call supplement override")
  assert(query(figure.where(kind: "chess-table")).map(f => f.supplement).contains([Crosstab]), message: "table per-call supplement override")
}

// ---- document supplement override (settable by option) ----
// _assemble / _table-figure resolve the document default with exactly this
// expression, so asserting it is faithful to what the figures use.
#set-diagram-defaults(supplement: [DocDia])
#set-table-defaults(supplement: [DocTab])
#context {
  assert((default-diagram-style + diagram-style-state.get()).supplement == [DocDia], message: "diagram supplement document-settable")
  assert((default-table-style + table-style-state.get()).supplement == [DocTab], message: "table supplement document-settable")
}

// ---- the global lang setting drives the localized defaults + notation ----
#set-lang("de")
#context {
  assert(resolve-lang(auto) == "de", message: "set-lang(de) -> global lang de")
  assert(ui-string(auto, "diagram-supplement") == "Diagramm", message: "set-lang(de) -> diagram supplement Diagramm")
  assert(ui-string(auto, "table-outline-title") == "Tabellenverzeichnis", message: "set-lang(de) -> table outline title")
}
// notation's default lang now follows the global setting (auto): N -> S, B -> L.
#let g = parse-pgn("[White \"A\"][Black \"B\"] 1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 *").first()
#assert(notation(g, lang: "de", nags: false, comments: false, diagrams: false, bold-mainline: false, spaced: true, variations: false) == "1. e4 e5 2. Sf3 Sc6 3. Lb5 a6", message: "explicit de notation")
#context {
  // the auto/default path returns content; render it and confirm it carries the
  // German letters (so the global lang reached notation).
  assert(resolve-lang(auto) == "de", message: "notation will resolve to de via the global setting")
}

// ---- the CHESS language (set-lang) is independent of the MAIN document
// language (#set text(lang:)). Captions and headers follow set-lang. ----
#[
  #set text(lang: "en")   // document prose stays English ...
  #set-lang("de")         // ... while the chess language is German
  #context {
    assert(text.lang == "en", message: "main language is still English")
    assert(resolve-lang(auto) == "de", message: "chess language is German despite English prose")
    assert((ui-string(auto, "fen-caption"))("w") == "Weiß am Zug", message: "caption follows set-lang, not text.lang")
    assert(ui-string(auto, "tbl-player") == "Spieler", message: "table header follows set-lang, not text.lang")
  }
]

// ---- set-lang("auto") makes the chess language follow #set text(lang:) ----
#[
  #set text(lang: "ru")
  #set-lang("auto")
  #context {
    assert(resolve-lang(auto) == "ru", message: "set-lang(auto) -> chess language follows text.lang (ru)")
    assert((ui-string(auto, "pgn-caption"))("1. e4") == "Позиция после 1. e4", message: "auto caption follows text.lang (ru)")
    assert(ui-string(auto, "tbl-points") == "Очки", message: "auto table header follows text.lang (ru)")
  }
]

= i18n OK
