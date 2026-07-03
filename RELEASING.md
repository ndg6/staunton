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
| [`README.md`](README.md) | the two `@preview/staunton:X.Y.Z` import lines |
| [`docs/manual.typ`](docs/manual.typ) | the import snippet **and** the title-page "package version" line |

Find them with `grep -rn "0\.1\.0"` (ignore the FEN/position examples, which are
not version strings).

## Publishing to Universe (upload-gated — get explicit approval each time)

1. Green suite: `bash tests/run.sh`.
2. If `docs/manual.typ` changed, rebuild and re-stage the tracked PDF so the repo
   copy doesn't drift:
   `typst compile --root . docs/manual.typ docs/manual.pdf && git add docs/manual.pdf`.
3. Commit the version bump.
4. Build the bundle: `bash scripts/build-bundle.sh` → `dist/preview/staunton/<version>/`
   (built from a clean `git archive` of HEAD, then the `exclude` globs removed;
   it self-verifies required files are present and repo-only files didn't leak).
5. Copy that `<name>/<version>` directory into a fork of
   [`typst/packages`](https://github.com/typst/packages) under
   `packages/preview/` and open a PR.

**Order:** land on GitHub first, then submit to Universe. **Never** push to GitHub
or submit to Universe without explicit, per-time approval.
