// EXPECT: already used by extended variant
// `define-variant` validates EAGERLY: a letter that overlaps the extended base
// (here `b`, standard bishop) errors at the definition itself, not at first use.
#import "/lib.typ": define-variant

#let bad = define-variant("Bad", extends: "standard", kinds: ("alfil",), abbr: (b: "alfil"))
