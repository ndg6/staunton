#!/usr/bin/env bash
# Static drift checks for the AGENT MACHINERY -- .claude/skills/*/SKILL.md and
# .claude/agents/*.md.
#
# Companion to lint-docs.sh, which checks the package's docs. This one checks the
# instructions that DRIVE the package's workflows. Those files are prose to every
# compiler, so a path that stops existing, an agent that gets renamed, or a
# measured number that goes stale is invisible until someone follows the
# instruction mid-release and it does not work.
#
# Motivating find (machinery audit, 2026-08-01): the release skill and
# RELEASING.md both said "Expect exactly 172/176" for the compiler-floor run.
# That was a SNAPSHOT: the suite was already 177 on an open branch, so the next
# merge would have turned the floor check into a phantom release blocker --
# training the reader to wave it through, which is exactly how a real floor
# regression would later slip past. Hence check 3.
#
# A STANDALONE tool, deliberately not wired into tests/run.sh -- same reasoning
# as lint-docs.sh: this is drift, not a regression.
#
# Usage:  bash scripts/lint-skills.sh
#
# NOTE: .claude/ is git-excluded (local-only), so on a fresh clone there is
# nothing to check and this exits clean rather than failing.
#
# WHEN ADDING A CHECK: verify it by PLANTING a regression and watching it go red.
# Both of this repo's lint scripts have shipped checks that could not fail --
# lint-docs.sh had two on its first draft, and its README check was still
# silently broken months later. A check that cannot fail looks exactly like a
# check that passes.
#
# PERFORMANCE: single-pass greps, per-item work inside awk/shell loops over
# already-collected output. Process spawning dominates runtime under MSYS.
set -eu
cd "$(dirname "$0")/.."

export LC_ALL=C

fail=0
FINDINGS=$(mktemp)
trap 'rm -f "$FINDINGS"' EXIT

run_check() {
  name="$1"; shift
  printf '== %s ==\n' "$name"
  : > "$FINDINGS"
  "$@" > "$FINDINGS" || true
  if [ -s "$FINDINGS" ]; then sed 's/^/  /' "$FINDINGS"; fail=$((fail + 1)); fi
}

SKILL_FILES=$(ls .claude/skills/*/SKILL.md .claude/agents/*.md 2>/dev/null || true)

if [ -z "$SKILL_FILES" ]; then
  echo "lint-skills: no .claude/ machinery present (local-only) -- nothing to check"
  exit 0
fi

# ---------------------------------------------------------------------------
# 1. Every repo path an instruction names must exist.
#    An instruction pointing at a moved or deleted file fails at the worst
#    possible moment: mid-workflow, when someone is following it literally.
#    Trailing sentence punctuation is stripped -- "see docs/manual.typ." names
#    a real file, and flagging it would be a false positive that teaches people
#    to ignore this check. PLACEHOLDER paths (dist/.../X.Y.Z/, <version>) are
#    templates, not references, and are skipped for the same reason.
# ---------------------------------------------------------------------------
check_paths() {
  grep -ohE '\b(scripts|tests|docs|src|prompts|bench|dist)/[A-Za-z0-9_/.*-]+' $SKILL_FILES \
    | sed 's/[.,;:)]*$//' | sort -u \
    | while read -r p; do
        case "$p" in
          *X.Y.Z*|*'<'*|*VERSION*|*N.N.N*) ;;   # template, not a real path
          *"*"*) ls $p >/dev/null 2>&1 || echo "MISSING (glob matches nothing): $p" ;;
          *)     [ -e "$p" ] || echo "MISSING: $p" ;;
        esac
      done
}
run_check "paths named by skills/agents exist" check_paths

# ---------------------------------------------------------------------------
# 2. Every agent a skill spawns must have a definition.
#    A skill that spawns a renamed-away agent fails only when that branch of the
#    workflow is reached -- often the delegation step of a long release.
# ---------------------------------------------------------------------------
check_agents() {
  defined=$(ls .claude/agents/*.md 2>/dev/null | sed 's|.*/||; s|\.md$||' | tr '\n' ' ')
  grep -ohE '`(scout|dev|test-engineer|verifier|reviewer|doc-writer|release-auditor|[a-z][a-z-]*-(agent|auditor|writer|engineer))`' \
    .claude/skills/*/SKILL.md 2>/dev/null | tr -d '`' | sort -u \
    | while read -r a; do
        case " $defined " in *" $a "*) ;; *) echo "NO SUCH AGENT: $a (spawned by a skill)" ;; esac
      done
}
run_check "agents spawned by skills are defined" check_agents

# ---------------------------------------------------------------------------
# 3. No hard-coded pass totals.
#    THE rot pattern. An expectation like "expect exactly 172/176" is true the
#    day it is written and wrong the next time the suite grows -- and the
#    instruction around it usually says "any other delta is a blocker", so the
#    stale number does active harm. Assert on NAMES and identities, never counts.
#    Version numbers (1.0.0, 0.14.2) and section refs are not totals; the pattern
#    below matches N/M and passed=/failed= forms only. Two deliberate exemptions:
#    `failed=0` is an INVARIANT (zero failures never rots, unlike `passed=176`),
#    and lines flagged as historical ("previously read", "until <date>") are
#    describing rot that was already fixed -- flagging the fix's own explanation
#    would make the check unusable.
# ---------------------------------------------------------------------------
check_counts() {
  grep -nE '(exactly[[:space:]]+`?[0-9]+/[0-9]+|passed=[0-9]+|failed=[0-9]+|[0-9]+[[:space:]]+of[[:space:]]+[0-9]+[[:space:]]+tests)' \
    $SKILL_FILES RELEASING.md 2>/dev/null \
    | grep -vE 'failed=0|never a pass total|not.*a total|snapshot|NOT a count'     | grep -vE 'previously|used to read|until [0-9]{4}|no longer|was already' \
    | sed 's/^/HARD-CODED COUNT: /'
}
run_check "no hard-coded pass totals in skills/RELEASING" check_counts

# ---------------------------------------------------------------------------
# 4. run.sh flags named by instructions must exist in run.sh's usage line.
#    A flag that gets renamed leaves instructions that silently do nothing --
#    `--system-fonts` in particular changes what the eyeball pass actually shows.
# ---------------------------------------------------------------------------
check_flags() {
  usage=$(grep -m1 'Usage:.*run\.sh' tests/run.sh 2>/dev/null || true)
  [ -n "$usage" ] || { echo "run.sh has no 'Usage:' line -- check 4 cannot verify anything"; return 0; }
  grep -ohE 'run\.sh[^`"'"'"']*' $SKILL_FILES RELEASING.md 2>/dev/null \
    | grep -oE '[[:space:]]--[a-z][a-z-]+' | tr -d ' ' | sort -u \
    | while read -r f; do
        case "$usage" in *"$f"*) ;; *) echo "UNKNOWN run.sh FLAG: $f (not in run.sh usage line)" ;; esac
      done
}
run_check "run.sh flags used by instructions exist" check_flags

echo "----------------------------------------"
if [ "$fail" -eq 0 ]; then
  echo "lint-skills: clean"
else
  echo "lint-skills: $fail check(s) FAILED"
fi
[ "$fail" -eq 0 ]
