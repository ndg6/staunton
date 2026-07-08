// EXPECT: already used by extended variant
// Non-overlap rule: a custom variant that `extends: "standard"` may not reuse a
// letter the base already assigns. Here `b` is standard bishop -- reassigning it
// to a fairy piece must be rejected.
#import "/lib.typ": position

#let bad = (extends: "standard", kinds: ("alfil",), abbr: (b: "alfil"))
#position((a1: "A"), variant: bad)
