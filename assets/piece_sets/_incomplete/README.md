# `_incomplete` — a deliberately incomplete piece set (test fixture)

This is **not** a real piece set. It exists only for the §2.4 piece-set tests
that exercise what happens after the unknown-set guard was removed:

* it contains a valid `bK.svg` only, so rendering a position that needs **only**
  the black king succeeds — proving a user can add a new set by just dropping a
  folder here, with no plugin code change;
* it is **missing every other piece file**, so rendering a position that needs,
  e.g., the white king fails with Typst's own image-load error — the new
  validation path for a missing / misnamed piece file.

The leading underscore marks it as a fixture, not a shippable set; it is not
listed in `known-piece-sets`.
