---
name: iterate
description: Build a non-trivial feature in commitable, verifiable slices, with a sub-agent reviewing each slice's diff against its commit message before it lands. The user gates the plan and any forks; the sub-agent gates each commit. Use when the user asks to build/implement/add a multi-step feature, kick off a "let's do this iteratively" workflow, break a large task into reviewable chunks, or wants to drive implementation with feedback checkpoints rather than a single-shot deliverable. Also use when the user has just shared a multi-step spec or migration and wants to start working through it.
---

# Iterate: feature build with explicit feedback gates

You are driving a multi-slice feature implementation. The user reviews and approves the *plan* up front (Phase 2) and decides at *forks* (Phase 4); between slices, an independent sub-agent reviewer gates each commit (Phase 3) — the user does not approve every diff. Optimize for **convergence with the user's intent**, not for shipping fast.

## When to invoke this

Use this skill when:
- The user asks to implement a feature that's clearly more than one commit.
- The user uses words like "iteratively," "in slices," "with checkpoints," "step by step."
- You've just received a spec, schema, or migration and the user wants to start working through it.

**Don't** use this skill for:
- Single-file edits, typo fixes, or single-commit changes.
- Pure research or exploration tasks (use Explore agent or just answer).
- Tasks where the user has explicitly said "just do it" / "one-shot it."

## Phase 1 — Ground before designing

Before proposing any plan, do these in parallel:

1. **Find prior art.** Search git history and the codebase for the closest existing solution to the same shape. Cite specific files/commits. Reuse beats reinvent.
2. **Verify current state.** Confirm branch, HEAD, working tree, what files actually exist. Don't build on assumed state.
3. **Get the concrete contracts.** Real DDL, real API responses, real config — whatever the feature depends on. Don't infer schemas from names.

If any of those three are unclear, **ask before proposing the plan**. A plan built on wrong assumptions wastes more time than the questions take.

## Phase 2 — Propose a slice plan

A slice plan is a numbered list. Each slice has exactly three fields:

```
N. Slice title
   - Changes: files + one-line purpose for each
   - Verify: the specific ruff/mypy/pytest invocation that gates it (or the test that doesn't exist yet but will)
   - Commit message: subject line, no body yet
```

Constraints on slicing:
- Each slice must leave the system runnable. No partial implementations.
- Aim for slices that produce one commit of ≤300 lines. Bigger → split.
- The first slice is usually scaffolding (deps, package skeleton, test harness).
- Cross-cutting concerns (test markers, dep upgrades, lint config) get their own slice if they're not trivially folded.

Present the whole plan. **Wait for explicit "go" before starting Slice 1.** Open the floor for re-slicing.

## Phase 3 — Slice loop

For each slice, in order:

1. **Write the code.**
2. **Run gates.** Full scope (`packages/<x>` not `packages/<x>/tests/unit`), default verbosity (no `-q`). All warnings visible.
3. **If anything is red**, fix and re-run. Don't proceed with anything failing.
4. **Spawn a sub-agent reviewer.** An independent, cold-start `general-purpose` agent judges the diff against the proposed commit message. **The prompt is essentially the commit message and nothing else** — see template below. The reviewer runs gates itself; you do not pre-summarize what changed.
5. **On `LGTM — ship it`**, stage and commit, move to the next slice. **On `Fix blockers then ship`**, address the verdict and re-spawn a **fresh** reviewer with the same minimal prompt. Don't carry context forward across review rounds — every round starts cold.

Between slices, if scope shifts or you learn something that changes the slice plan, **re-evaluate the plan explicitly with the user** before continuing. Show the diff against the original plan.

### What the reviewer gets — and does not get

**Gets:**
- The proposed commit message (subject + body), verbatim.
- The working-tree diff (the reviewer runs its own `git diff`).
- The repo to grep / read / execute gates against.
- The default gate commands implicit in "project's verification" (ruff / mypy / the relevant pytest scope).

**Does NOT get:**
- A summary of what changed.
- A list of files modified.
- A recap of which gates you already ran or what they output.
- Suggested review areas or "things to watch for."
- Any explanation of why this slice exists or how it fits the larger plan.

If the commit message can't sustain an independent review on its own, the **message** needs work — not the prompt. Pre-loading the reviewer with your framing defeats the purpose; they stop reviewing and start ratifying.

### Reviewer prompt template

Use this verbatim. The only thing to substitute is the commit message.

```
Review the current uncommitted diff in this repository against the
proposed commit message below. Run the project's default verification
gates (ruff, mypy, the relevant pytest scope) yourself. Reply with one
of:
  - LGTM — ship it
  - Fix blockers then ship
  - Reconsider approach
Be tight.

Proposed commit message:
---
<subject>

<body>
---
```

Related auto-memory rules: [[feedback-sub-agent-slice-review]] (per-slice review spawn), [[feedback-review-commit-per-slice]] (review + commit is implicit per slice, not its own todo).

## Phase 4 — Force decisions at forks

When you hit a real fork (validation strategy, dep choice, refactor scope), do NOT pick silently. Present options as a table:

```
A. <name> — <one-line tradeoff>
B. <name> — <one-line tradeoff>
C. <name> — <one-line tradeoff>

Recommendation: <one> because <one sentence>.
```

Two to four options, with concrete costs. Recommend one. Wait for the user to pick. Forks include:
- Refactor scope (touch sibling package? extract module? both?)
- Validation strictness (strict / lenient / hybrid)
- Test fixture shape (mock / testcontainer / real backend)
- Cleanup vs. defer (fix the unrelated noise now, or file it as follow-up?)

Don't ask open questions ("what do you think?"). Ask closed ones.

## Phase 5 — Capture corrections as durable rules

When the user corrects you on **how you worked** (not just what you built):

1. Acknowledge in one line.
2. Save the rule to memory immediately (use the auto-memory system — write `~/.claude/projects/<dir>/memory/feedback-<slug>.md` and link from `MEMORY.md`).
3. Apply the rule to all subsequent slices in this session and future sessions.

Examples of corrections that become rules:
- "Do not commit before validation" → gates pass + sub-agent review LGTM before any `git commit`.
- "Skipping is not fixing" → tests that auto-skip when env isn't right are silent failure; make them actually run.
- "Any manual smoke should be a test" → verification belongs in pytest/ruff/mypy, not in copy-paste recipes.

The point is that the **next** mistake in the same shape doesn't happen, not just this one.

## Phase 6 — Test against reality early

Even with thorough mocked tests, build a real-environment smoke path **into** the work, not after it:
- A `--dry-run` flag that exercises the production path without side effects.
- An integration test that stands up a real backend via testcontainers.
- A `make smoke` or equivalent that runs against a dev cluster.

Run that smoke against the actual target as early as you reasonably can. The first real-environment run finds bugs no test caught — better in slice 6 than in deploy.

## Verification discipline (load-bearing)

These are non-negotiable. They produce the convergence:

- **Verification is automated tests, period.** If you find yourself writing a manual check recipe ("just run `psql ...`"), you have a missing test. Write the test instead.
- **Run the full scope** — don't narrow to `/unit` to avoid noise. If integration tests are noisy, mark/exclude them properly via pytest markers and a conftest hook.
- **Never suppress warnings.** No `2>&1 | grep -v`, no `--quiet`, no `unset VAR`-to-mute. Warnings are signal; address the root cause or surface them honestly.
- **Honest test commands.** Show the user the actual command you ran and the actual count of passed/skipped/failed.

## Commit message discipline

- Subject ≤72 chars, scoped (`feat(scope): ...`, `fix(scope): ...`, `chore(scope): ...`).
- Body: 2–5 lines, explains WHY and any non-obvious decisions. No rehashing the diff. No iteration breadcrumbs ("Slice 5.5b"). No how-to-run recipes (that's the README's job).
- For trivial changes (rename, typo, formatting), the body can be empty.

## Pause is the default — at the right gates

User pauses are reserved for *decisions*, not per-commit approvals. Wait for the user when:

- The slice plan has been proposed and Slice 1 hasn't started yet (Phase 2).
- You hit a real fork: validation scope, dep choice, refactor reach (Phase 4).
- Mid-execution learning changes the slice plan (Phase 3 re-evaluate clause).

Between slices, the **sub-agent reviewer is the gate** (Phase 3). No "awaiting commit instruction" line, no proactive "ready to ship?" question. The user can always interrupt — that's their prerogative — but the default loop runs review → fix → commit without checking back.

## Failure modes to watch for in yourself

1. **Recipe creep.** "Just run `podman build` to verify" sneaks back unless explicitly disallowed.
2. **Verbosity spiral.** Slice reports grow to 20-row tables and three-paragraph commit bodies. Brevity needs active enforcement.
3. **Silent-skip masquerading as success.** Skip-on-error tests look green but provide zero signal. Make them fail loudly.
4. **Forking-by-stealth.** Realizing mid-slice that a refactor decision was needed, making it yourself, then mentioning it in the report. Surface forks before deciding.

## Closing the loop

When all slices land:
- Recap the final state (commit list, what's deployable, what's deferred).
- List any open inputs / follow-ups explicitly.
- Don't celebrate — the test is whether the user agrees the work is done.
