// ===========================================================================
// PGN parsing (Phase A: cheap, eager, no engine).
//
// `parse-pgn(input)` -> array of `game` dicts. One PGN string may contain many
// games. Movetext is parsed into a TREE of move nodes (mainline spine plus
// recursive `variations`); only the `san` strings are recorded here. Engine
// resolution (resolved moves + positions) happens later, on demand, in game.typ
// -- so a tournament file read only for results never invokes the engine.
//
// Errors are HARD: malformed tag pairs, unterminated comments/tags, and stray
// variation parens all panic with a message. (We are lenient about *missing*
// roster tags, but strict about malformed *syntax*.)
//
// A `game` is: (tags: dict, movetext: array<node>, result: str)
// A move `node` is:
//   (san, nags: array, comment-before: none|str, comment-after: none|str,
//    variations: array<array<node>>)
// ===========================================================================

#let _is-space(ch) = ch == " " or ch == "\n" or ch == "\t" or ch == "\r"
#let _specials = ("[", "]", "{", "}", "(", ")", ";")
#let _results = ("1-0", "0-1", "1/2-1/2", "*")

// ---- tokenizer ------------------------------------------------------------
#let _tokenize(input) = {
  // Normalise line endings first: Unicode grapheme segmentation groups CRLF
  // into a single "\r\n" cluster, which would otherwise read as a stray token.
  let cs = input.replace("\r\n", "\n").replace("\r", "\n").clusters()
  let n = cs.len()
  let i = 0
  let toks = ()
  while i < n {
    let ch = cs.at(i)
    if _is-space(ch) {
      i += 1
    } else if ch == "[" {
      let j = i + 1
      let buf = ""
      while j < n and cs.at(j) != "]" { buf += cs.at(j); j += 1 }
      assert(j < n, message: "malformed PGN: unterminated tag (missing ']')")
      let m = buf.match(regex("^\s*([A-Za-z0-9_]+)\s+\"(.*)\"\s*$"))
      assert(m != none, message: "malformed PGN tag pair: [" + buf + "]")
      toks.push((type: "tag", key: m.captures.at(0), value: m.captures.at(1)))
      i = j + 1
    } else if ch == "{" {
      let j = i + 1
      let buf = ""
      while j < n and cs.at(j) != "}" { buf += cs.at(j); j += 1 }
      assert(j < n, message: "malformed PGN: unterminated comment (missing '}')")
      toks.push((type: "comment", value: buf))
      i = j + 1
    } else if ch == ";" {
      let j = i + 1
      let buf = ""
      while j < n and cs.at(j) != "\n" { buf += cs.at(j); j += 1 }
      toks.push((type: "comment", value: buf.trim()))
      i = j
    } else if ch == "(" {
      toks.push((type: "open"))
      i += 1
    } else if ch == ")" {
      toks.push((type: "close"))
      i += 1
    } else if ch == "$" {
      let j = i + 1
      let buf = ""
      while j < n and not _is-space(cs.at(j)) and not _specials.contains(cs.at(j)) { buf += cs.at(j); j += 1 }
      toks.push((type: "nag", value: buf))
      i = j
    } else {
      let j = i
      let buf = ""
      while j < n and not _is-space(cs.at(j)) and not _specials.contains(cs.at(j)) {
        buf += cs.at(j)
        j += 1
      }
      i = j
      if buf == "" {
        // a lone special already handled; guard against no progress
        i += 1
      } else if _results.contains(buf) {
        toks.push((type: "result", value: buf))
      } else if buf.match(regex("^[0-9]+\.+$")) != none {
        toks.push((type: "num", value: buf))
      } else {
        // possibly a move number glued to a move, e.g. "12.e4" or "12...Nf6"
        let m = buf.match(regex("^([0-9]+\.+)(.+)$"))
        if m != none {
          toks.push((type: "num", value: m.captures.at(0)))
          let rest = m.captures.at(1)
          if _results.contains(rest) { toks.push((type: "result", value: rest)) }
          else { toks.push((type: "san", value: rest)) }
        } else {
          toks.push((type: "san", value: buf))
        }
      }
    }
  }
  toks
}

// ---- recursive movetext parser -------------------------------------------
// Returns (nodes, next, result). `top` = top level (stop at result/next-tag/EOF);
// otherwise a variation (stop at the matching close paren).
#let _parse-movetext(toks, start, n, top) = {
  let nodes = ()
  let i = start
  let result = none
  let pending-comment = none

  while i < n {
    let t = toks.at(i)
    if t.type == "tag" {
      break // start of the next game
    } else if t.type == "result" {
      result = t.value
      i += 1
      break
    } else if t.type == "num" {
      i += 1
    } else if t.type == "comment" {
      if nodes.len() > 0 {
        let last = nodes.last()
        let prev = last.at("comment-after", default: none)
        last.insert("comment-after", if prev == none { t.value } else { prev + " " + t.value })
        nodes.at(nodes.len() - 1) = last
      } else {
        pending-comment = t.value
      }
      i += 1
    } else if t.type == "nag" {
      if nodes.len() > 0 {
        let last = nodes.last()
        let ns = last.at("nags", default: ())
        ns.push(t.value)
        last.insert("nags", ns)
        nodes.at(nodes.len() - 1) = last
      }
      i += 1
    } else if t.type == "open" {
      assert(nodes.len() > 0, message: "malformed PGN: variation '(' without a preceding move")
      let sub = _parse-movetext(toks, i + 1, n, false)
      let last = nodes.last()
      let vars = last.at("variations", default: ())
      vars.push(sub.nodes)
      last.insert("variations", vars)
      nodes.at(nodes.len() - 1) = last
      i = sub.next
    } else if t.type == "close" {
      assert(not top, message: "malformed PGN: unexpected ')' outside a variation")
      i += 1
      break
    } else if t.type == "san" {
      nodes.push((
        san: t.value,
        nags: (),
        comment-before: pending-comment,
        comment-after: none,
        variations: (),
      ))
      pending-comment = none
      i += 1
    } else {
      i += 1
    }
  }
  (nodes: nodes, next: i, result: result)
}

// ---- normalise input (string or raw block) -------------------------------
#let _as-text(input) = {
  if type(input) == str { input }
  else if type(input) == content and input.func() == raw { input.text }
  else { panic("parse-pgn: expected a string or a raw block (`#raw(..)` or ```...```), got " + repr(type(input))) }
}

/// Parse PGN text (string or raw block) into an array of games.
#let parse-pgn(input) = {
  let toks = _tokenize(_as-text(input))
  let games = ()
  let i = 0
  let n = toks.len()
  while i < n {
    let tags = (:)
    while i < n and toks.at(i).type == "tag" {
      tags.insert(toks.at(i).key, toks.at(i).value)
      i += 1
    }
    let parsed = _parse-movetext(toks, i, n, true)
    if tags.len() == 0 and parsed.nodes.len() == 0 and parsed.next == i {
      i += 1 // no progress (stray token); avoid an infinite loop
      continue
    }
    i = parsed.next
    games.push((
      tags: tags,
      movetext: parsed.nodes,
      result: if parsed.result != none { parsed.result } else { tags.at("Result", default: "*") },
    ))
  }
  assert(games.len() > 0, message: "no games found in PGN input")
  games
}
