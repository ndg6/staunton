// EXPECT: unknown built-in color theme: "nonexistent"
// board() - an unknown built-in `color-theme:` NAME must be rejected, not
// silently ignored or misrendered. The EXPECT substring deliberately stops
// before "(expected one of ...)" -- that tail enumerates the whole registry,
// which now has 11 entries and will keep growing; pinning it here would make
// this test brittle against every future theme addition (see
// tests/board/style_options/color_board_themes.typ for the registry-shape
// assertions instead).
#import "/lib.typ": board
#board((:), color-theme: "nonexistent")
