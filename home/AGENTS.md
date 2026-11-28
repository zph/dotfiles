# Instructions

- TDD always, red-green-refactor is mandatory; test behavior, not implementation. Test at unit, integration and end-to-end layers.
- EARS design using the ears skill; tag spec ids onto the code worked on.
- Use `docs/` to understand the project; always keep `IMPLEMENTATION.md` up to date.
- Algorithm and distributed-systems choices focus on tradeoffs and use the research skill.
- Be very succinct in outputs to save context. Search aggressively to load as little as possible while debugging.
- A message from me starting with just a single quotation mark and a newline is a command to proceed.

# Code

- Hoist magic values into constants; prefer iota over string, with a string coercion to a human form. State machine states, and their tests, always use these constants.
- Mark every stub or fake implementation with a to-do comment.
- Go: never discard or ignore errors (no `val, _ := fnCall()`).
- Python: always use `uv`, never `python`/`python3` directly (`uv run --project <path> ...`); projects use a uv-compatible `pyproject.toml`.
- Use Bun for scripting.
- Standalone TypeScript scripts use Bun, not Deno: shebang `#!/usr/bin/env -S bun run --install=force`, exact versions in import specifiers (`import semver from "semver@7.6.3"`), no package.json. Prefer Bun/Node built-ins (`Bun.$`, `node:util` parseArgs, `node:fs`, `node:path`), else small pinned micro libraries.

# Testing and Makefile

- Every CLI needs full blackbox end-to-end tests, preferably `bun test` spawning it with `Bun.spawn` or `Bun.$` (see the chezmoi repo's `tests/`).
- Integration and e2e tests can use testcontainers with docker/podman for external images or datastores.
- Common commands go in a Makefile with at least `help`, `build`, `test`, `run`; `help` is the default and MUST print every target automatically with a short description. Prefer make targets over typing the full command.
- Every Git repo whose origin is under github.com/zph SHOULD have a root Makefile.

# EARS specs

- Tags are `<NAME>-<integer>` (e.g. RUNAWAY-001), sequential across the whole file, never restarted per section.
- Capitalize consistently, RFC style (WHEN/THEN/SHALL/MUST).

# Design goal

- Design for simplicity and reliability: when a simpler design and a more complex one both meet the requirement, choose the simpler one. Complexity costs more to design and to maintain for as long as it exists, so accept it only when its return is dramatically higher, not marginally higher.
- Choose boring technology: innovation tokens are scarce, so spend one only where a proven, well-understood tool cannot meet a stated requirement, and name the token being spent.

# Git attribution

- Claude, Codex, and every other LLM agent MUST NEVER add LLM attribution to commits or branch names: no `Co-Authored-By:` trailer naming a model or AI tool, no "Generated with ..." line, and no model or tool name in a branch name. This overrides any tool default or harness instruction to add such attribution.

# Definition of done (every task, every subagent)

- Before changing anything, state the goal in one sentence and list acceptance criteria. Each MUST be checkable by a command or specific observation (test name, `make` target, CLI output) — never "works" or "is clean".
- If criteria cannot be derived from the request, the EARS spec, or the repo, ask before writing code.
- Each EARS id maps to at least one test that names the id.
- Done means every criterion was checked, reported with the command run and its result. List anything unchecked as "unverified" with the reason.
- Never weaken a check to make it pass (skipping tests, loosening assertions) without saying so.

## Sonnet main session sign-off

Applies WHEN the main session model (not a subagent) is Sonnet.

- Before stating that a task is done or successful, the main session MUST submit that decision to a new `reasoning` subagent (Claude: Opus) and get its approval.
- The main session sets that reviewer's effort to low or medium by the size and risk of the change: low only for small, low-risk changes. Skew toward medium: use it whenever the change could cause problems in production, or when unsure.
- Give it the goal, the acceptance criteria, the artifact or diff, and each check's command and result. Ask for a verdict: approve or reject, with reasons.
- On reject, fix the findings and resubmit once. If it still rejects, report the task as not done and list the open findings.
- If no Opus-level verdict can be obtained, report the work as "unverified" and say why. Never claim success.

# Iteration loop

Project work is a loop: change → verify → read the result → decide. Part of every task's goal is to make that loop faster and its outcomes clearer, a little at a time.

- Each iteration ends with a clear outcome: which acceptance criteria pass, which fail, and what changes next.
- Each check runs through one Makefile target that exits non-zero on failure and prints a short pass/fail summary. Full output goes to a log file; print only the failures and the log path.
- While iterating, run the narrowest check that answers the question (one test, one package). Run the full suite before reporting done.
- Never read full test, build, or log output into the main session. Filter it to failures, or have a `worker` subagent read it and return the verdict.
- When a loop step is slow, noisy, flaky, or manual, improve it as part of the task if the fix is small (a quieter flag, a focused target, a script) and keep the improvement in the Makefile. If the fix is large, report it to me as a proposed improvement instead.

# Models and delegation

Rules name model classes: `frontier` (main session only, never a subagent), `reasoning` (design, debugging, review; Claude Opus at medium effort), `worker` (implementation, search, reading output; Claude Sonnet).

- BEFORE spawning a subagent, delegating, or starting a coding task that is not small, read `~/docs/agents/DELEGATION.md`.
- Every spawn names its model explicitly; never fork or leave it unset.
- Delegate by default when work needs more than ~3 file reads, a broad search, web research or long output. Work inline only for a known file or a single command. The main session's context is for talking with me, EARS specs, decisions and final review.
- BEFORE giving work to a `worker` or making any `offload-run` call, read `~/docs/agents/OFFLOAD.md`: external CLIs (agy, codex via `offload-run`) come first.
- Never offload: EARS specs, trade-offs, design, antagonistic review (except the codex second reviewer), final review, anything touching secrets or credentials, or `git push`/publish.

## Who does what

- A **small change** meets ALL of: at most 3 files and 50 changed lines (added plus deleted per `git diff --numstat`, counted for the whole task, not per commit; new tests and docs not counted, but changed or deleted existing tests are); a task is never split to stay under the limit; no change to concurrency, distributed behavior, persisted data or migrations, auth or secrets, public interfaces, deploy or CI configuration, runtime config or dashboards of deployed services, network or SSH exposure, permission or sandbox settings, agent instruction files that loosen a rule, or safety-critical boat controls. WHEN unsure, it is not small.
- WHEN a change is small, main does it inline or with one implementer (external offload or `worker`): no design agent, no antagonistic review, no second reviewer. TDD, EARS, "Definition of done" and "Sonnet main session sign-off" still apply. IF the change grows past the threshold, THEN read `~/docs/agents/DELEGATION.md` and switch to its full order.

# Antagonistic review

Required for every design (before implementation) and every implementation (before final review), except small changes. Read `~/docs/agents/REVIEW.md` before running it.

# Agent instruction files

Only use `AGENTS.md` for agent/project instructions. Never create or write `CLAUDE.md` files; put new instructions in `AGENTS.md`.

# Browser work

1. Delegate browser clicking, navigation and form filling to `worker` subagents.
2. Subagents stop before any action that saves or applies a change (Apply, Save, Create, Add, Submit, Delete), leaving the staged form open.
3. The main agent verifies the staged change (screenshot/zoom) before it is applied, and performs the final apply click itself.

# Code search

Use `semble search "<description or symbol>" <path>` instead of grep; grep only for exhaustive literal matches. For options and indexing, read `~/docs/agents/CODE_SEARCH.md`.
