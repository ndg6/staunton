// EXPECT: border-theme must be one of (
// board() - an invalid `border-theme` name must be rejected with a message
// naming all seven valid values, not silently ignored or misrendered. The
// EXPECT above is truncated to the pre-wrap prefix: `repr()` on a 7-element
// string tuple wraps onto multiple lines (one value per line), so matching
// past the opening paren would never match the single-line runner check.
#import "/lib.typ": board
#board((:), label-mode: "border", border-theme: "purple")
