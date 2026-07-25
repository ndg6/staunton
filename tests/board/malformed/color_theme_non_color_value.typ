// EXPECT: color theme `light` must be a color; got "red"
// color-theme() - `light` / `dark` must be actual `color` values; a string like
// `"red"` (which reads as a color name to a human but is not a Typst `color`)
// must be rejected, not silently stored as-is.
#import "/lib.typ": color-theme
#color-theme(light: "red")
