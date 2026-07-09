# Fairy piece art — attribution

These SVGs are used **only** by the manual (`docs/manual.typ`) to demonstrate
non-standard / fairy piece support. They are *not* bundled into the distributed
staunton package (the `docs/` tree is excluded from the Universe package); they
are only present in the source repository and embedded in the compiled
`manual.pdf`.

All fairy demo art is licensed **CC BY-SA 4.0**
(<https://creativecommons.org/licenses/by-sa/4.0/deed.en>), which requires
**attribution** and **share-alike** on derivatives.

| files | piece | source file (Wikimedia Commons) | author | license |
|-------|-------|---------------------------------|--------|---------|
| `alfil_{white,black}.svg`   | Alfil (elephant) | [White_Elephant_Xogos_da_Meiga_chess_icons_family.svg](https://commons.wikimedia.org/wiki/File:White_Elephant_Xogos_da_Meiga_chess_icons_family.svg) / [Black_…](https://commons.wikimedia.org/wiki/File:Black_Elephant_Xogos_da_Meiga_chess_icons_family.svg) | Iago Casabiell González | CC BY-SA 4.0 |
| `ferz_{white,black}.svg`    | Ferz    | [White_Ferz_Xogos_da_Meiga_chess_icons_family.svg](https://commons.wikimedia.org/wiki/File:White_Ferz_Xogos_da_Meiga_chess_icons_family.svg) / [Black_…](https://commons.wikimedia.org/wiki/File:Black_Ferz_Xogos_da_Meiga_chess_icons_family.svg) | Iago Casabiell González | CC BY-SA 4.0 |
| `dabbaba_{white,black}.svg` | Dabbaba | [White_dabbaba.svg](https://commons.wikimedia.org/wiki/File:White_dabbaba.svg) / [Black_dabbaba.svg](https://commons.wikimedia.org/wiki/File:Black_dabbaba.svg) | Kwamikagami | CC BY-SA 4.0 |

The alfil and ferz SVGs are the Xogos da Meiga "chess icons family" (50 mm
Inkscape drawings); the alfil uses that family's *Elephant* piece. The six files
in this directory were byte-verified identical to the Wikimedia Commons originals
above (fetched via `https://commons.wikimedia.org/wiki/Special:FilePath/<File name>`).

RESOLVED (2026-07-09, for 0.2.0): the earlier "provenance unconfirmed" note on
alfil & ferz was a *missing-attribution* problem, not bad art — the SVGs already
in the repo are exactly the CC BY-SA 4.0 Xogos da Meiga originals by Iago
Casabiell González. Provenance is now confirmed and credited; no art was changed.
