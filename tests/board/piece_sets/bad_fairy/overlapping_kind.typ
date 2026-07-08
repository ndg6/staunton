// EXPECT: already exists in extended variant
// Non-overlap rule: a custom variant that `extends: "standard"` may not re-add a
// kind the base already defines (here "queen").
#import "/lib.typ": position

#let bad = (extends: "standard", kinds: ("queen",), abbr: (z: "queen"))
#position((a1: "A"), variant: bad)
