// Asserting test: prompt 53 Phase 3 — a path-locator hop's `into` key is now
// OPTIONAL and defaults to 0 (`hop.at("into", default: 0)`, five sites: this
// covers the three reached from `move-at` — game.typ:158 (`_ply-of`/locator
// resolution, the general path), game.typ:190 (`move-node`'s variation
// descent) and game.typ:230 (`_resolved-move`'s descent) — plus game.typ:362
// (`_update-in-line`, the BUILDER path under with-nags/with-comments/
// with-variation). The property is an EQUIVALENCE: omitting `into` on a hop
// must produce exactly what `into: 0` produces — asserted both as `==`
// between the two forms AND against a concrete expected value, so the check
// cannot pass by both sides silently degrading the same way.
#import "/lib.typ": game, move-at, with-nags

#let g = game("[White \"V\"][Black \"T\"] 1. e4 (1. d4 d5 2. c4) e5 2. Nf3 *")

// --- move-at / locator resolution (game.typ:158/190/230) --------------------
#let with-into = move-at(g, at: (line: ((at: "1w", into: 0),), at: "2w")).san
#let sans-into = move-at(g, at: (line: ((at: "1w"),), at: "2w")).san
#assert(with-into == "c4", message: "concrete: 1w's variation continues 2. c4")
#assert(sans-into == with-into, message: "omitting `into` on 2w hop matches `into: 0`")

#let with-into-b = move-at(g, at: (line: ((at: "1w", into: 0),), at: "1b")).san
#let sans-into-b = move-at(g, at: (line: ((at: "1w"),), at: "1b")).san
#assert(with-into-b == "d5", message: "concrete: 1w's variation continues 1... d5")
#assert(sans-into-b == with-into-b, message: "omitting `into` on 1b hop matches `into: 0`")

// --- builder path (game.typ:362, via with-nags) ------------------------------
// with-nags(game, nags:) takes an array of (locator, value) pairs.
#let built-explicit = with-nags(g, nags: (((line: ((at: "1w", into: 0),), at: "2w"), "$1"),))
#let built-omitted = with-nags(g, nags: (((line: ((at: "1w"),), at: "2w"), "$1"),))
#assert(
  move-at(built-explicit, at: (line: ((at: "1w", into: 0),), at: "2w")).nags == ("1",),
  message: "with-nags with explicit into: 0 lands the nag",
)
#assert(
  move-at(built-omitted, at: (line: ((at: "1w", into: 0),), at: "2w")).nags == ("1",),
  message: "with-nags with `into` omitted lands the same nag",
)
// with-nags never mutates its source game (documented property).
#assert(
  move-at(g, at: (line: ((at: "1w", into: 0),), at: "2w")).nags == (),
  message: "the source game g is never mutated by with-nags",
)

// --- multi-hop: `into` omitted on some hops but not others (game.typ:158) ---
// A nested variation to address both hops of: 1. e4 (1. d4 d5 (1... Nf6 2. c4)) e5
#let g3 = game("[White \"A\"][Black \"B\"] 1. e4 (1. d4 d5 (1... Nf6 2. c4)) e5 *")
#let full = (line: ((at: "1w", into: 0), (at: "1b", into: 0)), at: "2w")
#let outer-omitted = (line: ((at: "1w"), (at: "1b", into: 0)), at: "2w")
#let inner-omitted = (line: ((at: "1w", into: 0), (at: "1b")), at: "2w")
#let both-omitted = (line: ((at: "1w"), (at: "1b")), at: "2w")
#assert(move-at(g3, at: full).san == "c4", message: "concrete: nested variation continues 2. c4")
#assert(move-at(g3, at: outer-omitted).san == "c4", message: "outer hop's `into` omitted matches explicit")
#assert(move-at(g3, at: inner-omitted).san == "c4", message: "inner hop's `into` omitted matches explicit")
#assert(move-at(g3, at: both-omitted).san == "c4", message: "both hops' `into` omitted matches explicit")

Path-locator `into: 0` default (prompt 53 Phase 3): omitting `into` on a hop is equivalent to writing it explicitly, checked through `move-at` (mainline resolution + move-node + engine descent) and `with-nags` (the builder path), including a two-hop nested-variation address with `into` omitted on either or both hops.
