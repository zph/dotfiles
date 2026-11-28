# Implementation notes

## LLM quota nudge

Run `~/bin/llm-quota-nudge {claude|codex|agy} [model]` once per scheduled invocation.
The script uses Bun (`brew install bun`). With a minimal scheduler PATH, invoke it as
`/opt/homebrew/bin/bun run ~/bin/llm-quota-nudge {claude|codex|agy} [model]`.
Each call uses the selected CLI's current login and sends one short headless prompt.
Defaults are Haiku, GPT-6 Luna at low effort, and Gemini 4 Hydrogen Low.
Run `make test-llm-quota-nudge` for the CLI checks (NUDGE-001..005).
