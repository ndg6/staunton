// EXPECT: color theme `brightness` must be `auto` or a ratio; got "20%"
// color-theme() - `brightness` only accepts `auto` or a ratio; a string that
// merely looks like a ratio must still be rejected, not silently stored as-is.
#import "/lib.typ": color-theme
#color-theme(light: red, dark: blue, brightness: "20%")
