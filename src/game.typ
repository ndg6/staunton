// ===========================================================================
// Game navigation (Phase B: engine resolution, on demand).
//
// Turns a parsed `game` (from pgn.typ) into positions. This is where the engine
// actually runs -- only when a diagram asks for a position, so a tournament
// file read only for results never reaches here.
//
// Locators address a point in the game:
//   * "30w" / "30b"  -- after White's / Black's 30th move (the mainline);
//   * a path dict     -- for (possibly nested) variations:
//       (line: ( (at: "2w", into: 0), (at: "2b", into: 0) ), at: "3w")
//     read as: from the mainline, at White's move 2 descend into variation 0,
//     then at Black's move 2 descend into variation 0, then take the position
//     after White's move 3.
//
// Ply numbering: after White's move m -> ply 2m-1; after Black's -> ply 2m.
// ===========================================================================

#import "fen.typ": parse-fen, starting-fen
#import "san.typ": san-to-move
#import "engine.typ": apply

// "30w" -> 59 ; "30b" -> 60
#let _ply-of(loc) = {
  assert(type(loc) == str and loc.len() >= 2, message: "bad move locator: " + repr(loc))
  let color = loc.slice(loc.len() - 1)
  let num = int(loc.slice(0, loc.len() - 1))
  if color == "w" { 2 * num - 1 }
  else if color == "b" { 2 * num }
  else { panic("move locator must end in 'w' or 'b': " + loc) }
}

/// The starting position of a game: from the `FEN` tag if present, else standard.
#let game-start(game) = {
  if "FEN" in game.tags { parse-fen(game.tags.at("FEN")) } else { parse-fen(starting-fen) }
}

/// The mainline as an array of SAN strings (the game as played).
#let mainline(game) = game.movetext.map(n => n.san)

/// The game result string ("1-0" / "0-1" / "1/2-1/2" / "*").
#let game-result(game) = game.result

// Apply SAN nodes line[0..k) to `pos`, returning the new position.
#let _advance(pos, line, k) = {
  let p = pos
  for j in range(k) {
    p = apply(p, san-to-move(p, line.at(j).san))
  }
  p
}

/// The position at a locator. Handles mainline and (nested) variations.
#let position-after(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let line = game.movetext
  let branch-ply = 1
  let pos = game-start(game)

  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply // moves before the branch point
    assert(k >= 0 and k < line.len() + 1, message: "locator hop out of range at " + hop.at("at"))
    pos = _advance(pos, line, k)
    let node = line.at(k)
    let vars = node.at("variations", default: ())
    let into = hop.at("into")
    assert(into < vars.len(), message: "no variation #" + str(into) + " at move " + hop.at("at"))
    line = vars.at(into)
    branch-ply = target
  }

  let target = _ply-of(loc.at("at"))
  let k = target - branch-ply + 1 // inclusive of the addressed move
  assert(k >= 0 and k <= line.len(), message: "locator out of range: addressed move past end of line")
  _advance(pos, line, k)
}

/// The SAN of the move addressed by `locator` (mainline "30w"/"30b" or a
/// variation path), e.g. "O-O-O". Used to build PGN-diagram captions.
#let move-san(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let line = game.movetext
  let branch-ply = 1
  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply
    let node = line.at(k)
    line = node.at("variations").at(hop.at("into"))
    branch-ply = target
  }
  let k = _ply-of(loc.at("at")) - branch-ply
  assert(k >= 0 and k < line.len(), message: "move-san: locator addresses a move past the end of its line")
  line.at(k).san
}

/// The full move node addressed by `locator` (mainline "30w"/"30b" or a variation
/// path), including its comments (`comment-before` / `comment-after`) and
/// variations. Used to recover PGN `%cal` / `%csl` annotations for a diagram.
#let move-node(game, locator) = {
  let loc = if type(locator) == str { (line: (), at: locator) } else { locator }
  let line = game.movetext
  let branch-ply = 1
  for hop in loc.at("line", default: ()) {
    let target = _ply-of(hop.at("at"))
    let k = target - branch-ply
    let node = line.at(k)
    line = node.at("variations").at(hop.at("into"))
    branch-ply = target
  }
  let k = _ply-of(loc.at("at")) - branch-ply
  assert(k >= 0 and k < line.len(), message: "move-node: locator addresses a move past the end of its line")
  line.at(k)
}

/// A non-destructive "what-if" line: start from a position (or FEN string) and
/// apply a sequence of SAN moves, returning the array of positions
/// (start, after move 1, after move 2, ...). The source is never modified.
#let line(start, moves) = {
  let pos = if type(start) == str { parse-fen(start) } else { start }
  let out = (pos,)
  for s in moves {
    pos = apply(pos, san-to-move(pos, s))
    out.push(pos)
  }
  out
}
