// EXPECT: unknown piece kind
// §position - the dict form validates piece kinds against the variant: a name
// that is neither a long kind nor an abbreviation is a hard error.
#import "/lib.typ": position
#let _ = position((e1: (kind: "wizard", color: "white")))
