// EXPECT: unknown color theme option: "border-radius" (expected one of (
// color-theme() - only accepts light/dark/pattern/brightness/contrast for now;
// any other key must be rejected, not silently ignored.
#import "/lib.typ": color-theme
#color-theme(border-radius: 5%)
