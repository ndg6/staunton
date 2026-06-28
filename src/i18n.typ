// ===========================================================================
// Language registry for notation output (prompt 14).
//
// Each `src/assets/i18n/<code>.typ` exports a `piece-chars` dict mapping a piece
// KIND (king/queen/rook/bishop/knight; pawns have no SAN letter) to that
// language's first letter(s) -- e.g. German knight "S", Russian king "Кр".
// They are imported statically here (Typst cannot import by a runtime string)
// into one `notation-langs` map keyed by language code. `notation` looks a code
// up here; an unknown code falls back to English.
//
// Adding a language is a no-code change: drop `src/assets/i18n/<code>.typ`
// exporting `piece-chars`, then add one line to `notation-langs` below.
// ===========================================================================

#import "assets/i18n/en.typ"
#import "assets/i18n/de.typ"
#import "assets/i18n/es.typ"
#import "assets/i18n/fr.typ"
#import "assets/i18n/it.typ"
#import "assets/i18n/pt.typ"
#import "assets/i18n/ru.typ"

#let notation-langs = (
  en: en.piece-chars,
  de: de.piece-chars,
  es: es.piece-chars,
  fr: fr.piece-chars,
  it: it.piece-chars,
  pt: pt.piece-chars,
  ru: ru.piece-chars,
)
