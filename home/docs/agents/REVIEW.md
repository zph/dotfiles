Part of ~/AGENTS.md; section names cited here may live there or in a sibling file in this folder.

# Antagonistic review

Standard for every design (before implementation starts) and every implementation (before main's final review), except a small change as defined under "Who does what".

- Main spawns a new `reasoning` subagent as the reviewer. It MUST NOT be the designer, an implementer, or the agent that reviewed them: those are anchored by the long process that produced the work and inherit its logic flaws.
- Give it only the EARS spec, the acceptance criteria, and the artifact (design doc or diff). Withhold the authors' reasoning, summaries, and review conclusions.
- WHEN `offload-run` and `codex` are installed, main also runs a second reviewer from a different model family, in parallel with the first and with the same inputs and rules: `offload-run codex review <abs-scratch>/codex-review-<n>.out @<abs-scratch>/review-brief.md` (a bare call, as "External offload" requires). The brief holds the EARS spec, the acceptance criteria, and a frozen copy of the artifact (the design text or the diff itself, not a path or a live `git diff` range), so both reviewers see identical input. Main merges both reviewers' findings and drops duplicates. If codex fails or runs out of quota, continue with the Claude reviewer alone and say so in one line.
- Its job is to break the work, not approve it: logic flaws, unmet or untested EARS ids, tests that pass without exercising the behavior, unhandled failure and concurrency cases, assumptions the spec does not support.
- Each finding has a `file:line` or design section, a concrete failure scenario (inputs/state → wrong result), and a severity. "No findings" MUST list what was checked.
- Main decides which findings stand and sends fixes back to the authors. Re-review once after fixes, then report any still-open findings to me rather than looping.
