// EXPECT: unknown pattern: "bogus" (expected `none`, "stripes", "marble", or "wood")
// color-theme() - `pattern` only accepts `none` / "stripes" / "marble" / "wood";
// any other value must be rejected, not silently stored as-is.
#import "/lib.typ": color-theme
#color-theme(light: red, dark: blue, pattern: "bogus")
