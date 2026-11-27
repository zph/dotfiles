# Instructions

1. Always use TDD approach to building
2. EARS design using our ears skill
3. Tag ears spec ids onto the code area worked on for a given task
4. Use docs/ folder for understanding the project and keep an upto date IMPLEMENTATION.md doc
5. Common commands for project should be added to a Makefile that includes `help` as the default
   target

**Remember:**
- 🧪 Test first, EARS always, trace everything
- 🎯 Test behavior, not implementation
- 📋 **Always update IMPLEMENTATION.md**
- 🔄 Red-Green-Refactor loop is mandatory
- Technical choices for algorithms and distributed systems behavior should focus on the tradeoffs involved and use research skill.
**Test Driven Development TDD**
- Implement testing at various layers: unit tests, integration tests, end to end tests
- Anything with a cli interface must also have full blackbox end to end tests, preferrably using
`bun test` as the harness, spawning the CLI as a subprocess with `Bun.spawn` or `Bun.$`
(see the chezmoi repo's `tests/` for examples)
- Standalone TypeScript scripts use Bun, not Deno: shebang `#!/usr/bin/env -S bun run --install=force`,
with exact versions in import specifiers (e.g. `import semver from "semver@7.6.3"`) and no
package.json. Prefer Bun/Node built-ins (`Bun.$`, `node:util` parseArgs, `node:fs`, `node:path`)
over libraries; otherwise use small pinned micro libraries.
- Integration and end to end tests can use testcontiners with docker/podman if needing external
images or datastores.
- Running tests is often possible from the Makefile and so is building binaries. Use makefile
commands preferentially instead of writing out and executing the full command. It's important for
consistency and correctness.

**Makefile and common tasks**
- Makefile should at a minimum have the following targets: help, build, test, run
- The `help` target MUST print every target automatically, with a short description of each.
- Every Git repo whose origin is under github.com/zph SHOULD have a Makefile at its root.

**EARS Specifications**
- Tags must be in the form <NAME>-<sequential integer>
- example: RUNAWAY-001
- Be consistent in the capitalization and non capitalization, prefer RFC type captilization
where WHEN/THEN/SHALL/MUST are capitalized
- The sequential integers must be sequential for the full file and MUST not be restarted per
section

**Constants**
- Magic values in code should become constants and prefer iota > string for constants but offer
a string coercion to a human form.
- State machine states should always use these defined constants and so should tests
- Any time you see me start a message with just the single quotation mark and an enter, I want you to treat that as a command to proceed.
- Prefer to hoist out values as constants rather than littering them about the code as strings or magic numbers.
- Be very succinct in outputs to me to avoid using up context
- Use search tools aggressively to minimize how much context you load while debugging
- If you are stubbing something out and not doing the real implementation, you must always mark it with a to-do comment.
- Must never throw away or ignore error responses in golang. It's bad to do `val, _ := fnCall()`

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

## Model classes

Rules in this file name a class, not a model. Prefer the latest model in each line, which should be what the tool's default for that line resolves to; do not pin older versions. For a tool or model not listed, map it by cost and capability relative to these examples.

| Class | Use for | Claude | Codex |
|---|---|---|---|
| `frontier` | Main session only; never a subagent | Fable | Astra |
| `reasoning` | Design, debugging, review | Opus at medium effort | Sol at medium effort |
| `worker` | Implementation, search, reading output | Sonnet | Sol at low effort; Luna for easy work |

## External offload (cheapest first)

Grunt work that runs on Claude's `worker` class goes to an external CLI first, to save Claude tokens.
Use the first tier whose check passes:

| Tier | Check | Why |
|---|---|---|
| 1 agy (Antigravity) | `command -v offload-run && command -v agy` | Prepaid Google credits that expire monthly |
| 2 codex | `command -v offload-run && command -v codex` | Paid subscription, but cheaper for me than Claude |
| 3 Claude `worker` subagent | — | Fallback |

**Call:** `offload-run [-C <project-dir>] [-t <seconds>] <agy|codex> <read|review|edit> <abs-out-file> @<abs-brief-file>`

- **Modes:** `read` is search, summarizing and reading logs (read-only, low effort). `review` is antagonistic review (read-only, medium effort). `edit` is implementation from a written spec (agy `accept-edits`, codex `workspace-write`).
- **Only route:** `~/bin/offload-run` is the only way to call agy or codex. Deny rules in settings block direct calls. Neither CLI can start inside Claude's sandbox, so the sandbox excludes `offload-run`, and the script enforces its own guards: pinned binaries, agy `--sandbox`, codex's own sandbox with no MCP servers, brief and output files only under `/private/tmp/claude-<uid>/` (no symlinks; the output file must not already exist), a clean git tree for `edit`, and a hard timeout (default 900s) that kills the whole process group.
- **Bare call only:** the sandbox exclusion applies only to a single `offload-run` command with literal absolute paths. No `$TMPDIR` or other variables, no `VAR=value` prefix, no pipes, redirects, `cd` or `$(...)`, or the call stays sandboxed and the CLI fails. Write out the scratchpad path, and use `-C` instead of `cd` and `-t` instead of env vars.
- **agy limits:** headless agy can't answer its own permission prompts, so it auto-denies shell commands and file access outside the project and then stops (`offload-run` exits 3). Give agy only in-project file work: edits, search, summarizing files you name inside the project. Work that needs shell commands, such as running tests or reading logs elsewhere, goes to codex.
- **Offload:** mechanical edits from a written spec, boilerplate and test scaffolding, renames and reformatting, broad search, summarizing logs or test output, doc updates, browser-free research.
- **Never offload:** EARS specs, trade-off decisions, design, antagonistic review (except the second reviewer described under "Antagonistic review"), final review, and anything that touches secrets or credentials, or runs `git push`/publish.
- **Brief:** write it to a file in the scratchpad and pass `@<path>`. Use the brief format from "Who does what": goal, acceptance criteria with the check command, files in scope, what's ruled out, and a return format of at most 30 lines. Put the artifact itself (design text or diff) in the brief instead of pointing at live files, so the input can't change mid-run.
- **Output:** agy writes everything to `<out-file>`. codex writes its final message to `<out-file>` and its progress to `<out-file>.log`. Use a new file name for every run. Claude reads only the last 30 lines or a grep of the failures, never the whole log.
- **Edits:** `edit` needs a clean git tree, so commit or use a worktree first. Run at most one edit-mode attempt per tree at a time.
- **Verification:** Claude runs the acceptance command (the `make` target) and checks `git diff --stat`. Claude also reads the diff of any test, Makefile or CI file the worker touched, so the worker can't pass by weakening checks. Otherwise Claude doesn't re-read its work or trust the CLI's own report.
- **Fallback:** on a non-zero exit (3 is agy auto-denying a tool, 124 is a timeout) or a quota or auth error, stash the failed attempt's changes (`git stash push -u -m "failed offload: <tier>"`), then move to the next tier once and say so in one line. Don't retry the same tier in a loop.
- **Threshold:** only offload when the task would cost more than about 3 file reads or a long output. A handoff still costs Claude tokens for the brief plus the result.

## Who does what

The main session runs on the `frontier` class, the most expensive. Its context is for talking with me, EARS specs, decisions, and final review. Everything else is delegated.

| Work | Runs on |
|---|---|
| EARS spec, trade-off decisions, final review | main session (`frontier`) |
| Low-level design, debugging, multi-step reasoning, reviewing implementers | `reasoning` subagent |
| Antagonistic review of designs and diffs | new `reasoning` subagent |
| Implementation from a written spec, search, reading logs/test output, summarizing, docs | External offload (agy → codex), else `worker` subagent |

- Every spawn names its model explicitly, using the class's model for the tool in use. Never fork or leave the model unset (the subagent inherits the `frontier` model).
- Delegate by default when work needs more than ~3 file reads, a broad search, web research, or reading long output. Work inline only for a known file or a single command.
- Coding tasks run in this order:
  1. Main writes EARS + interfaces.
  2. One `reasoning` agent produces the low-level design.
  3. Antagonistic review of the design.
  4. The `reasoning` agent spawns `worker` implementers and reviews them.
  5. Antagonistic review of the diff.
  6. Main reviews the final diff.
- Every brief contains: goal, acceptance criteria and the command that checks them, files in scope, what is already ruled out, and the return format.
- Subagents return at most 30 lines: conclusion, `file:line` references, commands run with pass/fail. Long output goes to a file; return the path.
- Run independent subagents in parallel in one message.
- Main verifies a subagent's claim by running the acceptance command, not by re-reading its work.

# Antagonistic review

Standard for every design (before implementation starts) and every implementation (before main's final review).

- Main spawns a new `reasoning` subagent as the reviewer. It MUST NOT be the designer, an implementer, or the agent that reviewed them: those are anchored by the long process that produced the work and inherit its logic flaws.
- Give it only the EARS spec, the acceptance criteria, and the artifact (design doc or diff). Withhold the authors' reasoning, summaries, and review conclusions.
- WHEN `offload-run` and `codex` are installed, main also runs a second reviewer from a different model family, in parallel with the first and with the same inputs and rules: `offload-run codex review <abs-scratch>/codex-review-<n>.out @<abs-scratch>/review-brief.md` (a bare call, as "External offload" requires). The brief holds the EARS spec, the acceptance criteria, and a frozen copy of the artifact (the design text or the diff itself, not a path or a live `git diff` range), so both reviewers see identical input. Main merges both reviewers' findings and drops duplicates. If codex fails or runs out of quota, continue with the Claude reviewer alone and say so in one line.
- Its job is to break the work, not approve it: logic flaws, unmet or untested EARS ids, tests that pass without exercising the behavior, unhandled failure and concurrency cases, assumptions the spec does not support.
- Each finding has a `file:line` or design section, a concrete failure scenario (inputs/state → wrong result), and a severity. "No findings" MUST list what was checked.
- Main decides which findings stand and sends fixes back to the authors. Re-review once after fixes, then report any still-open findings to me rather than looping.

# Python

- **Always use `uv`** for all Python execution. Never invoke `python3` or `python` directly.
- Makefile targets, scripts, and commands should use `uv run --project <path> python ...` or `uv run --project <path> <entry-point>`.
- Python projects use `pyproject.toml` with uv-compatible configuration.

# Agent instruction files
1. Only use `AGENTS.md` for agent/project instructions. Never create or write to `CLAUDE.md` files; put new instructions in `AGENTS.md` instead.

# Browser work
1. Delegate browser clicking/navigation/form-filling to cheaper subagents (`worker` class) instead of doing it in the main agent.
2. Subagents must stop before any action that saves or applies a change (Apply, Save, Create, Add, Submit, Delete) and leave the staged form open.
3. The main agent verifies the staged change (screenshot/zoom of the form) before it is ever applied, and performs the final apply click itself.

# Code Search

Use `semble search` to find code by describing what it does or naming a symbol/identifier, instead of grep:

​```bash
semble search "authentication flow" ./my-project
semble search "save_pretrained" ./my-project
semble search "save model to disk" ./my-project --top-k 10
​```

If you anticipate doing more than one search, use `semble index` to create an index.

​```bash
semble index ./my-project -o my_index
​```

You can then reuse this index later on:

​```bash
semble search "save_pretrained" --index my_index
​```

An index is not automatically updated, so if the code changes significantly, reindex. If you notice stale results while resolving searches to files, reindex.

Use `--content docs` to search documentation and prose, `--content config` for config files (yaml, toml, etc.), or `--content all` to search code, docs, and config:

​```bash
semble search "deployment guide" ./my-project --content docs
semble search "database host port" ./my-project --content config
semble search "authentication" ./my-project --content all
​```

Use `semble find-related` to discover code similar to a known location (pass `file_path` and `line` from a prior search result):

​```bash
semble find-related src/auth.py 42 ./my-project
​```

Like search, `find-related` also accepts an `--index` argument.

`path` defaults to the current directory when omitted; git URLs are accepted.

If `semble` is not on `$PATH`, use `uvx --from "semble[mcp]" semble` in its place.

### Workflow

1. Index the repo using `semble index -o cached_index`.
2. Start with `semble search` to find relevant chunks. Pass the index to achieve results faster.
3. Use `--content docs` for documentation, `--content config` for config files, or `--content all` for everything.
4. Inspect full files only when the returned chunk does not give enough context.
5. Optionally use `semble find-related` with a promising result's `file_path` and `line` to discover related implementations.
6. Use grep only when you need exhaustive literal matches or quick confirmation of an exact string.
