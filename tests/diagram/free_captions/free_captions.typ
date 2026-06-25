// §3 Diagrams - free (manual) captions, overriding the automatic ones in both
// slots: `game-info:` replaces the above line, `caption:` replaces the below
// line, and either can be set to `none` to suppress it entirely.
#import "/lib.typ": chess-diagram, starting-fen

#set page(width: 13cm, height: auto, margin: 1.2cm)
#set text(font: "Libertinus Serif", size: 10pt)

= Free captions

== Custom game-info (above) + custom caption (below)
#chess-diagram(starting-fen, size: 3.2cm,
  game-info: [*Opening study* — symmetrical setup],
  caption: [The initial array, before 1.e4.])

== game-info overrides the would-be automatic player line
#chess-diagram(starting-fen, size: 3.2cm, white: [X], black: [Y], year: 2000,
  game-info: [My own title beats the auto "X – Y (2000)" line])

== Suppress the default caption with `caption: none`
#chess-diagram(starting-fen, size: 3.2cm, caption: none)

== Rich content in a caption (cross-reference target, math, emphasis)
#chess-diagram(starting-fen, size: 3.2cm,
  caption: [Material is equal: #emph[16] vs #emph[16] pieces.]) <start>

See @start for the starting position.
