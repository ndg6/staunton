// EXPECT: unknown color theme option: "brightness" (expected one of ("light", "dark", "pattern"))
// color-theme() - only accepts `light` / `dark` for now; any other key must be
// rejected, not silently ignored.
#import "/lib.typ": color-theme
#color-theme(brightness: 5%)
