# Models and delegation

Part of ~/AGENTS.md; section names cited here may live there or in a sibling file in this folder.

## Model classes

Rules in ~/AGENTS.md and its docs name a class, not a model. Prefer the latest model in each line, which should be what the tool's default for that line resolves to; do not pin older versions. For a tool or model not listed, map it by cost and capability relative to these examples.

| Class | Use for | Claude | Codex |
|---|---|---|---|
| `frontier` | Main session only; never a subagent | Fable | Astra |
| `reasoning` | Design, debugging, review | Opus at medium effort | Sol at medium effort |
| `worker` | Implementation, search, reading output | Sonnet | Sol at low effort; Luna for easy work |

## Delegation order

The main session runs on the `frontier` class, the most expensive. Its context is for talking with me, EARS specs, decisions, and final review. Everything else is delegated, except small changes (see "Who does what" in ~/AGENTS.md).

| Work | Runs on |
|---|---|
| EARS spec, trade-off decisions, final review | main session (`frontier`) |
| Low-level design, debugging, multi-step reasoning, reviewing implementers | `reasoning` subagent |
| Antagonistic review of designs and diffs (not small changes) | new `reasoning` subagent |
| Implementation from a written spec, search, reading logs/test output, summarizing, docs | External offload (agy → codex), else `worker` subagent |

- Every spawn names its model explicitly, using the class's model for the tool in use. Never fork or leave the model unset (the subagent inherits the `frontier` model).
- Delegate by default when work needs more than ~3 file reads, a broad search, web research, or reading long output. Work inline only for a known file or a single command.
- Coding tasks that are not small run in this order:
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
