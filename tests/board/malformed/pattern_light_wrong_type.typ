// EXPECT: pattern-light must be a boolean; got "yes"
// `pattern-light` gates whether a material pattern is drawn on light squares.
// It is a plain on/off switch, so anything non-boolean must be rejected at the
// board rather than silently treated as truthy -- a stringy "false" that
// evaluated as on would draw exactly the look the caller was opting out of.
#import "/lib.typ": board
#board("8/8/8/8/8/8/8/8 w - - 0 1", pattern: "wood", pattern-light: "yes")
