// EXPECT: invalid piece char
// position - the string form rejects characters that are not a valid piece
// abbreviation (for the variant) or "." -- here "x" is not a standard piece.
#import "/lib.typ": position
#let _ = position("xkr.....")
