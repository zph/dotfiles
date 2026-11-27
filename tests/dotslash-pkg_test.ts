// Blackbox tests for ~/bin/dotslash-pkg (home/bin/executable_dotslash-pkg). They pin the CURRENT
// behaviour, quirks included, so a rewrite (e.g. Bun) can be proven identical by running the same
// suite with SCRIPT=<path to rewrite>. A local stub HTTP server stands in for the GitHub API and
// for the release asset hosts; fake `dotslash` and fake `<script name>` CLIs on PATH stand in for
// the real ones. Run with `bun test tests/dotslash-pkg_test.ts`.
//
// Seams: the script reads GITHUB_API_URL (default https://api.github.com) and GITHUB_RAW_URL
// (default https://raw.githubusercontent.com); the stub is wired through both. Asset URLs come
// from the stub's release JSON.
//
// DSPKG-001: WHEN run with --help or without a command, the script SHALL print the help text to stdout and exit 0.
// DSPKG-002: IF the command is not create, update, check, install or search, THEN the script SHALL print the valid commands to stderr, exit 1 and write nothing.
// DSPKG-003: WHEN run as `create owner/repo tag pattern`, the script SHALL write an executable manifest (dotslash shebang, blank line, 2-space JSON) with one entry per detected platform: size, blake3 digest, binary path, format, URL + github-release providers, readonly.
// DSPKG-004: WHEN creating, the script SHALL record build_info (created_at, build_tool, command that reproduces the run, tag) in the manifest metadata.
// DSPKG-005: WHEN creating, the script SHALL pick for each of linux/macos x aarch64/x86_64 the first release asset whose lower-cased name matches the platform and omit platforms without a match.
// DSPKG-006: WHEN creating, the script SHALL locate the binary by matching the asset-pattern glob (case-insensitive, globstar) against the paths inside the extracted archive.
// DSPKG-007: IF no file in an archive matches the pattern, THEN the script SHALL warn, omit that platform and still write the manifest.
// DSPKG-008: WHEN creating, the script SHALL name the output file after the last path segment of the pattern (unknown-pkg if empty), in the current directory, and SHALL ignore --output.
// DSPKG-009: WHEN creating, the script SHALL support tar.gz, tgz (reported as tar.gz), tar, tar.xz, tar.zst and zip assets.
// DSPKG-010: IF an asset has an unsupported extension or cannot be extracted, THEN create SHALL log the error, write no manifest and exit 0.
// DSPKG-011: WHEN the tag is `latest`, an exact tag or a caret expression, the script SHALL query the single-release endpoint (latest / tags/<tag>), not the release list.
// DSPKG-012: WHEN the tag contains a space or starts with ~ > < or =, the script SHALL list releases and choose the highest tag satisfying the semver range (optional v prefix, prereleases excluded unless named).
// DSPKG-013: IF no release satisfies the range, or the GitHub API answers non-2xx, THEN create SHALL log the error, write no manifest and exit 0.
// DSPKG-014: IF the repository argument is not owner/repo, THEN create SHALL exit 1; IF the tag or pattern argument is missing, THEN create SHALL log an error, write nothing and exit 0.
// DSPKG-015: WHEN run as `create <http(s) url> name`, the script SHALL run `dotslash -- create-url-entry <url>` and write its JSON plus build_info (empty tag) as an executable manifest named name.
// DSPKG-016: IF the URL form lacks a name, or dotslash fails, THEN create SHALL write nothing and exit 0.
// DSPKG-017: WHEN run as `update <manifests>`, the script SHALL read each manifest (JSONC after the first line), print "Updating <command>" and re-run the recorded create command through the shell.
// DSPKG-018: IF a manifest's recorded command is not a create command, THEN update SHALL report it unsupported and run nothing; IF a manifest cannot be parsed, THEN update SHALL log the error, stop processing later manifests and exit 0.
// DSPKG-019: WHEN given a directory, update/check SHALL consider only its direct files whose first line is a shebang ending in `dotslash`; WHEN given a missing path or non-manifest file, they SHALL skip it silently.
// DSPKG-020: WHEN run as `check <manifests>`, the script SHALL announce each manifest, warn when it contains TODO:, run it once with --version and always exit 0.
// DSPKG-021: WHEN run as `install <http(s) url> --output file`, the script SHALL write the fetched body to file (mode 0755) and print "Installed file"; without --output it SHALL exit 1.
// DSPKG-022: WHEN given a github:// reference, install SHALL do nothing; WHEN given owner/repo/path, install SHALL resolve the default branch through the GitHub API (or use the `#tag` fragment without an API call), fetch <GITHUB_RAW_URL>/owner/repo/ref/path, write it (mode 0755, to --output or the path's basename) and print "Installed <file>"; IF resolution or the fetch fails or the path is empty, THEN it SHALL exit 1 and write nothing.
// DSPKG-023: WHEN run as `search <term>` (or `install <term>` / `install owner/repo`), the script SHALL query /search/repositories?q=<encoded>&sort=stars&order=desc and print `No results found for "<term>"` when empty.
// DSPKG-024: IF the search API answers non-2xx, THEN `search` SHALL log the error and exit 0, while `install <term>` SHALL exit 1.
// DSPKG-025: WHEN interactively choosing a search result, confirming, choosing a release tag and an output name, the script SHALL create that manifest; IF the user declines, THEN it SHALL write nothing.
// DSPKG-026: IF choosing the "latest" entry in the interactive tag list, THEN no manifest SHALL be written.
// DSPKG-027: WHEN --verbose or LOG_LEVEL=DEBUG is set, the script SHALL print debug lines; WHEN LOG_LEVEL is ERROR or unrecognised, it SHALL suppress info output.
//
// Untested (reason): non-TTY prompt
// behaviour (with results and no TTY the cliffy prompt hangs, so it is not run); single-file .gz/.xz/.zst
// assets succeed (they cannot: output target is a directory, see DSPKG-010).
import { afterAll, beforeAll, describe, expect, setDefaultTimeout, test } from "bun:test";
import {
  chmodSync,
  copyFileSync,
  existsSync,
  mkdirSync,
  mkdtempSync,
  readdirSync,
  readFileSync,
  rmSync,
  statSync,
  writeFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { basename, join } from "node:path";
import { fileURLToPath } from "node:url";

setDefaultTimeout(90_000);

const SCRIPT_SRC = process.env.SCRIPT ??
  fileURLToPath(new URL("../home/bin/executable_dotslash-pkg", import.meta.url));
const BIN_NAME = basename(SCRIPT_SRC);
const SHEBANG = "#!/usr/bin/env dotslash";
const enc = new TextEncoder();
const dec = new TextDecoder();

// ---------------------------------------------------------------- fixtures

// Minimal ustar writer so archive bytes (and thus digests) are deterministic.
function tar(files: Record<string, string>): Uint8Array {
  const parts: Uint8Array[] = [];
  for (const [name, content] of Object.entries(files)) {
    const h = new Uint8Array(512);
    const put = (s: string, o: number) => h.set(enc.encode(s), o);
    put(name, 0);
    put("0000755\0", 100);
    put("0000000\0", 108);
    put("0000000\0", 116);
    const body = enc.encode(content);
    put(body.length.toString(8).padStart(11, "0") + "\0", 124);
    put("00000000000\0", 136);
    put("        ", 148);
    put("0", 156);
    put("ustar\0", 257);
    put("00", 263);
    let sum = 0;
    for (const b of h) sum += b;
    put(sum.toString(8).padStart(6, "0") + "\0 ", 148);
    parts.push(h);
    const padded = new Uint8Array(Math.ceil(body.length / 512) * 512);
    padded.set(body);
    parts.push(padded);
  }
  parts.push(new Uint8Array(1024));
  return Buffer.concat(parts);
}

// Four platform assets, distinct names (exercise every arch/os keyword) and distinct bytes.
const PLATFORM_ASSETS: Record<string, { name: string; files: Record<string, string> }> = {
  "linux-aarch64": {
    name: "tool-2.0.0-aarch64-unknown-linux-gnu.tar",
    files: { "tool-2.0.0/bin/tool": "linux-arm64\n", "tool-2.0.0/README": "readme\n" },
  },
  "linux-x86_64": {
    name: "tool_2.0.0_linux_amd64.tar",
    files: { "tool-2.0.0/bin/tool": "linux-x64\n" },
  },
  "macos-aarch64": {
    name: "tool-2.0.0-aarch64-apple-darwin.tar",
    files: { "tool-2.0.0/bin/tool": "macos-arm64\n" },
  },
  "macos-x86_64": {
    name: "tool-2.0.0-x86_64-apple-darwin.tar",
    files: { "tool-2.0.0/bin/tool": "macos-x64\n" },
  },
};
// blake3 of the tar bytes above (pinned from the Deno original; @noble/hashes blake3).
const EXPECTED_DIGEST: Record<string, string> = {
  "linux-aarch64": "5562bbf4a9782b56d325d8ce58669d008d8ad8bf83d61ed68ceffe69ea916efc",
  "linux-x86_64": "1080c10cf293e5602b6c2e35dbace0cc93bc712c979fd276efe258c71458c712",
  "macos-aarch64": "94b1a153a1bc19182a0ef4af04b1402f844bde936e53d47012f26f4ea412e9f2",
  "macos-x86_64": "e8b3c28ace3210c99e3cd1f47c36e00b26dd8c0023b77cd70a0fab7d32e47878",
};

type Asset = { name: string; bytes: Uint8Array };
const assetOf = (key: string): Asset => ({
  name: PLATFORM_ASSETS[key].name,
  bytes: tar(PLATFORM_ASSETS[key].files),
});

// ---------------------------------------------------------------- stub server

type Release = { tag_name: string; name?: string; prerelease?: boolean; assets: Asset[] };
type Handler = (req: Request, url: URL) => Response | undefined;

interface Stub {
  url: string;
  requests: string[];
  stop(): void;
}

// `handler` may answer first; otherwise /dl/<name> serves registered asset bytes. Everything
// else is 404. `requests` records pathname+search of every request, in order.
function startStub(
  assets: Asset[],
  handler: Handler = () => undefined,
): Stub {
  const byName = new Map(assets.map((a) => [a.name, a.bytes]));
  const requests: string[] = [];
  const server = Bun.serve({
    port: 0,
    hostname: "127.0.0.1",
    fetch(req) {
      const url = new URL(req.url);
      requests.push(url.pathname + url.search);
      const custom = handler(req, url);
      if (custom) return custom;
      if (url.pathname.startsWith("/dl/")) {
        const bytes = byName.get(decodeURIComponent(url.pathname.slice(4)));
        if (bytes) return new Response(bytes);
      }
      return new Response("not found", { status: 404 });
    },
  });
  return {
    url: `http://127.0.0.1:${server.port}`,
    requests,
    stop: () => server.stop(true),
  };
}

const releaseJson = (stubUrl: string, r: Release) => ({
  tag_name: r.tag_name,
  name: r.name,
  prerelease: r.prerelease ?? false,
  assets: r.assets.map((a) => ({
    name: a.name,
    size: a.bytes.length,
    browser_download_url: `${stubUrl}/dl/${a.name}`,
  })),
});

// Serves the usual release endpoints for owner/repo `o/tool` from a list of releases.
function releaseHandler(getUrl: () => string, releases: Release[], latest?: string): Handler {
  const json = (r: Release) => Response.json(releaseJson(getUrl(), r));
  return (_req, url) => {
    const p = url.pathname;
    if (p === "/repos/o/tool/releases/latest") {
      const r = releases.find((x) => x.tag_name === (latest ?? releases[0]?.tag_name));
      return r ? json(r) : undefined;
    }
    if (p.startsWith("/repos/o/tool/releases/tags/")) {
      const tag = decodeURIComponent(p.slice("/repos/o/tool/releases/tags/".length));
      const r = releases.find((x) => x.tag_name === tag);
      return r ? json(r) : undefined;
    }
    if (p === "/repos/o/tool/releases") {
      return Response.json(releases.map((r) => releaseJson(getUrl(), r)));
    }
    return undefined;
  };
}

// ---------------------------------------------------------------- harness

let ROOT = "";
let FAKE_BIN = "";
let SCRIPT = "";
const REAL_HOME = process.env.HOME ?? "";
let ARCHIVES: Record<string, Asset> = {};

beforeAll(() => {
  ROOT = mkdtempSync(join(tmpdir(), "dspkg-"));
  FAKE_BIN = join(ROOT, "fakebin");
  mkdirSync(FAKE_BIN);
  // The source file in chezmoi is not executable (the `executable_` prefix is applied on
  // install), so run an executable copy under the same name when needed.
  if (statSync(SCRIPT_SRC).mode & 0o111) {
    SCRIPT = SCRIPT_SRC;
  } else {
    const dir = join(ROOT, "script");
    mkdirSync(dir);
    SCRIPT = join(dir, BIN_NAME);
    copyFileSync(SCRIPT_SRC, SCRIPT);
    chmodSync(SCRIPT, 0o755);
  }
  // Fake `dotslash`: logs its argv; answers `-- create-url-entry` with $FAKE_DOTSLASH_JSON.
  writeFileSync(
    join(FAKE_BIN, "dotslash"),
    `#!/bin/sh
echo "dotslash $*" >> "$FAKE_LOG"
[ -n "$FAKE_DOTSLASH_FAIL" ] && exit 3
if [ "$1" = "--" ] && [ "$2" = "create-url-entry" ]; then
  printf '%s' "$FAKE_DOTSLASH_JSON"
fi
exit 0
`,
    { mode: 0o755 },
  );
  // Fake of the script's own name: update re-runs the recorded command through PATH.
  writeFileSync(
    join(FAKE_BIN, BIN_NAME),
    `#!/bin/sh
for a in "$@"; do printf '[%s]' "$a" >> "$FAKE_LOG"; done
echo >> "$FAKE_LOG"
`,
    { mode: 0o755 },
  );

  // Real archives in the other formats, built with system tools.
  const stage = join(ROOT, "stage");
  mkdirSync(join(stage, "tool-2.0.0/bin"), { recursive: true });
  writeFileSync(join(stage, "tool-2.0.0/bin/tool"), "formats\n");
  const out = join(ROOT, "archives");
  mkdirSync(out);
  const mk = (name: string, cmd: string[]) => {
    const r = Bun.spawnSync(cmd, { cwd: stage });
    if (r.exitCode !== 0) throw new Error(`cannot build ${name}: ${dec.decode(r.stderr)}`);
    ARCHIVES[name] = { name, bytes: new Uint8Array(readFileSync(join(out, name))) };
  };
  mk("tool-2.0.0-linux-amd64.tar.gz", ["tar", "czf", join(out, "tool-2.0.0-linux-amd64.tar.gz"), "tool-2.0.0"]);
  mk("tool-2.0.0-linux-amd64.tgz", ["tar", "czf", join(out, "tool-2.0.0-linux-amd64.tgz"), "tool-2.0.0"]);
  mk("tool-2.0.0-linux-amd64.tar.xz", ["tar", "cJf", join(out, "tool-2.0.0-linux-amd64.tar.xz"), "tool-2.0.0"]);
  mk("tool-2.0.0-linux-amd64.tar.zst", ["tar", "--zstd", "-cf", join(out, "tool-2.0.0-linux-amd64.tar.zst"), "tool-2.0.0"]);
  mk("tool-2.0.0-linux-amd64.zip", ["zip", "-qr", join(out, "tool-2.0.0-linux-amd64.zip"), "tool-2.0.0"]);
});

afterAll(() => {
  if (ROOT) rmSync(ROOT, { recursive: true, force: true });
});

interface Sandbox {
  cwd: string;
  home: string;
  log: string;
  logLines(): string[];
  files(): string[];
  read(name: string): string;
  write(name: string, content: string, mode?: number): string;
}

function sandbox(): Sandbox {
  const dir = mkdtempSync(join(ROOT, "t-"));
  const cwd = join(dir, "cwd");
  const home = join(dir, "home");
  mkdirSync(cwd);
  mkdirSync(home);
  const log = join(dir, "calls.log");
  writeFileSync(log, "");
  return {
    cwd,
    home,
    log,
    logLines: () => readFileSync(log, "utf8").split("\n").filter(Boolean),
    files: () => readdirSync(cwd).sort(),
    read: (n) => readFileSync(join(cwd, n), "utf8"),
    write(name, content, mode = 0o644) {
      const p = join(cwd, name);
      mkdirSync(join(p, ".."), { recursive: true });
      writeFileSync(p, content, { mode });
      chmodSync(p, mode);
      return p;
    },
  };
}

function envFor(sb: Sandbox, stub: Stub | null, extra: Record<string, string> = {}) {
  const env: Record<string, string> = {
    PATH: `${FAKE_BIN}:${process.env.PATH ?? ""}`,
    HOME: sb.home,
    // Hazard: the script splits the temp download path on "." to find the archive format, so a
    // TMPDIR containing a dot breaks extraction. ROOT comes from os.tmpdir() and has none.
    TMPDIR: ROOT,
    NO_COLOR: "1",
    FAKE_LOG: sb.log,
    // Never reach the real GitHub: with no stub, point at a closed port.
    GITHUB_API_URL: stub?.url ?? "http://127.0.0.1:9",
    GITHUB_RAW_URL: stub?.url ?? "http://127.0.0.1:9",
    // Keep both runtimes' real module caches (parent env wins) so a changed HOME does not force a re-download.
    DENO_DIR: process.env.DENO_DIR ?? `${REAL_HOME}/Library/Caches/deno`,
    BUN_INSTALL_CACHE_DIR: process.env.BUN_INSTALL_CACHE_DIR ?? `${REAL_HOME}/.bun/install/cache`,
    ...extra,
  };
  for (const k of ["BUN_INSTALL", "XDG_CACHE_HOME"]) if (process.env[k]) env[k] = process.env[k]!;
  return env;
}

async function run(
  sb: Sandbox,
  stub: Stub | null,
  args: string[],
  extraEnv: Record<string, string> = {},
) {
  const p = Bun.spawn([SCRIPT, ...args], {
    cwd: sb.cwd,
    env: envFor(sb, stub, extraEnv),
    stdin: "ignore",
    stdout: "pipe",
    stderr: "pipe",
  });
  const [stdout, stderr, code] = await Promise.all([
    new Response(p.stdout).text(),
    new Response(p.stderr).text(),
    p.exited,
  ]);
  return { code, stdout, stderr };
}

// Drives prompts through a pseudo-terminal. Each step is sent once output has gone quiet, so no
// prompt wording is relied on. Prompt rendering not pinned; effects only.
async function runTty(sb: Sandbox, stub: Stub, args: string[], steps: string[]) {
  let out = "";
  let lastData = 0;
  const p = Bun.spawn([SCRIPT, ...args], {
    cwd: sb.cwd,
    env: envFor(sb, stub),
    terminal: { cols: 120, rows: 40, data(_t, d) { out += dec.decode(d); lastData = Date.now(); } },
  });
  const quiet = async (mustContain = "") => {
    const start = Date.now();
    while (Date.now() - start < 30_000) {
      if (lastData > 0 && out.includes(mustContain) && Date.now() - lastData > 900) return;
      await Bun.sleep(50);
    }
    throw new Error(`pty wait timed out (waiting for ${JSON.stringify(mustContain)})`);
  };
  // The first key waits for the script's own (non-prompt) result-list line because runtime
  // start-up time differs (Deno vs Bun); output going quiet alone could fire too early.
  let mustContain = "Top results for";
  for (const step of steps) {
    lastData = 0;
    await quiet(mustContain);
    mustContain = "";
    p.terminal!.write(step);
  }
  const code = await Promise.race([
    p.exited,
    Bun.sleep(30_000).then(() => { p.kill(); return -1; }),
  ]);
  return { code, out };
}

const ENTER = "\r";
const DOWN = "\x1b[B";

function parseManifest(text: string) {
  const [first, blank, ...rest] = text.split("\n");
  return { first, blank, body: rest.join("\n"), json: JSON.parse(rest.join("\n")) };
}

const modeOf = (p: string) => statSync(p).mode & 0o777;
const ISO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/;

function expectedPlatform(stubUrl: string, key: string, owner = "o", tag = "v2.0.0") {
  const a = assetOf(key);
  return {
    size: a.bytes.length,
    hash: "blake3",
    digest: EXPECTED_DIGEST[key],
    path: "tool-2.0.0/bin/tool",
    format: "tar",
    providers: [
      { url: `${stubUrl}/dl/${a.name}` },
      { type: "github-release", repo: `${owner}/tool`, tag, name: a.name },
    ],
    readonly: true,
  };
}

const fullRelease = (tag = "v2.0.0"): Release => ({
  tag_name: tag,
  assets: Object.keys(PLATFORM_ASSETS).map(assetOf),
});

// Starts a stub serving the 4-platform release (and any extra releases) for o/tool.
function toolStub(releases: Release[] = [fullRelease()], latest?: string, extraAssets: Asset[] = []) {
  let stub!: Stub;
  const assets = [...Object.keys(PLATFORM_ASSETS).map(assetOf), ...extraAssets, ...releases.flatMap((r) => r.assets)];
  stub = startStub(assets, releaseHandler(() => stub.url, releases, latest));
  return stub;
}

async function withStub<T>(stub: Stub, fn: () => Promise<T>): Promise<T> {
  try {
    return await fn();
  } finally {
    stub.stop();
  }
}

// ---------------------------------------------------------------- tests

const HELP = `
Usage: dotslash-pkg <command> [options]

Commands:
  create    Generate a new manifest file
  update    Update an existing manifest(s) file
  check     Verify if manifest is valid
  install   Install a tool from a manifest
  search    Search GitHub for most popular matching projects

Create command:
  dotslash-pkg create owner/repo tag_name asset_pattern

The tag_name parameter supports semver constraints:
  - Exact versions: 1.2.3
  - Caret ranges: ^1.2.3 (matches 1.2.3 to <2.0.0)
  - Tilde ranges: ~1.2.3 (matches 1.2.3 to <1.3.0)
  - Greater than: >1.2.3
  - Greater/equal: >=1.2.3
  - Less than: <2.0.0
  - Less/equal: <=2.0.0
  - Hyphen ranges: 1.2.3 - 2.0.0
  - Combined ranges: >=1.2.3 <2.0.0
  - 'v' prefix is optional: v1.2.3 is the same as 1.2.3

Examples:
  dotslash-pkg create owner/repo 1.2.3 "*.tar.gz"          # Create manifest for version 1.2.3
  dotslash-pkg update owner/repo ^1.2.3 "release-*.zip"    # Update manifest to latest 1.x.x
  dotslash-pkg check owner/repo ">=1.0.0 <2" "*-linux-*"   # Check for updates

Update command:
  dotslash-pkg update                      # Update all manifests in current directory
  dotslash-pkg update manifest1 manifest2  # Update specific manifests
  dotslash-pkg update $PWD                 # Update all manifests in current directory
  dotslash-pkg create BurntSushi/ripgrep latest '*/rg'

Options:
  --help     Show this help message
  --verbose  Enable verbose logging
  --output   Specify output file path
`;

describe("help and command validation", () => {
  test("DSPKG-001 --help and no arguments print the help text and exit 0", async () => {
    for (const args of [["--help"], [], ["create", "--help"], ["bogus", "--help"], ["--verbose"]]) {
      const sb = sandbox();
      const r = await run(sb, null, args);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe(HELP + "\n");
      expect(sb.files()).toEqual([]);
    }
  });

  test("DSPKG-002 unknown command exits 1 with the valid commands and writes nothing", async () => {
    for (const args of [["bogus"], ["Create", "o/r", "t", "p"], ["--verbose", "nope"]]) {
      const sb = sandbox();
      const r = await run(sb, null, args);
      expect(r.code).toBe(1);
      expect(r.stdout).toBe("");
      expect(r.stderr).toBe("Invalid command. Must be one of: create, update, check, install, search\n");
      expect(sb.files()).toEqual([]);
    }
  });
});

describe("create from a GitHub release", () => {
  test("DSPKG-003 DSPKG-004 DSPKG-005 DSPKG-008 four platforms produce the exact manifest", async () => {
    const stub = toolStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "o/tool", "v2.0.0", "*/bin/tool"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("");
      expect(sb.files()).toEqual(["tool"]);
      expect(stub.requests[0]).toBe("/repos/o/tool/releases/tags/v2.0.0");

      const text = sb.read("tool");
      const m = parseManifest(text);
      expect(m.first).toBe(SHEBANG);
      expect(m.blank).toBe("");
      // Layout: 2-space JSON. Platform key order depends on download timing, so compare parsed.
      expect(m.body).toBe(JSON.stringify(m.json, null, 2));
      expect(Object.keys(m.json)).toEqual(["name", "platforms", "metadata"]);
      expect(m.json.name).toBe("tool");
      expect(Object.keys(m.json.platforms).sort()).toEqual(Object.keys(PLATFORM_ASSETS).sort());
      for (const key of Object.keys(PLATFORM_ASSETS)) {
        expect(m.json.platforms[key]).toEqual(expectedPlatform(stub.url, key));
        expect(Object.keys(m.json.platforms[key])).toEqual([
          "size", "hash", "digest", "path", "format", "providers", "readonly",
        ]);
      }
      const bi = m.json.metadata.build_info;
      expect(Object.keys(m.json.metadata)).toEqual(["build_info"]);
      expect(Object.keys(bi)).toEqual(["created_at", "build_tool", "command", "tag"]);
      expect(bi.created_at).toMatch(ISO);
      expect(bi.build_tool).toBe(BIN_NAME);
      expect(bi.tag).toBe("v2.0.0");
      expect(bi.command).toBe(`${BIN_NAME} create 'o/tool' 'v2.0.0' '*/bin/tool'`);
      expect(modeOf(join(sb.cwd, "tool"))).toBe(0o755);
    });
  });

  test("DSPKG-004 recorded command shell-quotes arguments and includes flags", async () => {
    const stub = toolStub([{ ...fullRelease("v1.0.0") }], "v1.0.0");
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "--verbose", "o/tool", "latest", "*/bin/tool"]);
      expect(r.code).toBe(0);
      const bi = parseManifest(sb.read("tool")).json.metadata.build_info;
      expect(bi.tag).toBe("latest");
      expect(bi.command).toBe(`${BIN_NAME} create '--verbose' 'o/tool' latest '*/bin/tool'`);
    });
  });

  test("DSPKG-005 platform detection by asset name keywords, first match wins, case-insensitive", async () => {
    const A = (name: string, body: string): Asset => ({ name, bytes: tar({ "pkg/tool": body }) });
    const assets = [
      A("tool-Linux-ARM64.tar", "la1"),
      A("tool-linux-aarch64-musl.tar", "la2"), // second linux/arm match: ignored
      A("tool-linux-x64.tar", "lx"),
      A("tool-MacOS-arm64.tar", "ma"),
      A("tool-darwin-amd64.tar", "mx"),
      A("tool-windows-x64.tar", "win"), // no platform
      A("checksums.txt", "sums"),
    ];
    const stub = toolStub([{ tag_name: "v1.0.0", assets }], "v1.0.0");
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "o/tool", "latest", "pkg/tool"]);
      expect(r.code).toBe(0);
      const p = parseManifest(sb.read("tool")).json.platforms;
      expect(Object.keys(p).sort()).toEqual(["linux-aarch64", "linux-x86_64", "macos-aarch64", "macos-x86_64"]);
      expect(p["linux-aarch64"].providers[1].name).toBe("tool-Linux-ARM64.tar");
      expect(p["linux-x86_64"].providers[1].name).toBe("tool-linux-x64.tar");
      expect(p["macos-aarch64"].providers[1].name).toBe("tool-MacOS-arm64.tar");
      expect(p["macos-x86_64"].providers[1].name).toBe("tool-darwin-amd64.tar");
    });
  });

  test("DSPKG-005 platforms without a matching asset are omitted; none at all still writes a manifest", async () => {
    const A = (name: string): Asset => ({ name, bytes: tar({ "pkg/tool": "x" }) });
    const stub = toolStub([{ tag_name: "v1.0.0", assets: [A("tool-linux-x64.tar")] }], "v1.0.0");
    await withStub(stub, async () => {
      const sb = sandbox();
      expect((await run(sb, stub, ["create", "o/tool", "latest", "pkg/tool"])).code).toBe(0);
      expect(Object.keys(parseManifest(sb.read("tool")).json.platforms)).toEqual(["linux-x86_64"]);
    });
    const empty = toolStub([{ tag_name: "v1.0.0", assets: [A("README.md")] }], "v1.0.0");
    await withStub(empty, async () => {
      const sb = sandbox();
      expect((await run(sb, empty, ["create", "o/tool", "latest", "pkg/tool"])).code).toBe(0);
      expect(parseManifest(sb.read("tool")).json.platforms).toEqual({});
    });
  });

  test("DSPKG-006 asset-pattern glob matching inside the archive", async () => {
    const asset: Asset = {
      name: "tool-1.0.0-linux-amd64.tar",
      bytes: tar({ "Top.txt": "t", "dir/deep/Tool": "d", "dir/other": "o" }),
    };
    const stub = toolStub([{ tag_name: "v1.0.0", assets: [asset] }], "v1.0.0");
    await withStub(stub, async () => {
      const cases: Array<[string, string | null]> = [
        ["**/tool", "dir/deep/Tool"], // case-insensitive, globstar
        ["dir/*/tool", "dir/deep/Tool"],
        ["top.txt", "Top.txt"], // root-level file, case-insensitive
        ["*/tool", null], // single * does not cross directories
        ["tool", null], // must match the whole relative path
        ["dir/other", "dir/other"],
        ["dir/{deep/tool,nothing}", "dir/deep/Tool"], // extended glob braces
      ];
      for (const [pattern, expected] of cases) {
        const sb = sandbox();
        const r = await run(sb, stub, ["create", "o/tool", "latest", pattern]);
        expect(r.code).toBe(0);
        const name = pattern.split("/").pop()!;
        const m = parseManifest(sb.read(name)).json;
        if (expected === null) {
          expect(m.platforms).toEqual({});
          expect(r.stderr).toContain("No binary path found for tool-1.0.0-linux-amd64.tar");
        } else {
          expect(m.platforms["linux-x86_64"].path).toBe(expected);
        }
      }
    });
  });

  test("DSPKG-007 a platform whose archive lacks the binary is dropped, others kept, exit 0", async () => {
    const good: Asset = { name: "tool-linux-amd64.tar", bytes: tar({ "pkg/tool": "x" }) };
    const bad: Asset = { name: "tool-linux-arm64.tar", bytes: tar({ "pkg/other": "x" }) };
    const stub = toolStub([{ tag_name: "v1.0.0", assets: [good, bad] }], "v1.0.0");
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "o/tool", "latest", "pkg/tool"]);
      expect(r.code).toBe(0);
      expect(r.stderr).toContain("No binary path found for tool-linux-arm64.tar");
      expect(Object.keys(parseManifest(sb.read("tool")).json.platforms)).toEqual(["linux-x86_64"]);
    });
  });

  test("DSPKG-008 output name is the last pattern segment in cwd; --output is ignored", async () => {
    const stub = toolStub();
    await withStub(stub, async () => {
      let sb = sandbox();
      expect((await run(sb, stub, ["create", "o/tool", "v2.0.0", "tool-2.0.0/bin/tool"])).code).toBe(0);
      expect(sb.files()).toEqual(["tool"]);

      sb = sandbox();
      expect((await run(sb, stub, ["create", "--output", "elsewhere", "o/tool", "v2.0.0", "**/tool"])).code).toBe(0);
      expect(sb.files()).toEqual(["tool"]);

      sb = sandbox();
      expect((await run(sb, stub, ["create", "o/tool", "v2.0.0", "tool-2.0.0/"])).code).toBe(0);
      expect(sb.files()).toEqual(["unknown-pkg"]);
      // Pattern "tool-2.0.0/" matches no file, so the manifest has no platforms.
      expect(parseManifest(sb.read("unknown-pkg")).json.platforms).toEqual({});
    });
  });

  test("DSPKG-008 an existing output file is overwritten", async () => {
    const stub = toolStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      sb.write("tool", "old contents", 0o600);
      expect((await run(sb, stub, ["create", "o/tool", "v2.0.0", "**/tool"])).code).toBe(0);
      expect(sb.read("tool").startsWith(SHEBANG + "\n\n{")).toBe(true);
      expect(modeOf(join(sb.cwd, "tool"))).toBe(0o755);
    });
  });

  test("DSPKG-009 tar.gz, tgz, tar.xz, tar.zst and zip assets are extracted and typed", async () => {
    const cases: Array<[string, string]> = [
      ["tool-2.0.0-linux-amd64.tar.gz", "tar.gz"],
      ["tool-2.0.0-linux-amd64.tgz", "tar.gz"],
      ["tool-2.0.0-linux-amd64.tar.xz", "tar.xz"],
      ["tool-2.0.0-linux-amd64.tar.zst", "tar.zst"],
      ["tool-2.0.0-linux-amd64.zip", "zip"],
    ];
    for (const [name, format] of cases) {
      const asset = ARCHIVES[name];
      const stub = toolStub([{ tag_name: "v2.0.0", assets: [asset] }], "v2.0.0");
      await withStub(stub, async () => {
        const sb = sandbox();
        const r = await run(sb, stub, ["create", "o/tool", "latest", "**/bin/tool"]);
        expect(r.code).toBe(0);
        const e = parseManifest(sb.read("tool")).json.platforms["linux-x86_64"];
        expect(e.format).toBe(format);
        expect(e.path).toBe("tool-2.0.0/bin/tool");
        expect(e.size).toBe(asset.bytes.length);
        expect(e.digest).toMatch(/^[0-9a-f]{64}$/);
        expect(e.providers).toEqual([
          { url: `${stub.url}/dl/${name}` },
          { type: "github-release", repo: "o/tool", tag: "v2.0.0", name },
        ]);
      });
    }
  });

  test("DSPKG-010 unsupported or non-extractable assets log an error, write nothing, exit 0", async () => {
    const names = ["tool-linux-amd64.deb", "tool-linux-amd64.gz", "tool-linux-amd64.zst", "tool-linux-amd64.xz", "tool-linux-amd64"];
    for (const name of names) {
      const asset: Asset = { name, bytes: enc.encode("not an archive") };
      const stub = toolStub([{ tag_name: "v1.0.0", assets: [asset] }], "v1.0.0");
      await withStub(stub, async () => {
        const sb = sandbox();
        const r = await run(sb, stub, ["create", "o/tool", "latest", "tool"]);
        // runtime-specific stderr not pinned
        expect(r.code).toBe(0);
        expect(sb.files()).toEqual([]);
        expect(r.stdout).toBe("");
      });
    }
  });

  test("DSPKG-010 a corrupt archive or a failing download writes nothing and exits 0", async () => {
    const corrupt: Asset = { name: "tool-linux-amd64.tar.gz", bytes: enc.encode("garbage") };
    let stub = toolStub([{ tag_name: "v1.0.0", assets: [corrupt] }], "v1.0.0");
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "o/tool", "latest", "tool"]);
      expect(r.code).toBe(0);
      expect(sb.files()).toEqual([]);
    });
    // Release JSON lists an asset the stub does not serve (404).
    const ghost: Asset = { name: "tool-linux-amd64.tar", bytes: tar({ tool: "x" }) };
    stub = startStub([], releaseHandler(() => stub.url, [{ tag_name: "v1.0.0", assets: [ghost] }]));
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "o/tool", "latest", "tool"]);
      expect(r.code).toBe(0);
      expect(r.stderr).toContain("Failed to download asset");
      expect(sb.files()).toEqual([]);
    });
  });
});

describe("create: release and tag selection", () => {
  test("DSPKG-011 latest, exact and caret tags use the single-release endpoints", async () => {
    const asset: Asset = { name: "tool-linux-amd64.tar", bytes: tar({ tool: "x" }) };
    const rels: Release[] = [
      { tag_name: "v1.2.3", assets: [asset] },
      { tag_name: "1.2.3", assets: [asset] },
      { tag_name: "^1.2.3", assets: [asset] }, // only reachable if the caret is sent verbatim
    ];
    const cases: Array<[string, string, string]> = [
      ["latest", "/repos/o/tool/releases/latest", "v1.2.3"],
      ["v1.2.3", "/repos/o/tool/releases/tags/v1.2.3", "v1.2.3"],
      ["1.2.3", "/repos/o/tool/releases/tags/1.2.3", "1.2.3"],
      // Help text promises caret ranges, but ^ is not detected as a range: it is a literal tag.
      ["^1.2.3", "/repos/o/tool/releases/tags/%5E1.2.3", "^1.2.3"],
    ];
    for (const [tag, path, resolved] of cases) {
      const stub = toolStub(rels, "v1.2.3", [asset]);
      await withStub(stub, async () => {
        const sb = sandbox();
        const r = await run(sb, stub, ["create", "o/tool", tag, "tool"]);
        expect(r.code).toBe(0);
        expect(stub.requests[0]).toBe(path);
        expect(stub.requests.some((q) => q === "/repos/o/tool/releases")).toBe(false);
        const m = parseManifest(sb.read("tool")).json;
        expect(m.platforms["linux-x86_64"].providers[1].tag).toBe(resolved);
        expect(m.metadata.build_info.tag).toBe(tag);
      });
    }
  });

  test("DSPKG-012 semver ranges list releases and choose the highest satisfying tag", async () => {
    const asset: Asset = { name: "tool-linux-amd64.tar", bytes: tar({ tool: "x" }) };
    const tags = ["v1.0.0", "v1.2.3", "v1.9.0", "v2.0.0", "v2.1.0-beta.1", "nightly", "3.0.0", "v1.10.0-rc.1"];
    const rels: Release[] = tags.map((t) => ({ tag_name: t, assets: [asset] }));
    const cases: Array<[string, string]> = [
      [">=1.0.0 <2.0.0", "v1.9.0"],
      ["<2.0.0", "v1.9.0"],
      ["<=2.0.0", "v2.0.0"],
      ["~1.2.0", "v1.2.3"],
      [">1.2.3", "3.0.0"], // tag without v prefix is matched
      [">=1.0.0", "3.0.0"],
      ["1.0.0 - 1.5.0", "v1.2.3"],
      ["=1.2.3", "v1.2.3"],
      [">=2.1.0-beta.1 <3.0.0", "v2.1.0-beta.1"], // prerelease only when named by the range
      ["<2.1.0 >1.9.0", "v2.0.0"],
    ];
    const stub = toolStub(rels, undefined, [asset]);
    await withStub(stub, async () => {
      for (const [range, expected] of cases) {
        const sb = sandbox();
        const before = stub.requests.length;
        const r = await run(sb, stub, ["create", "o/tool", range, "tool"]);
        expect(r.code).toBe(0);
        expect(stub.requests[before]).toBe("/repos/o/tool/releases");
        const m = parseManifest(sb.read("tool")).json;
        expect([range, m.platforms["linux-x86_64"].providers[1].tag]).toEqual([range, expected]);
        expect(m.metadata.build_info.tag).toBe(range);
      }
    });
  });

  test("DSPKG-012 a leading v in the range operand is stripped before matching", async () => {
    const asset: Asset = { name: "tool-linux-amd64.tar", bytes: tar({ tool: "x" }) };
    const rels: Release[] = ["v1.0.0", "v1.5.0"].map((t) => ({ tag_name: t, assets: [asset] }));
    const stub = toolStub(rels, undefined, [asset]);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["create", "o/tool", "=v1.0.0", "tool"]);
      expect(r.code).toBe(0);
      // "=v1.0.0" does not start with v, so only "v" prefix removal at index 0 is skipped;
      // semver itself accepts the v in the comparator.
      expect(parseManifest(sb.read("tool")).json.platforms["linux-x86_64"].providers[1].tag).toBe("v1.0.0");
    });
  });

  test("DSPKG-013 unsatisfiable range and API failures log, write nothing and exit 0", async () => {
    const asset: Asset = { name: "tool-linux-amd64.tar", bytes: tar({ tool: "x" }) };
    const rels: Release[] = [{ tag_name: "v1.0.0", assets: [asset] }];
    let stub = toolStub(rels, undefined, [asset]);
    await withStub(stub, async () => {
      for (const [tag, message] of [
        [">=9.0.0", "No matching version found for >=9.0.0"],
        ["v404", "Failed to fetch release"],
      ]) {
        const sb = sandbox();
        const r = await run(sb, stub, ["create", "o/tool", tag, "tool"]);
        expect(r.code).toBe(0);
        expect(r.stderr).toContain(message);
        expect(sb.files()).toEqual([]);
        expect(r.stdout).toBe("");
      }
    });
    // Unknown repository (404) and server error (500) on both endpoints.
    stub = startStub([], (_r, url) => url.pathname.endsWith("/releases") ? new Response("x", { status: 500 }) : undefined);
    await withStub(stub, async () => {
      for (const [tag, message] of [["latest", "Failed to fetch release"], [">=1.0.0", "Failed to fetch releases"]]) {
        const sb = sandbox();
        const r = await run(sb, stub, ["create", "o/tool", tag, "tool"]);
        expect(r.code).toBe(0);
        expect(r.stderr).toContain(message);
        expect(sb.files()).toEqual([]);
      }
    });
  });

  test("DSPKG-013 an unreachable GitHub API logs and exits 0 without a manifest", async () => {
    const sb = sandbox();
    const r = await run(sb, null, ["create", "o/tool", "latest", "tool"]);
    // runtime-specific stderr not pinned
    expect(r.code).toBe(0);
    expect(sb.files()).toEqual([]);
  });

  test("DSPKG-014 argument validation", async () => {
    const stub = toolStub();
    await withStub(stub, async () => {
      for (const args of [["create", "noslash", "v2.0.0", "tool"], ["create", "/repo", "v2.0.0", "tool"], ["create", "owner/", "v2.0.0", "tool"]]) {
        const sb = sandbox();
        const r = await run(sb, stub, args);
        expect(r.code).toBe(1);
        expect(r.stderr).toContain("Repository must be in format owner/repo");
        expect(sb.files()).toEqual([]);
      }
      // Missing positional arguments crash inside the script's top-level catch: exit 0, no output file.
      // runtime-specific stderr not pinned
      for (const args of [["create"], ["create", "o/tool"], ["create", "o/tool", "v2.0.0"]]) {
        const sb = sandbox();
        const r = await run(sb, stub, args);
        expect(r.code).toBe(0);
        expect(r.stdout).toBe("");
        expect(sb.files()).toEqual([]);
      }
      expect(stub.requests).toEqual([]);
    });
  });
});

describe("create from a URL", () => {
  const BASE = JSON.stringify({ name: "foo", platforms: { "linux-x86_64": { url: "http://x/y" } } });

  test("DSPKG-015 writes the dotslash create-url-entry output plus build_info", async () => {
    for (const url of ["http://example.test/foo.tar.gz", "https://example.test/foo.tar.gz"]) {
      const sb = sandbox();
      const r = await run(sb, null, ["create", url, "myfoo"], { FAKE_DOTSLASH_JSON: BASE });
      expect(r.code).toBe(0);
      expect(sb.logLines()).toEqual([`dotslash -- create-url-entry ${url}`]);
      expect(sb.files()).toEqual(["myfoo"]);
      const m = parseManifest(sb.read("myfoo"));
      expect(m.first).toBe(SHEBANG);
      expect(m.blank).toBe("");
      expect(m.body).toBe(JSON.stringify(m.json, null, 2));
      expect(Object.keys(m.json)).toEqual(["name", "platforms", "metadata"]);
      expect(m.json.name).toBe("foo");
      expect(m.json.platforms).toEqual({ "linux-x86_64": { url: "http://x/y" } });
      expect(m.json.metadata.build_info).toEqual({
        created_at: expect.stringMatching(ISO),
        build_tool: BIN_NAME,
        command: `${BIN_NAME} create '${url}' myfoo`,
        tag: "",
      });
      expect(modeOf(join(sb.cwd, "myfoo"))).toBe(0o755);
    }
  });

  test("DSPKG-015 the URL test is case-insensitive and metadata from dotslash is replaced", async () => {
    const sb = sandbox();
    const base = JSON.stringify({ name: "foo", platforms: {}, metadata: { keep: "no" } });
    const r = await run(sb, null, ["create", "HTTPS://example.test/a", "out"], { FAKE_DOTSLASH_JSON: base });
    expect(r.code).toBe(0);
    const m = parseManifest(sb.read("out")).json;
    expect(Object.keys(m.metadata)).toEqual(["build_info"]);
  });

  test("DSPKG-016 missing name, failing dotslash or invalid JSON write nothing and exit 0", async () => {
    // runtime-specific stderr not pinned
    for (const [args, env] of [
      [["create", "https://example.test/a"], { FAKE_DOTSLASH_JSON: BASE }],
      [["create", "https://example.test/a", "out"], { FAKE_DOTSLASH_JSON: BASE, FAKE_DOTSLASH_FAIL: "1" }],
      [["create", "https://example.test/a", "out"], { FAKE_DOTSLASH_JSON: "not json" }],
    ] as const) {
      const sb = sandbox();
      const r = await run(sb, null, [...args], { ...env });
      expect(r.code).toBe(0);
      expect(sb.files()).toEqual([]);
    }
  });
});

// A manifest as written by create: shebang line then JSON carrying the recorded command.
function manifestText(command: string, extra = "") {
  return `${SHEBANG}\n${extra}{"name":"m","platforms":{},"metadata":{"build_info":{"command":${JSON.stringify(command)},"tag":"t"}}}\n`;
}

describe("update", () => {
  test("DSPKG-017 with no manifests nothing runs", async () => {
    const sb = sandbox();
    sb.write("m", manifestText(`${BIN_NAME} create o/r 1.0 tool`));
    const r = await run(sb, null, ["update"]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe("");
    expect(sb.logLines()).toEqual([]);
  });

  test("DSPKG-017 re-runs the recorded create command, tolerating JSONC comments and trailing commas", async () => {
    const sb = sandbox();
    sb.write(
      "m1",
      `${SHEBANG}\n// comment\n{\n  "name": "m", /* block */\n  "platforms": {},\n  "metadata": {"build_info": {"command": "${BIN_NAME} create 'o/r' '>=1.0 <2' '*/a b'", "tag": "t",},},\n}\n`,
    );
    const r = await run(sb, null, ["update", join(sb.cwd, "m1")]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe(`Updating ${BIN_NAME} create 'o/r' '>=1.0 <2' '*/a b'\n`);
    expect(r.stderr).toBe(`> ${BIN_NAME} create 'o/r' '>=1.0 <2' '*/a b'\n`); // dax printCommand
    // The command string runs through a shell: quoting is honoured, one argv entry per word.
    expect(sb.logLines()).toEqual(["[create][o/r][>=1.0 <2][*/a b]"]);
  });

  test("DSPKG-017 multiple manifests update in the order given; relative paths work", async () => {
    const sb = sandbox();
    sb.write("a", manifestText(`${BIN_NAME} create o/a 1 pa`));
    sb.write("b", manifestText(`${BIN_NAME} create o/b 2 pb`));
    const r = await run(sb, null, ["update", "b", "a"]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe(`Updating ${BIN_NAME} create o/b 2 pb\nUpdating ${BIN_NAME} create o/a 1 pa\n`);
    expect(r.stderr).toBe(`> ${BIN_NAME} create o/b 2 pb\n> ${BIN_NAME} create o/a 1 pa\n`);
    expect(sb.logLines()).toEqual(["[create][o/b][2][pb]", "[create][o/a][1][pa]"]);
  });

  test("DSPKG-018 non-create commands are reported unsupported and not run", async () => {
    const sb = sandbox();
    sb.write("m", manifestText("something else entirely"));
    const r = await run(sb, null, ["update", "m"]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe("Updating something else entirely\n");
    expect(r.stderr).toContain("Unsupported command: something else entirely");
    expect(r.stderr).toContain("Create it manually first");
    expect(sb.logLines()).toEqual([]);
  });

  test("DSPKG-018 an unparseable manifest aborts the rest of the run but exits 0", async () => {
    const sb = sandbox();
    sb.write("a_bad", `${SHEBANG}\n{"name": oops}\n`);
    sb.write("b_good", manifestText(`${BIN_NAME} create o/b 2 pb`));
    const r = await run(sb, null, ["update", "a_bad", "b_good"]);
    // runtime-specific stderr not pinned
    expect(r.code).toBe(0);
    expect(r.stdout).toBe("");
    expect(sb.logLines()).toEqual([]);
  });

  test("DSPKG-018 a manifest without build_info aborts with exit 0 and runs nothing", async () => {
    const sb = sandbox();
    sb.write("m", `${SHEBANG}\n{"name":"m","platforms":{},"metadata":{}}\n`);
    const r = await run(sb, null, ["update", "m"]);
    expect(r.code).toBe(0);
    expect(sb.logLines()).toEqual([]);
  });

  test("DSPKG-018 a failing recorded command is logged and the exit code stays 0", async () => {
    const sb = sandbox();
    sb.write("m", manifestText("no-such-binary-xyz create o/r 1 p"));
    const r = await run(sb, null, ["update", "m"]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe("Updating no-such-binary-xyz create o/r 1 p\n");
  });
});

describe("manifest discovery (update and check)", () => {
  const files: Array<[string, string]> = [
    ["a-dotslash", `${SHEBANG}\n{"n":1}\n`],
    ["b-usr-bin", `#!/usr/bin/dotslash\n{}\n`],
    ["c-crlf", `${SHEBANG}\r\n{}\r\n`],
    ["d-nospace", `#!dotslash\n{}\n`],
    ["e-sh", `#!/bin/sh\necho hi\n`],
    ["f-text", `hello dotslash\n`],
    ["g-empty", ``],
    ["h-args", `${SHEBANG} --flag\n{}\n`],
    ["i-nopound", `/usr/bin/env dotslash\n{}\n`],
  ];
  const EXPECTED = ["a-dotslash", "b-usr-bin", "c-crlf", "d-nospace"];

  test("DSPKG-019 check on a directory considers only direct files with a dotslash shebang first line", async () => {
    // Only a-dotslash is a real manifest here: checking runs the manifest, and the other
    // shebang variants (see the update test below) would fail to spawn.
    const sb = sandbox();
    for (const [name, content] of files) sb.write(`dir/${name}`, content, 0o755);
    sb.write("dir/sub/nested", `${SHEBANG}\n{}\n`, 0o755); // not recursive
    const r = await run(sb, null, ["check", "dir"], { LOG_LEVEL: "DEBUG" });
    expect(r.stdout).toContain("Checking dir/a-dotslash by running");
    for (const n of ["e-sh", "f-text", "g-empty", "h-args", "i-nopound", "nested"]) {
      expect(r.stdout).not.toContain(`Checking dir/${n}`);
    }
    // Every direct file is probed (debug lines); the shebang check decides which are manifests.
    expect(r.stdout).toContain(`First line of dir/a-dotslash: ${SHEBANG}`);
    expect(r.stdout).toContain("First line of dir/e-sh: #!/bin/sh");
    expect(r.stdout).not.toContain("First line of dir/sub");
  });

  test("DSPKG-019 update on a directory processes exactly the manifests found", async () => {
    const sb = sandbox();
    for (const [name, content] of files) {
      const body = content.startsWith("#!") && content.includes("dotslash") && !content.includes("--flag")
        ? content.split("\n")[0] + `\n{"name":"m","metadata":{"build_info":{"command":"${BIN_NAME} create o/r 1 ${name}"}}}\n`
        : content;
      sb.write(`dir/${name}`, body);
    }
    sb.write("dir/sub/nested", manifestText(`${BIN_NAME} create o/r 1 nested`));
    const r = await run(sb, null, ["update", "dir"]);
    expect(r.code).toBe(0);
    expect(sb.logLines().sort()).toEqual(EXPECTED.map((n) => `[create][o/r][1][${n}]`).sort());
  });

  test("DSPKG-019 missing paths and non-manifest files are skipped silently", async () => {
    const sb = sandbox();
    sb.write("plain", "just text\n");
    sb.write("real", manifestText(`${BIN_NAME} create o/r 1 real`));
    const r = await run(sb, null, ["update", "missing", "plain", "real", "also-missing/"]);
    expect(r.code).toBe(0);
    expect(r.stderr).not.toContain("missing");
    expect(sb.logLines()).toEqual(["[create][o/r][1][real]"]);
  });
});

describe("check", () => {
  test("DSPKG-020 announces each manifest, runs it with --version and exits 0", async () => {
    const sb = sandbox();
    const a = sb.write("a", manifestText("x"), 0o755);
    const b = sb.write("b", manifestText("y"), 0o755);
    const r = await run(sb, null, ["check", a, b]);
    expect(r.code).toBe(0);
    expect(r.stdout).toBe(`Checking ${a} by running\nChecking ${b} by running\n`);
    // Executing the manifest runs its shebang interpreter: the fake dotslash logs "<file> --version".
    // Only --version is tried: the probe loop never moves on to -v / version.
    expect(sb.logLines().sort()).toEqual([`dotslash ${a} --version`, `dotslash ${b} --version`]);
    // dax printCommand lines (the two runs are not awaited, so their order is not pinned)
    expect(r.stderr.split("\n").filter(Boolean).sort()).toEqual([`> '${a}' '--version'`, `> '${b}' '--version'`].sort());
  });

  test("DSPKG-020 a manifest with TODO: warns on stderr", async () => {
    const sb = sandbox();
    const a = sb.write("a", `${SHEBANG}\n{"name":"m"} \n// TODO: fix me\n`, 0o755);
    const r = await run(sb, null, ["check", a]);
    expect(r.code).toBe(0);
    expect(r.stderr).toBe(`${a} has TODOs\n${SHEBANG}\n{"name":"m"} \n//\nfix me\n> '${a}' '--version'\n`);
    const clean = sandbox();
    const c = clean.write("c", manifestText("x"), 0o755);
    expect((await run(clean, null, ["check", c])).stderr).not.toContain("has TODOs");
  });

  test("DSPKG-020 a manifest that fails --version is not reported as an error and still exits 0", async () => {
    // Known quirk: the probe's async predicate is always truthy, so the failure branch is dead.
    const sb = sandbox();
    const a = sb.write("a", manifestText("x"), 0o755);
    const r = await run(sb, null, ["check", a], { FAKE_DOTSLASH_FAIL: "1" });
    expect(r.code).toBe(0);
    expect(r.stderr).not.toContain("supports none of");
  });

  test("DSPKG-020 no arguments or no manifests: nothing happens", async () => {
    const sb = sandbox();
    sb.write("plain", "text\n");
    for (const args of [["check"], ["check", "plain", "missing"]]) {
      const r = await run(sb, null, args);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("");
      expect(sb.logLines()).toEqual([]);
    }
  });
});

describe("install", () => {
  test("DSPKG-021 http ref with --output writes the body, mode 0755, and reports", async () => {
    const stub = startStub([], (_r, url) => url.pathname === "/files/tool.sh" ? new Response("#!/bin/sh\necho hi\n") : undefined);
    await withStub(stub, async () => {
      for (const outArgs of [["--output", "out.sh"], ["--output=out.sh"]]) {
        const sb = sandbox();
        const r = await run(sb, stub, ["install", `${stub.url}/files/tool.sh`, ...outArgs]);
        expect(r.code).toBe(0);
        expect(r.stdout).toBe("Installed out.sh\n");
        expect(sb.read("out.sh")).toBe("#!/bin/sh\necho hi\n");
        expect(modeOf(join(sb.cwd, "out.sh"))).toBe(0o755);
        expect(sb.files()).toEqual(["out.sh"]);
      }
    });
  });

  test("DSPKG-021 the response status is not checked: an error body is written as is", async () => {
    const stub = startStub([]);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", `${stub.url}/missing`, "--output", "out"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("Installed out\n");
      expect(sb.read("out")).toBe("not found");
    });
  });

  test("DSPKG-021 http ref without --output cannot write to the URL path and fails non-zero", async () => {
    const stub = startStub([], () => new Response("body"));
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", `${stub.url}/x`]);
      // runtime-specific stderr not pinned
      expect(r.code).toBe(1);
      expect(r.stdout).not.toContain("Installed");
      expect(sb.files()).toEqual([]);
    });
  });

  test("DSPKG-022 github:// refs are accepted and ignored", async () => {
    const stub = startStub([]);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", "github://a/b/c"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("");
      expect(sb.files()).toEqual([]);
      expect(stub.requests).toEqual([]);
    });
  });

  test("DSPKG-022 owner/repo/path resolves the default branch via the API and fetches raw content", async () => {
    // API 404 for the repository: fails before any raw content is requested.
    let stub = startStub([]);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", "o/r/bin/tool.sh"]);
      expect(r.code).toBe(1);
      expect(stub.requests).toEqual(["/repos/o/r"]);
      expect(sb.files()).toEqual([]);
      expect(r.stdout).not.toContain("Installed");
    });
    const raw: Handler = (_r, url) => {
      if (url.pathname === "/repos/o/r") return Response.json({ default_branch: "main" });
      if (url.pathname === "/o/r/main/bin/tool.sh" || url.pathname === "/o/r/v1/bin/tool.sh") return new Response("#!/bin/sh\necho raw\n");
      return undefined;
    };
    stub = startStub([], raw);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", "o/r/bin/tool.sh"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("Installed tool.sh\n");
      expect(stub.requests).toEqual(["/repos/o/r", "/o/r/main/bin/tool.sh"]);
      expect(sb.files()).toEqual(["tool.sh"]);
      expect(sb.read("tool.sh")).toBe("#!/bin/sh\necho raw\n");
      expect(modeOf(join(sb.cwd, "tool.sh"))).toBe(0o755);
    });
    // A #fragment names the ref: no API call, and --output picks the destination.
    stub = startStub([], raw);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", "o/r/bin/tool.sh#v1", "--output", "dest.sh"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("Installed dest.sh\n");
      expect(stub.requests).toEqual(["/o/r/v1/bin/tool.sh"]);
      expect(sb.files()).toEqual(["dest.sh"]);
      expect(sb.read("dest.sh")).toBe("#!/bin/sh\necho raw\n");
      expect(modeOf(join(sb.cwd, "dest.sh"))).toBe(0o755);
    });
  });

  test("DSPKG-022 a non-2xx raw response exits 1 and writes nothing", async () => {
    const stub = startStub([], (_r, url) => url.pathname === "/repos/o/r" ? Response.json({ default_branch: "main" }) : undefined);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", "o/r/bin/tool.sh"]);
      // runtime-specific stderr not pinned
      expect(r.code).toBe(1);
      expect(r.stdout).toBe("");
      expect(stub.requests).toEqual(["/repos/o/r", "/o/r/main/bin/tool.sh"]);
      expect(sb.files()).toEqual([]);
    });
  });

  test("DSPKG-021 several refs are started concurrently, not awaited in order", async () => {
    // The slow first ref finishes last, so it writes last: its body wins. Sequential handling would leave "B".
    const stub = startStub([], (_r, url) => {
      if (url.pathname === "/a") return new Promise<Response>((res) => setTimeout(() => res(new Response("A")), 600)) as unknown as Response;
      if (url.pathname === "/b") return new Response("B");
      return undefined;
    });
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", `${stub.url}/a`, `${stub.url}/b`, "--output", "out"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe("Installed out\nInstalled out\n");
      expect(stub.requests).toEqual(["/a", "/b"]);
      expect(sb.read("out")).toBe("A");
    });
  });

  test("DSPKG-022 owner/repo/ with an empty path fails non-zero without any request", async () => {
    const stub = startStub([]);
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["install", "o/r/"]);
      expect(r.code).toBe(1);
      expect(stub.requests).toEqual([]);
      expect(sb.files()).toEqual([]);
    });
  });
});

describe("search", () => {
  const searchHandler = (items: unknown[]): Handler => (_r, url) =>
    url.pathname === "/search/repositories" ? Response.json({ items }) : undefined;

  test("DSPKG-023 empty results print a notice; the query is encoded and sorted by stars", async () => {
    const stub = startStub([], searchHandler([]));
    await withStub(stub, async () => {
      for (const [args, q] of [
        [["search", "zzz"], "zzz"],
        [["install", "zzz"], "zzz"], // no slash: searched
        [["install", "owner/repo"], "owner%2Frepo"], // one slash: searched
        [["search", "a b/c&d"], "a%20b%2Fc%26d"],
      ] as const) {
        const sb = sandbox();
        const before = stub.requests.length;
        const r = await run(sb, stub, [...args]);
        expect(r.code).toBe(0);
        expect(r.stdout).toBe(`No results found for "${args[1]}"\n`);
        expect(stub.requests[before]).toBe(`/search/repositories?q=${q}&sort=stars&order=desc`);
        expect(sb.files()).toEqual([]);
      }
    });
  });

  test("DSPKG-023 multiple search terms are searched in order; no terms do nothing", async () => {
    const stub = startStub([], searchHandler([]));
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await run(sb, stub, ["search", "one", "two"]);
      expect(r.code).toBe(0);
      expect(r.stdout).toBe(`No results found for "one"\nNo results found for "two"\n`);
      expect(stub.requests).toEqual([
        "/search/repositories?q=one&sort=stars&order=desc",
        "/search/repositories?q=two&sort=stars&order=desc",
      ]);
      const none = await run(sb, stub, ["search"]);
      expect(none.code).toBe(0);
      expect(none.stdout).toBe("");
    });
  });

  test("DSPKG-024 search API failure: `search` logs and exits 0, `install <term>` exits non-zero", async () => {
    const stub = startStub([], () => new Response("boom", { status: 500 }));
    await withStub(stub, async () => {
      const sb = sandbox();
      const s = await run(sb, stub, ["search", "zzz"]);
      expect(s.code).toBe(0);
      expect(s.stderr).toContain("Failed to search GitHub");
      expect(s.stdout).toBe("");
      const i = await run(sb, stub, ["install", "zzz"]);
      // runtime-specific stderr not pinned
      expect(i.code).toBe(1);
      expect(i.stdout).toBe("");
    });
  });
});

describe("search (interactive, driven through a pty)", () => {
  // prompt rendering not pinned; effects only.
  const asset: Asset = { name: "tool-1.0.0-linux-amd64.tar", bytes: tar({ tool: "interactive\n" }) };
  const items = [
    { name: "toolbox", full_name: "o/toolbox", stargazers_count: 9, description: null, owner: { login: "o" } },
    { name: "tool", full_name: "o/tool", stargazers_count: 5, description: "d", owner: { login: "o" } },
  ];
  const releases: Release[] = [
    { tag_name: "v1.0.0", name: "One", assets: [asset] },
    { tag_name: "v0.9.0", assets: [asset], prerelease: true },
  ];
  function interactiveStub() {
    let stub!: Stub;
    const rel = releaseHandler(() => stub.url, releases);
    stub = startStub([asset], (req, url) => {
      if (url.pathname === "/search/repositories") return Response.json({ items });
      return rel(req, url);
    });
    return stub;
  }
  // Rewritten in terms of o/tool because the closest name to the term "tool" is listed first.
  const toolRel = (stub: Stub) => stub.requests.filter((q) => q.includes("/releases"));

  test("DSPKG-025 select, confirm, pick a release, accept the default name: manifest created", async () => {
    const stub = interactiveStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      // first result (closest name to "tool" is o/tool), y + enter, down to v1.0.0 + enter, default name.
      const r = await runTty(sb, stub, ["search", "tool"], [ENTER, "y", ENTER, DOWN, ENTER, ENTER]);
      expect(r.code).toBe(0);
      expect(r.out).toContain("Installed tool to tool");
      expect(sb.files()).toEqual(["tool"]);
      const m = parseManifest(sb.read("tool")).json;
      expect(m.name).toBe("tool");
      expect(m.platforms["linux-x86_64"]).toEqual({
        size: asset.bytes.length,
        hash: "blake3",
        digest: expect.stringMatching(/^[0-9a-f]{64}$/),
        path: "tool",
        format: "tar",
        providers: [
          { url: `${stub.url}/dl/${asset.name}` },
          { type: "github-release", repo: "o/tool", tag: "v1.0.0", name: asset.name },
        ],
        readonly: true,
      });
      // The recorded command is the equivalent create, not `search`.
      expect(m.metadata.build_info.command).toBe(`${BIN_NAME} create 'o/tool' 'v1.0.0' tool`);
      expect(m.metadata.build_info.tag).toBe("v1.0.0");
      expect(stub.requests).toContain("/repos/o/tool/releases/tags/v1.0.0");
      expect(modeOf(join(sb.cwd, "tool"))).toBe(0o755);
    });
  });

  test("DSPKG-025 a typed output name is used for the output file", async () => {
    const stub = interactiveStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await runTty(sb, stub, ["search", "tool"], [ENTER, "y", ENTER, DOWN, ENTER, "x\r"]);
      expect(r.code).toBe(0);
      expect(r.out).toContain("Installed x to x");
      expect(sb.files()).toEqual(["x"]);
      expect(parseManifest(sb.read("x")).json.metadata.build_info.command).toBe(`${BIN_NAME} create 'o/tool' 'v1.0.0' x`);
    });
  });

  test("DSPKG-025 search --output only changes the reported destination, not the file written", async () => {
    const stub = interactiveStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await runTty(sb, stub, ["search", "tool", "--output", "dest"], [ENTER, "y", ENTER, DOWN, ENTER, ENTER]);
      expect(r.code).toBe(0);
      expect(r.out).toContain("Installed tool to dest");
      expect(sb.files()).toEqual(["tool"]);
    });
  });

  test("DSPKG-025 declining the confirmation writes nothing and fetches no releases", async () => {
    const stub = interactiveStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await runTty(sb, stub, ["search", "tool"], [ENTER, "n", ENTER]);
      expect(r.code).toBe(0);
      expect(r.out).toContain("Installation cancelled");
      expect(sb.files()).toEqual([]);
      expect(toolRel(stub)).toEqual([]);
    });
  });

  test("DSPKG-026 choosing the first tag entry (latest) writes no manifest", async () => {
    // Known bug: the "latest" option's value is the string "latest", so tag.tag_name is undefined.
    const stub = interactiveStub();
    await withStub(stub, async () => {
      const sb = sandbox();
      const r = await runTty(sb, stub, ["search", "tool"], [ENTER, "y", ENTER, ENTER, ENTER]);
      // Unhandled rejection after the (unawaited) create is started: exit 1, but the success line was already printed.
      expect(r.code).toBe(1);
      expect(r.out).toContain("Installed tool to tool");
      expect(sb.files()).toEqual([]);
      expect(stub.requests.some((q) => q.includes("/releases/tags/"))).toBe(false);
    });
  });
});

describe("logging", () => {
  test("DSPKG-027 --verbose and LOG_LEVEL=DEBUG print debug lines; default does not", async () => {
    const sb = sandbox();
    const m = sb.write("m", manifestText(`${BIN_NAME} create o/r 1 p`));
    const plain = await run(sb, null, ["update", m]);
    expect(plain.stdout).not.toContain("First line of");
    const verbose = await run(sb, null, ["update", m, "--verbose"]);
    expect(verbose.stdout).toContain(`First line of ${m}: ${SHEBANG}`);
    expect(verbose.stdout).toContain("isShebang: true, isDotslash: true");
    const env = await run(sb, null, ["update", m], { LOG_LEVEL: "DEBUG" });
    expect(env.stdout).toContain(`First line of ${m}: ${SHEBANG}`);
  });

  test("DSPKG-027 LOG_LEVEL=ERROR silences info and warnings; an unrecognised level silences everything", async () => {
    const sb = sandbox();
    const m = sb.write("m", manifestText("other command"), 0o755);
    const base = await run(sb, null, ["update", m]);
    expect(base.stdout).toBe("Updating other command\n");
    expect(base.stderr).toContain("Unsupported command");
    const err = await run(sb, null, ["update", m], { LOG_LEVEL: "ERROR" });
    expect(err.stdout).toBe("");
    expect(err.stderr).toContain("Unsupported command");
    const warn = await run(sb, null, ["update", m], { LOG_LEVEL: "WARN" });
    expect(warn.stdout).toBe("");
    expect(warn.stderr).toContain("Unsupported command");
    // Quirk: an unknown level compares as undefined, so every logger method is skipped.
    const bogus = await run(sb, null, ["update", m], { LOG_LEVEL: "bogus" });
    expect(bogus.code).toBe(0);
    expect(bogus.stdout).toBe("");
    expect(bogus.stderr).not.toContain("Unsupported command");
  });
});
