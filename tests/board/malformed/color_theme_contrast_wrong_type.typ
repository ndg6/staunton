// EXPECT: color theme `contrast` must be `auto` or a ratio; got rgb("#ff4136")
// color-theme() - `contrast` only accepts `auto` or a ratio; a color value
// must still be rejected, not silently stored as-is.
#import "/lib.typ": color-theme
#color-theme(light: red, dark: blue, contrast: red)
