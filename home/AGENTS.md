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
deno as a wrapper for the test harness (see https://github.com/zph/tome-cli/tree/main/test)
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

## Who does what

The main session runs on the `frontier` class, the most expensive. Its context is for talking with me, EARS specs, decisions, and final review. Everything else is delegated.

| Work | Runs on |
|---|---|
| EARS spec, trade-off decisions, final review | main session (`frontier`) |
| Low-level design, debugging, multi-step reasoning, reviewing implementers | `reasoning` subagent |
| Antagonistic review of designs and diffs | new `reasoning` subagent |
| Implementation from a written spec, search, reading logs/test output, summarizing, docs | `worker` subagent |

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
