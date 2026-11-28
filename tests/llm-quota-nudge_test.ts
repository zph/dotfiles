import { expect, test } from "bun:test";
import { mkdtempSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { delimiter, dirname, join } from "node:path";

const script = join(import.meta.dir, "../home/bin/executable_llm-quota-nudge");
const prompt = "Reply with only OK. Do not use tools.";

// WHEN given a provider, the CLI SHALL send one headless prompt using its lightweight
// default (NUDGE-001) or the supplied model (NUDGE-002).
// WHEN given invalid arguments, the CLI SHALL print usage and exit 2 (NUDGE-003).
// WHEN the provider exits, the CLI SHALL report its response and exit status (NUDGE-004).
// WHEN launched with an absolute Bun path, the CLI SHALL work even if Bun is absent from PATH (NUDGE-005).
function run(args: string[], exitCode = 0, explicitBun = false) {
  const bin = mkdtempSync(join(tmpdir(), "quota-nudge-test-"));
  try {
    for (const provider of ["claude", "codex", "agy"]) {
      // TODO: replace these fakes with authenticated CLIs for a live quota check.
      writeFileSync(
        join(bin, provider),
        '#!/bin/sh\nprintf "%s\\n" "${0##*/}" "$@"\nexit "$NUDGE_TEST_EXIT"\n',
        { mode: 0o755 },
      );
    }
    const command = explicitBun ? [process.execPath, "run", script] : [script];
    const path = explicitBun ? bin : [bin, dirname(process.execPath)].join(delimiter);
    const result = Bun.spawnSync([...command, ...args], {
      cwd: bin,
      env: { ...process.env, PATH: path, NUDGE_TEST_EXIT: String(exitCode) },
    });
    return {
      code: result.exitCode,
      args: result.stdout.toString().trim().split("\n"),
      stderr: result.stderr.toString(),
    };
  } finally {
    rmSync(bin, { recursive: true, force: true });
  }
}

test.each([
  ["claude", "--print", "haiku"],
  ["codex", "exec", "gpt-6-luna"],
  ["agy", "--print", "gemini-4-hydrogen-low"],
])("NUDGE-001 %s sends one headless prompt using its lightweight default", (provider, headless, model) => {
  const result = run([provider]);
  expect(result.code).toBe(0);
  expect(result.args[0]).toBe(provider);
  expect(result.args).toContain(headless);
  expect(result.args[result.args.indexOf("--model") + 1]).toBe(model);
  expect(result.args.filter((arg) => arg === prompt)).toHaveLength(1);
});

test("NUDGE-002 accepts a model override", () => {
  const result = run(["agy", "custom-model"]);
  expect(result.code).toBe(0);
  expect(result.args[result.args.indexOf("--model") + 1]).toBe("custom-model");
});

test.each([[], ["unknown"], ["claude", ""]])("NUDGE-003 rejects invalid arguments %j", (...args: string[]) => {
  const result = run(args);
  expect(result.code).toBe(2);
  expect(result.args).toEqual([""]);
  expect(result.stderr).toContain("Usage:");
});

test("NUDGE-004 preserves provider failures", () => {
  const result = run(["codex"], 42);
  expect(result.code).toBe(42);
  expect(result.args[0]).toBe("codex");
});

test("NUDGE-005 accepts an absolute Bun launcher with a scheduler PATH", () => {
  const result = run(["agy"], 0, true);
  expect(result.code).toBe(0);
  expect(result.args[0]).toBe("agy");
});
