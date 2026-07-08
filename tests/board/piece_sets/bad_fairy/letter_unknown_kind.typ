// EXPECT: maps to unknown kind
// A full inline spec (no `extends`) whose `abbr` maps a letter to a kind that is
// not listed in `kinds` must be rejected.
#import "/lib.typ": position

#let bad = (kinds: ("alfil",), abbr: (a: "alfil", z: "zebra"))
#position((a1: "A"), variant: bad)
