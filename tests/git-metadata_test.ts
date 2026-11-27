// Blackbox tests for home/bin/git/executable_git-metadata (`git metadata`).
// The script is run as a subprocess via its shebang (runtime-agnostic, so the same suite can compare a Deno and a Bun implementation).
// Override the script with env SCRIPT. Every run uses a throwaway repo, HOME and git config.
//
// GITMETA-001: WHEN run without positional arguments (including only `--help`), the script SHALL print usage to stdout and exit 1.
// GITMETA-002: WHEN run with exactly one positional argument, the script SHALL exit non-zero and SHALL NOT print success output.
// GITMETA-003: WHEN run as `set KEY VALUE`, the script SHALL write VALUE, without a trailing newline, to .com.xargs.io/env/KEY at the repo root and exit 0 with no stdout.
// GITMETA-004: WHEN `set` is run for an existing KEY, the script SHALL overwrite the previous value.
// GITMETA-005: WHEN run as `get KEY` AND KEY exists, the script SHALL print the stored value followed by a newline and exit 0.
// GITMETA-006: IF `get KEY` is run AND KEY does not exist, THEN the script SHALL exit non-zero, print nothing to stdout and create no key file.
// GITMETA-007: IF `set` is not given exactly KEY and VALUE, THEN the script SHALL exit non-zero and write nothing.
// GITMETA-008: IF `get` is given more than KEY, THEN the script SHALL exit non-zero.
// GITMETA-009: WHEN run for a valid action, the script SHALL create the .com.xargs.io/env directory if missing and SHALL leave it in place on later runs.
// GITMETA-010: WHEN run from a subdirectory AND `git root` succeeds, the script SHALL read and write at the repository root.
// GITMETA-011: WHEN run from a linked worktree, the script SHALL read and write at the main repository root, shared by all worktrees.
// GITMETA-012: WHEN `git root` fails AND cwd contains a .git directory, the script SHALL use cwd as the root.
// GITMETA-013: IF `git root` fails AND cwd has no .git entry, THEN the script SHALL exit non-zero and create nothing.
// GITMETA-014: IF the .git file has no `gitdir:` line, THEN the script SHALL exit non-zero and create nothing.
// GITMETA-015: WHEN the .git file points at a gitdir without /worktrees, the script SHALL use the parent of that gitdir as the root.
// GITMETA-016: WHEN given an action other than get or set with two or more positional arguments, the script SHALL exit 0, print nothing and only create the env directory.
// GITMETA-017: WHEN `--help` accompanies other arguments, the script SHALL ignore it and run normally.
// GITMETA-018: WHEN a VALUE is numeric, the script SHALL store its numeric normalization (parseArgs coerces: 007 -> 7, 1e3 -> 1000); non-numeric values are stored verbatim.
// GITMETA-019: WHEN a KEY contains a path separator whose directory does not exist, the script SHALL exit non-zero and SHALL NOT report success.
// GITMETA-020: WHEN `--` precedes arguments, the script SHALL treat them as positional, so a dash-prefixed VALUE can be stored.
// GITMETA-021: WHEN a flag-like token such as `--x` precedes a positional, the script SHALL consume that positional as the flag's value (parseArgs), reducing the positional count.
// GITMETA-022: WHEN VALUE is the empty string, the script SHALL store an empty file and `get` SHALL print a lone newline.
// GITMETA-023: WHEN a VALUE contains spaces, quotes or multiple lines, the script SHALL store it verbatim.
//
// GITMETA-024: WHEN a KEY is numeric (parseArgs coerces it), the script SHALL exit 1, print nothing and write nothing.
// GITMETA-025: WHEN a flag-like token follows the positionals (`set k v --x`), the script SHALL ignore it and store VALUE.
// GITMETA-026: WHEN VALUE looks like a negative number or short flag (`-5`, `-a`), the script SHALL treat it as a flag, exit 1 and leave the key unchanged.
// GITMETA-027: WHEN `--help=false` is given, the script SHALL treat it like `--help` (ignored with positionals; usage and exit 1 without).
// GITMETA-028: WHEN the .git file has `gitdir:` with an empty path, the script SHALL exit 1 and create nothing.
// GITMETA-029: IF KEY names an existing directory, THEN `get` and `set` SHALL each exit 1 with no stdout.
// GITMETA-030: WHEN the .git file uses upper-case `GITDIR:`, the script SHALL match it case-insensitively.
// GITMETA-031: WHEN the .git file holds a relative gitdir, the script SHALL resolve its parent relative to cwd (so a real submodule writes inside the superproject's .git/modules).
//
// Crashing paths (every test using expectCrash) pin only exit code 1 (an uncaught throw exits 1 in both
// Deno and Bun), empty stdout and no side effects: runtime-specific stderr not pinned.
//
// Scripts under test MUST be fully standalone single files (no relative imports, no node_modules):
// the harness deliberately copies the script to a temp dir before running it.
import { afterAll, beforeAll, describe, expect, test } from "bun:test";
import { chmodSync, copyFileSync, existsSync, mkdirSync, mkdtempSync, readFileSync, readdirSync, realpathSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve } from "node:path";

const REAL_HOME = process.env.HOME ?? "";
const SCRIPT_SRC = process.env.SCRIPT ?? resolve(import.meta.dir, "../home/bin/git/executable_git-metadata");
const ENV_DIR = ".com.xargs.io/env";
const USAGE = "Usage:\ngit metadata set key value\ngit metadata get key\n";

let sandbox: string;
let script: string;
let binDir: string;
let home: string;
let gitConfig: string;

const gitEnv = () => ({
  ...process.env as Record<string, string>,
  HOME: home,
  GIT_CONFIG_GLOBAL: gitConfig,
  GIT_CONFIG_NOSYSTEM: "1",
  GIT_AUTHOR_NAME: "t", GIT_AUTHOR_EMAIL: "t@example.test",
  GIT_COMMITTER_NAME: "t", GIT_COMMITTER_EMAIL: "t@example.test",
  // Keep both runtimes' real module caches (env overrides win) so a changed HOME does not force a re-download.
  DENO_DIR: process.env.DENO_DIR ?? `${REAL_HOME}/Library/Caches/deno`,
  BUN_INSTALL_CACHE_DIR: process.env.BUN_INSTALL_CACHE_DIR ?? `${REAL_HOME}/.bun/install/cache`,
  PATH: `${binDir}:${process.env.PATH}`,
});

function git(cwd: string, ...args: string[]) {
  const p = Bun.spawnSync(["git", ...args], { cwd, env: gitEnv() });
  if (p.exitCode !== 0) throw new Error(`git ${args.join(" ")}: ${p.stderr.toString()}`);
}

function newRepo(name: string) {
  const dir = join(sandbox, name);
  mkdirSync(dir, { recursive: true });
  git(dir, "init", "-q");
  return realpathSync(dir);
}

async function run(cwd: string, args: string[], env: Record<string, string> = {}) {
  const p = Bun.spawn([script, ...args], { cwd, env: { ...gitEnv(), ...env }, stdout: "pipe", stderr: "pipe" });
  const [stdout, stderr, code] = await Promise.all([new Response(p.stdout).text(), new Response(p.stderr).text(), p.exited]);
  return { code, stdout, stderr };
}

function expectCrash(r: { code: number; stdout: string }) {
  expect(r.code).toBe(1);
  expect(r.stdout).toBe("");
}

const keyFile = (root: string, key: string) => join(root, ENV_DIR, key);
const read = (root: string, key: string) => readFileSync(keyFile(root, key), "utf8");
const noRootEnv = { FAKE_GIT_ROOT_FAIL: "1" };

beforeAll(() => {
  sandbox = realpathSync(mkdtempSync(join(tmpdir(), "git-metadata-test-")));
  home = join(sandbox, "home");
  mkdirSync(home);
  gitConfig = join(sandbox, "gitconfig");
  writeFileSync(gitConfig, "");
  // Copy so +x does not depend on how git records the mode.
  script = join(sandbox, "git-metadata-under-test");
  copyFileSync(SCRIPT_SRC, script);
  chmodSync(script, 0o755);
  // Deterministic `git root`: the script shells out to it; real hosts may or may not have one.
  binDir = join(sandbox, "bin");
  mkdirSync(binDir);
  writeFileSync(join(binDir, "git-root"), `#!/bin/sh\n[ -n "$FAKE_GIT_ROOT_FAIL" ] && exit 1\nexec git rev-parse --show-toplevel\n`);
  chmodSync(join(binDir, "git-root"), 0o755);
});

afterAll(() => rmSync(sandbox, { recursive: true, force: true }));

describe("usage and argument count", () => {
  test("GITMETA-001 no arguments prints usage and exits 1", async () => {
    const r = await run(newRepo("u1"), []);
    expect(r.code).toBe(1);
    expect(r.stdout).toBe(USAGE);
  });

  test("GITMETA-001 only --help prints usage and exits 1", async () => {
    const r = await run(newRepo("u2"), ["--help"]);
    expect(r.code).toBe(1);
    expect(r.stdout).toBe(USAGE);
  });

  test("GITMETA-001 usage creates nothing", async () => {
    const repo = newRepo("u3");
    await run(repo, []);
    expect(existsSync(join(repo, ".com.xargs.io"))).toBe(false);
  });

  test("GITMETA-002 one positional argument fails", async () => {
    for (const args of [["get"], ["set"], ["foo"]]) {
      const repo = newRepo(`one-${args[0]}`);
      const r = await run(repo, args);
      expectCrash(r);
      expect(r.stdout).toBe("");
      expect(existsSync(join(repo, ".com.xargs.io"))).toBe(false);
    }
  });
});

describe("set and get", () => {
  test("GITMETA-003 set writes the value without trailing newline", async () => {
    const repo = newRepo("s1");
    const r = await run(repo, ["set", "name", "hello"]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe("");
    expect(read(repo, "name")).toBe("hello");
  });

  test("GITMETA-004 set overwrites an existing key", async () => {
    const repo = newRepo("s2");
    await run(repo, ["set", "k", "one"]);
    const r = await run(repo, ["set", "k", "two"]);
    expect(r.code).toBe(0);
    expect(read(repo, "k")).toBe("two");
  });

  test("GITMETA-005 get prints value plus newline", async () => {
    const repo = newRepo("g1");
    await run(repo, ["set", "k", "val"]);
    const r = await run(repo, ["get", "k"]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe("val\n");
  });

  test("GITMETA-005 keys are independent", async () => {
    const repo = newRepo("g2");
    await run(repo, ["set", "a", "1x"]);
    await run(repo, ["set", "b", "2x"]);
    expect((await run(repo, ["get", "a"])).stdout).toBe("1x\n");
    expect((await run(repo, ["get", "b"])).stdout).toBe("2x\n");
  });

  test("GITMETA-005 get prints a stored file's trailing newline too", async () => {
    const repo = newRepo("g3");
    await run(repo, ["set", "k", "x"]);
    writeFileSync(keyFile(repo, "k"), "line\n");
    expect((await run(repo, ["get", "k"])).stdout).toBe("line\n\n");
  });

  test("GITMETA-006 get of a missing key fails with no output", async () => {
    const repo = newRepo("g4");
    const r = await run(repo, ["get", "missing"]);
    expectCrash(r);
    expect(r.stdout).toBe("");
    expect(existsSync(keyFile(repo, "missing"))).toBe(false);
  });

  test("GITMETA-007 set with wrong argument count fails and writes nothing", async () => {
    const repo = newRepo("s3");
    for (const args of [["set", "k"], ["set", "k", "a", "b"]]) {
      const r = await run(repo, args);
      expectCrash(r);
      expect(r.stdout).toBe("");
    }
    expect(existsSync(join(repo, ".com.xargs.io"))).toBe(false);
  });

  test("GITMETA-008 get with an extra argument fails", async () => {
    const repo = newRepo("g5");
    await run(repo, ["set", "k", "v"]);
    const r = await run(repo, ["get", "k", "extra"]);
    expectCrash(r);
    expect(r.stdout).toBe("");
  });

  test("GITMETA-009 env directory is created once and kept", async () => {
    const repo = newRepo("d1");
    expect(existsSync(join(repo, ENV_DIR))).toBe(false);
    await run(repo, ["set", "a", "1x"]);
    expect(existsSync(join(repo, ENV_DIR))).toBe(true);
    await run(repo, ["set", "b", "2x"]);
    expect(readdirSync(join(repo, ENV_DIR)).sort()).toEqual(["a", "b"]);
  });

  test("GITMETA-009 get also creates the env directory even when the key is missing", async () => {
    const repo = newRepo("d2");
    await run(repo, ["get", "nope"]);
    expect(existsSync(join(repo, ENV_DIR))).toBe(true);
  });

  test("GITMETA-022 empty value is stored and read back as a newline", async () => {
    const repo = newRepo("e1");
    const s = await run(repo, ["set", "k", ""]);
    expect(s.code).toBe(0);
    expect(read(repo, "k")).toBe("");
    expect((await run(repo, ["get", "k"])).stdout).toBe("\n");
  });

  test("GITMETA-023 values with spaces, quotes and newlines are verbatim", async () => {
    const repo = newRepo("v1");
    const value = `a b "c" 'd'\nsecond line $HOME`;
    expect((await run(repo, ["set", "k", value])).code).toBe(0);
    expect(read(repo, "k")).toBe(value);
    expect((await run(repo, ["get", "k"])).stdout).toBe(value + "\n");
  });
});

describe("argument parsing quirks", () => {
  test("GITMETA-017 --help with other arguments is ignored", async () => {
    const repo = newRepo("h1");
    const s = await run(repo, ["--help", "set", "k", "v"]);
    expect(s.code).toBe(0);
    expect(s.stdout).toBe("");
    expect(read(repo, "k")).toBe("v");
    const g = await run(repo, ["get", "k", "--help"]);
    expect(g.code).toBe(0);
    expect(g.stdout).toBe("v\n");
  });

  test("GITMETA-018 numeric values are normalized", async () => {
    const repo = newRepo("n1");
    for (const [input, stored] of [["42", "42"], ["007", "7"], ["1e3", "1000"], ["3.50", "3.5"], ["0x10", "16"]]) {
      expect((await run(repo, ["set", "k", input])).code).toBe(0);
      expect(read(repo, "k")).toBe(stored);
    }
  });

  test("GITMETA-018 non-numeric look-alikes are stored verbatim", async () => {
    const repo = newRepo("n2");
    for (const input of ["1.2.3", "v1", "abc", "12abc"]) {
      await run(repo, ["set", "k", input]);
      expect(read(repo, "k")).toBe(input);
    }
  });

  test("GITMETA-020 -- makes following arguments positional", async () => {
    const repo = newRepo("dd1");
    const r = await run(repo, ["set", "k", "--", "--dashed"]);
    expect(r.code).toBe(0);
    expect(read(repo, "k")).toBe("--dashed");
  });

  test("GITMETA-021 a flag-like token swallows the next positional", async () => {
    const repo = newRepo("f1");
    const r = await run(repo, ["set", "k", "--x", "v"]);
    expectCrash(r);
    expect(existsSync(keyFile(repo, "k"))).toBe(false);
  });

  test("GITMETA-016 unknown action with two or three arguments is a silent no-op (also 4+ positionals)", async () => {
    for (const args of [["foo", "bar"], ["foo", "bar", "baz"], ["foo", "a", "b", "c"], ["GET", "k"]]) {
      const repo = newRepo(`unk-${args.join("-")}`);
      const r = await run(repo, args);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("");
      expect(readdirSync(join(repo, ENV_DIR))).toEqual([]);
    }
  });

  test("GITMETA-019 key containing a missing directory fails", async () => {
    const repo = newRepo("k1");
    const r = await run(repo, ["set", "a/b", "v"]);
    expectCrash(r);
    expect(existsSync(join(repo, ENV_DIR, "a"))).toBe(false);
  });
});

describe("repository root resolution", () => {
  test("GITMETA-010 subdirectory uses the repo root", async () => {
    const repo = newRepo("r1");
    const sub = join(repo, "a", "b");
    mkdirSync(sub, { recursive: true });
    expect((await run(sub, ["set", "k", "v"])).code).toBe(0);
    expect(read(repo, "k")).toBe("v");
    expect(existsSync(join(sub, ".com.xargs.io"))).toBe(false);
    expect((await run(sub, ["get", "k"])).stdout).toBe("v\n");
  });

  test("GITMETA-011 linked worktree shares the main repo's store", async () => {
    const repo = newRepo("w1");
    git(repo, "commit", "-q", "--allow-empty", "-m", "init");
    const wt = join(sandbox, "w1-wt");
    git(repo, "worktree", "add", "-q", wt, "-b", "feature");
    const wtReal = realpathSync(wt);
    expect((await run(wtReal, ["set", "k", "shared"])).code).toBe(0);
    expect(read(repo, "k")).toBe("shared");
    expect(existsSync(join(wtReal, ".com.xargs.io"))).toBe(false);
    expect((await run(repo, ["get", "k"])).stdout).toBe("shared\n");
  });

  test("GITMETA-011 subfolder of a linked worktree also uses the main repo", async () => {
    const repo = newRepo("w2");
    git(repo, "commit", "-q", "--allow-empty", "-m", "init");
    const wt = join(sandbox, "w2-wt");
    git(repo, "worktree", "add", "-q", wt, "-b", "feature");
    const sub = join(wt, "deep");
    mkdirSync(sub);
    expect((await run(realpathSync(sub), ["set", "k", "v"])).code).toBe(0);
    expect(read(repo, "k")).toBe("v");
  });

  test("GITMETA-012 without `git root`, cwd with a .git directory is the root", async () => {
    const repo = newRepo("c1");
    const r = await run(repo, ["set", "k", "v"], noRootEnv);
    expect(r.code).toBe(0);
    expect(read(repo, "k")).toBe("v");
  });

  test("GITMETA-013 without `git root`, a subdirectory fails and creates nothing", async () => {
    const repo = newRepo("c2");
    const sub = join(repo, "sub");
    mkdirSync(sub);
    const r = await run(sub, ["set", "k", "v"], noRootEnv);
    expectCrash(r);
    expect(existsSync(join(sub, ".com.xargs.io"))).toBe(false);
    expect(existsSync(join(repo, ".com.xargs.io"))).toBe(false);
  });

  test("GITMETA-013 outside any repo fails and creates nothing", async () => {
    const dir = join(sandbox, "not-a-repo");
    mkdirSync(dir);
    const r = await run(dir, ["set", "k", "v"], noRootEnv);
    expectCrash(r);
    expect(readdirSync(dir)).toEqual([]);
  });

  test("GITMETA-014 .git file without gitdir fails", async () => {
    const dir = join(sandbox, "bad-gitfile");
    mkdirSync(dir);
    writeFileSync(join(dir, ".git"), "garbage\n");
    const r = await run(dir, ["set", "k", "v"], noRootEnv);
    expectCrash(r);
    expect(existsSync(join(dir, ".com.xargs.io"))).toBe(false);
  });

  test("GITMETA-015 gitdir without /worktrees resolves to the gitdir's parent", async () => {
    const outer = join(sandbox, "sm");
    const work = join(outer, "work");
    mkdirSync(join(outer, "gitdirs", "mod"), { recursive: true });
    mkdirSync(work);
    writeFileSync(join(work, ".git"), `gitdir: ${join(outer, "gitdirs", "mod")}\n`);
    const r = await run(work, ["set", "k", "v"], noRootEnv);
    expect(r.code).toBe(0);
    expect(read(join(outer, "gitdirs"), "k")).toBe("v");
    expect(existsSync(join(work, ".com.xargs.io"))).toBe(false);
  });
});

describe("further parse and path quirks", () => {
  test("GITMETA-024 numeric key crashes and writes nothing", async () => {
    const repo = newRepo("nk1");
    expectCrash(await run(repo, ["set", "007", "v"]));
    expectCrash(await run(repo, ["get", "007"]));
    expect(readdirSync(join(repo, ENV_DIR))).toEqual([]);
  });

  test("GITMETA-025 trailing flag is ignored", async () => {
    const repo = newRepo("tf1");
    const r = await run(repo, ["set", "k", "v", "--x"]);
    expect(r.code).toBe(0);
    expect(read(repo, "k")).toBe("v");
  });

  test("GITMETA-026 dash-numeric and short-flag values crash and leave the key unchanged", async () => {
    const repo = newRepo("df1");
    await run(repo, ["set", "k", "orig"]);
    for (const v of ["-5", "-a"]) {
      expectCrash(await run(repo, ["set", "k", v]));
      expect(read(repo, "k")).toBe("orig");
    }
  });

  test("GITMETA-027 --help=false behaves like --help", async () => {
    const repo = newRepo("hf1");
    const s = await run(repo, ["--help=false", "set", "k", "v"]);
    expect(s.code).toBe(0);
    expect(read(repo, "k")).toBe("v");
    const u = await run(repo, ["--help=false"]);
    expect(u.code).toBe(1);
    expect(u.stdout).toBe(USAGE);
  });

  test("GITMETA-028 empty gitdir path crashes", async () => {
    const dir = join(sandbox, "empty-gitdir");
    mkdirSync(dir);
    writeFileSync(join(dir, ".git"), "gitdir: \n");
    expectCrash(await run(dir, ["set", "k", "v"], noRootEnv));
    expect(readdirSync(dir)).toEqual([".git"]);
  });

  test("GITMETA-029 KEY that is a directory crashes for get and set", async () => {
    const repo = newRepo("kd1");
    mkdirSync(join(repo, ENV_DIR, "dir"), { recursive: true });
    expectCrash(await run(repo, ["get", "dir"]));
    expectCrash(await run(repo, ["set", "dir", "v"]));
    expect(readdirSync(join(repo, ENV_DIR, "dir"))).toEqual([]);
  });

  test("GITMETA-030 upper-case GITDIR: is accepted", async () => {
    const outer = join(sandbox, "upper");
    const work = join(outer, "work");
    mkdirSync(join(outer, "gd", "mod"), { recursive: true });
    mkdirSync(work);
    writeFileSync(join(work, ".git"), `GITDIR: ${join(outer, "gd", "mod")}\n`);
    expect((await run(work, ["set", "k", "v"], noRootEnv)).code).toBe(0);
    expect(read(join(outer, "gd"), "k")).toBe("v");
  });

  test("GITMETA-031 relative gitdir resolves against cwd", async () => {
    const outer = join(sandbox, "rel");
    const work = join(outer, "work");
    mkdirSync(join(outer, "gd", "mod"), { recursive: true });
    mkdirSync(work);
    writeFileSync(join(work, ".git"), "gitdir: ../gd/mod\n");
    expect((await run(work, ["set", "k", "v"], noRootEnv)).code).toBe(0);
    expect(read(join(outer, "gd"), "k")).toBe("v");
    expect(existsSync(join(work, ".com.xargs.io"))).toBe(false);
  });

  test("GITMETA-031 real submodule writes inside the superproject's .git/modules", async () => {
    const lib = newRepo("sm-lib");
    git(lib, "commit", "-q", "--allow-empty", "-m", "init");
    const parent = newRepo("sm-parent");
    git(parent, "-c", "protocol.file.allow=always", "submodule", "add", "-q", lib, "x");
    const sub = join(parent, "x");
    expect(readFileSync(join(sub, ".git"), "utf8").trim()).toBe("gitdir: ../.git/modules/x");
    expect((await run(sub, ["set", "k", "v"], noRootEnv)).code).toBe(0);
    expect(read(join(parent, ".git", "modules"), "k")).toBe("v");
    expect(existsSync(join(sub, ".com.xargs.io"))).toBe(false);
  });
});
