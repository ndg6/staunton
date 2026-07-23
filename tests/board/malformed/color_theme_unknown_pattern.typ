// EXPECT: unknown pattern: "bogus" (expected `none` or "diagonal-stripes")
// color-theme() - `pattern` only accepts `none` / "diagonal-stripes"; any other
// value must be rejected, not silently stored as-is.
#import "/lib.typ": color-theme
#color-theme(light: red, dark: blue, pattern: "bogus")
