Part of ~/AGENTS.md; section names cited here may live there or in a sibling file in this folder.

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
- **Brief:** write it to a file in the scratchpad and pass `@<path>`. Use the brief format from "Delegation order" in ~/docs/agents/DELEGATION.md: goal, acceptance criteria with the check command, files in scope, what's ruled out, and a return format of at most 30 lines. Put the artifact itself (design text or diff) in the brief instead of pointing at live files, so the input can't change mid-run.
- **Output:** agy writes everything to `<out-file>`. codex writes its final message to `<out-file>` and its progress to `<out-file>.log`. Use a new file name for every run. Claude reads only the last 30 lines or a grep of the failures, never the whole log.
- **Edits:** `edit` needs a clean git tree, so commit or use a worktree first. Run at most one edit-mode attempt per tree at a time.
- **Verification:** Claude runs the acceptance command (the `make` target) and checks `git diff --stat`. Claude also reads the diff of any test, Makefile or CI file the worker touched, so the worker can't pass by weakening checks. Otherwise Claude doesn't re-read its work or trust the CLI's own report.
- **Fallback:** on a non-zero exit (3 is agy auto-denying a tool, 124 is a timeout) or a quota or auth error, stash the failed attempt's changes (`git stash push -u -m "failed offload: <tier>"`), then move to the next tier once and say so in one line. Don't retry the same tier in a loop.
- **Threshold:** only offload when the task would cost more than about 3 file reads or a long output. A handoff still costs Claude tokens for the brief plus the result.
