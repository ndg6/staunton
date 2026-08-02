// ===========================================================================
// Language registry: SAN piece letters + UI strings.
//
// Each `src/assets/i18n/<code>.typ` exports:
//   * `piece-chars` -- piece KIND -> SAN letter(s) (German knight "S", ...);
//   * `strings`     -- UI strings: diagram/table supplement + outline titles.
// They are imported statically here (Typst cannot import by a runtime string)
// into `notation-langs` (piece-chars) and `ui-strings` (UI strings), keyed by
// language code; an unknown code falls back to English.
//
// Adding a language is a no-code change beyond this file: drop
// `src/assets/i18n/<code>.typ` exporting `piece-chars` + `strings`, then add one
// line to each map below.
// ===========================================================================

#import "style.typ": default-i18n-style, i18n-style-state

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

#let ui-strings = (
  en: en.strings,
  de: de.strings,
  es: es.strings,
  fr: fr.strings,
  it: it.strings,
  pt: pt.strings,
  ru: ru.strings,
)

/// Resolve an effective language code. Must be called inside a `context`.
/// `call-lang == auto` uses the document `lang` setting; `"auto"` follows
/// `text.lang`; any other code is used as given.
///
/// - call-lang (auto, str): the per-call language, or `auto` for the document
///   default.
/// -> str
#let resolve-lang(call-lang) = {
  let setting = if call-lang != auto { call-lang } else { (default-i18n-style + i18n-style-state.get()).lang }
  if setting == "auto" { text.lang } else { setting }
}

/// Look up one localized UI string (English fallback for an unknown code or key).
/// Must be called inside a `context`.
///
/// - call-lang (auto, str): the language, or `auto` for the document default.
/// - key (str): the string key (e.g. `"diagram-supplement"`).
/// -> str
#let ui-string(call-lang, key) = {
  let code = resolve-lang(call-lang)
  let tbl = ui-strings.at(code, default: ui-strings.en)
  tbl.at(key, default: ui-strings.en.at(key))
}

// Resolve piece-chars for a call-lang (context). English fallback.
#let lang-piece-chars(call-lang) = {
  notation-langs.at(resolve-lang(call-lang), default: notation-langs.en)
}

// Reverse of `notation-langs.at(lang)`: SAN letter -> piece kind, sorted longest
// letter first so a multi-cluster letter (Russian king "Кр") is tried before a
// shorter one it starts with (knight "К") -- derived, never a second hand-written
// table. `lang` must already be a known code (see `normalize-san`).
#let _lang-letter-kinds(lang) = {
  let chars = notation-langs.at(lang)
  let pairs = chars.pairs().map(p => (p.at(1), p.at(0)))
  pairs.sorted(key: p => -p.at(0).clusters().len())
}

/// Convert one SAN token written in `lang` into canonical English SAN: the
/// leading piece letter and any promotion letter (after `=`) are translated via
/// `notation-langs`; everything else (files, ranks, `x`, `O-O`/`O-O-O`, check/mate,
/// glyph suffixes) is language-independent and passes through untouched. For
/// `lang: "en"` this is the identity (byte-for-byte).
///
/// - san (str): a SAN token in the given language, e.g. `"Sf3"` (German).
/// - lang (str): the source language code (must be a key of `notation-langs`).
/// -> str
#let normalize-san(san, lang) = {
  assert(
    notation-langs.keys().contains(lang),
    message: "unknown language code \"" + lang + "\"; supported: " + notation-langs.keys().join(", "),
  )
  if lang == "en" { return san }
  let kinds = _lang-letter-kinds(lang)

  // leading piece letter
  let cs = san.clusters()
  let s = san
  for (letter, kind) in kinds {
    let lc = letter.clusters()
    if cs.len() >= lc.len() and cs.slice(0, lc.len()) == lc {
      s = notation-langs.en.at(kind) + cs.slice(lc.len()).join("")
      break
    }
  }

  // promotion letter after "="
  if s.contains("=") {
    let parts = s.split("=")
    if parts.len() == 2 and parts.at(1).len() > 0 {
      let pc = parts.at(1).clusters()
      let letter = pc.at(0)
      for (l, kind) in kinds {
        if kind != "king" and l == letter {
          s = parts.at(0) + "=" + notation-langs.en.at(kind) + pc.slice(1).join("")
          break
        }
      }
    }
  }
  s
}
