# Releasing staunton

Two separate things — don't conflate them:

- **GitHub** is the source repository. Push as often as you like; a commit or
  push **never** changes the package version.
- **Typst Universe** is the published registry. Each published version is
  **immutable**.

## The version lives in one place

`version = "…"` in [`typst.toml`](typst.toml) is the single source of truth.
`scripts/build-bundle.sh` reads it to name the bundle directory
(`dist/preview/staunton/<version>/`). Nothing about pushing to GitHub touches it.

## Key rule: Universe versions are immutable

Once a version is published to Universe (it lands at
`packages/preview/staunton/<version>/` in the `typst/packages` repo) you can
**never** edit or replace it — not even a one-character correction. *Any* change
you want on Universe requires a **new version number**. Consequences:

- Do intermediate work on GitHub under the current version and push freely; none
  of it reaches Universe.
- Only bump the version and publish when you are ready to **freeze** that version.
- Don't publish a version to Universe until you consider it release-worthy — if
  you publish `0.1.0` and then find a bug, you can't fix `0.1.0`, you must ship
  `0.1.1`.

## When you bump the version

Pick the new number by semver:

- **patch** (`0.1.x`) — corrections / bug fixes, no API change;
- **minor** (`0.x.0`) — backward-compatible additions;
- **major** (`x.0.0`) — breaking changes. (Pre-1.0, breaking changes conventionally
  go in the *minor* slot.)

Then update the version string **everywhere it appears** (keep them in sync):

| File | What |
|------|------|
| [`typst.toml`](typst.toml) | `version` — authoritative |
| [`README.md`](README.md) | the `@preview/staunton:X.Y.Z` import lines; the `vX.Y.Z` tag URLs (showcase/quickstart images, manual/showcase source links); the **pinned manual download link** `releases/download/vX.Y.Z/manual.pdf`; and the top **changelog heading** — make it version-only (`### X.Y.Z`), **never** `(unreleased)` in user-facing text (see the HTML note above that heading) |
| [`docs/manual.typ`](docs/manual.typ) | the `@preview/staunton:X.Y.Z` import snippets **and** the title-page "package version" line |
| [`tests/VISUAL_CHECKS.md`](tests/VISUAL_CHECKS.md) | the cover-string eyeball item that mirrors the "package version" line |

Find them with `grep -rn "0\.1\.0"` and bump each. Leave only the *historical*
`0.1.0` mentions: the `## 0.1.0` changelog heading in README, the example in this
file, and past-findings notes. (Ignore the FEN/position examples, which are not
version strings.)

## README images

The README shows pre-rendered PNGs (Typst Universe renders the README as plain
markdown — it does **not** execute the code fences, so only real `![]()` images
display). Each lives under `docs/img/` with its Typst source beside it and the
regen command in the source header:

- `showcase-diagram.typ` / `showcase-notation.typ` / `showcase-table.typ` /
  `showcase-annotations.typ` / `showcase-marble.typ` / `showcase-wood.typ` → the
  six showcase sections (a game diagram, move notation, a standings table, an
  annotated diagram, a marble board, an inlaid-wood board);
- `quickstart-1.typ` → the "…and the basics" FEN diagram.

Keep this list in sync when you add a showcase — it is the only inventory of
which PNGs exist, and a missing entry means the image is never regenerated.

If you change a showcase code block, regenerate the matching PNG (`typst compile
--root . --format png --ppi 160 docs/img/<name>.typ docs/img/<name>.png`) and
commit it. These sheets are **not** part of `tests/run.sh`, so nothing else will
flag a drift between the code shown and the image. Worth doing here as a cheap
guard, since these sources are otherwise ungated: `for f in docs/img/*.typ; do
typst compile --root . "$f" /dev/null || echo "BROKEN $f"; done` — a public-API
rename can leave one uncompilable and it ships unnoticed. The image URLs are pinned to
the release tag (like the manual link), so they only resolve once `vX.Y.Z` is
pushed.

**Push the tag before (or together with) `main` whenever a commit ADDS a README
image.** GitHub renders the README from the *branch*, but the image URLs resolve
against the *tag* — so pushing `main` first publishes a README whose new image
404s until the tag catches up. This bit 1.0.0: the wood showcase was added after
`v1.0.0` was already cut, `main` went up first, and the front page carried a
broken image until the tag was force-moved. Note that force-moving a published
tag is only defensible while Universe has not seen that version; after the
Universe PR, a README fix needs a new version, not a moved tag.

## Publishing to Universe (upload-gated — get explicit approval each time)

1. Green suite: `bash tests/run.sh --system-fonts`. The `--system-fonts` flag is
   required at the gate: the default run passes `--ignore-system-fonts` for speed,
   which renders the kept visual sheets with fallback fonts — the gate must use the
   real fonts so those sheets are correct for the eyeball pass (`tests/VISUAL_CHECKS.md`).
1a. **Compiler-floor check.** `typst.toml`'s `compiler = "0.14.2"` is a public
    compatibility promise, not a one-off fact — re-verify it every release, since
    any `src/`-touching change since the floor was last measured could have
    silently regressed it. Re-run the gate suite against the pinned 0.14.2
    binary (versioned binaries live under
    `C:\temp\sw_setup\sw_apps\productivity\publishing\typst\typst_0_14\typst_0_14_2\`;
    prepend its directory to `PATH`, since `tests/run.sh` calls a bare `typst`).
    **The `PATH` entry must be POSIX-style** (`/c/temp/sw_setup/.../typst_0_14_2`),
    not `C:/...` — Git Bash silently ignores a Windows-style `PATH` entry, so the
    suite falls through to the 0.15 binary and reports a **false green**
    (`176/176`). Always confirm the version actually used before trusting the run:
    ```sh
    DP=/c/temp/sw_setup/sw_apps/productivity/publishing/typst/typst_0_14/typst_0_14_2
    PATH="$DP:$PATH" bash -c 'typst --version; bash tests/run.sh --system-fonts'
    ```
    Expect exactly `172/176`, with the same four understood, non-behavioral gaps: the two
    HTML-export tests (`boards_inline_svg`, `tables_native` — impossible without
    `html.frame`, 0.15+ only) and two expected-fail fixtures whose asserted
    *error wording* differs between compiler versions (`loader_outside_root`,
    `bad_by`). Any *other* delta (a different count, a different failing test) is
    a release blocker — it means something in `src/` now depends on a 0.15+
    feature without being guarded, and the compiler floor claim is false.
1b. **Drift lint (optional but cheap).** `bash scripts/lint-docs.sh` (~5s) — catches
    what compiling cannot: dangling test references in `tests/*.md`, renamed-away
    API names in `README.md`'s code fences (README is in no compile gate and is the
    Universe front page), and unreachable `src/` symbols. Deliberately not part of
    `tests/run.sh`; a release is the natural time to run it.
2. Commit the version bump and land it on GitHub.
3. Publish the GitHub Release, attaching the compiled manual as an asset (the PDF
   is a build artifact, gitignored — it is *not* committed). The README download
   link is **pinned** to `releases/download/vX.Y.Z/manual.pdf` (not `latest`), so
   the Release for `vX.Y.Z` **must** attach `manual.pdf`, and the link must be
   bumped each release (see the table above). Pinning keeps a given version's
   README pointing at *its own* manual, so a later release can't hijack the link:
   `bash scripts/build-manual.sh` then
   `gh release create vX.Y.Z docs/manual.pdf --title vX.Y.Z` (or, for an existing
   release, `gh release upload vX.Y.Z docs/manual.pdf --clobber`).
4. Build the bundle: `bash scripts/build-bundle.sh` → `dist/preview/staunton/<version>/`
   (built from a clean `git archive` of HEAD, then the `exclude` globs removed;
   it self-verifies required files are present and repo-only files didn't leak).
4a. **Smoke-test the bundle as a real package.** Step 4's checks are a file-tree
    diff — they cannot catch a broken relative path, a computed-at-runtime asset
    lookup, or anything else that only breaks once the bundle is actually
    *imported and rendered* the way a staunton user would. Run
    `bash scripts/install-local.sh`, which builds the same bundle straight into
    the local Typst package cache
    (`C:\Users\fralip\AppData\Local\typst\packages\preview\staunton\<version>\`),
    then compile a small scratch import test against it (e.g.
    `out/pkg_smoke_test.typ`, gitignored):
    ```typ
    #import "@preview/staunton:<version>": *
    #board("8/8/8/3k4/3K4/8/8/8")
    ```
    `typst compile out/pkg_smoke_test.typ out/pkg_smoke_test.pdf` must succeed
    clean. This resolves `@preview/staunton:<version>` from the installed package
    exactly as Typst Universe would (no `/lib.typ` root-relative shortcut, no
    dev-tree fallback), so it is the closest local approximation of what a real
    user's first import does. Any failure here is a release blocker.
5. Copy that `<name>/<version>` directory into a fork of
   [`typst/packages`](https://github.com/typst/packages) under
   `packages/preview/` and open a PR (prepared in the local `typst/packages` fork
   clone that has `origin` = your fork and `upstream` = `typst/packages`).
   - **Title:** `staunton:X.Y.Z` (the repo's `name:version` convention).
   - **Body: use the official PR template** (`.github/pull_request_template.md`) —
     do **not** hand-write a custom body (we did for 0.2.0/0.2.1; the maintainers
     expect the template). For an *update* release, fill it out as the template
     itself instructs: check `[x] an update for a package`, write a short
     `Description:` of the package + what changed, and **delete** the
     new-submission checklist and the template-license box (both are for new
     packages / templates only). `gh pr create --repo typst/packages --base main`
     picks up the template into the editor; keep the parts above and drop the rest.

**Order:** land on GitHub first, then submit to Universe. **Never** push to GitHub
or submit to Universe without explicit, per-time approval.
