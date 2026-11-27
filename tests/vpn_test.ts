// Blackbox tests for ~/bin/vpn. Fake tailscale and curl CLIs stand in for the real ones.
//
// VPN-001: WHEN run as `vpn on`, the script SHALL set the exit node to mini.
// VPN-002: WHEN run as `vpn off`, the script SHALL clear the exit node.
// VPN-003: WHEN run without arguments or as `vpn toggle` AND no exit node is set, the script SHALL set it to mini.
// VPN-004: WHEN run without arguments or as `vpn toggle` AND any exit node is set, the script SHALL clear it.
// VPN-005: IF the arguments are not empty, `on`, `off`, `toggle` or `status`, THEN the script SHALL print usage, exit 2 and change nothing.
// VPN-006: IF the current state cannot be read while toggling, THEN the script SHALL exit non-zero and change nothing.
// VPN-007: IF setting the exit node fails, THEN the script SHALL exit non-zero and SHALL NOT report success.
// VPN-008: WHEN the exit node is changed, the script SHALL print the status report of the new state.
// VPN-009: WHILE Tailscale is stopped, WHEN turning on, the script SHALL warn that traffic is not yet routed.
// VPN-010: WHEN run as `vpn status`, the script SHALL report on/off, Tailscale state, exit node, LAN access and public IP, and change nothing.
// VPN-011: IF the public IP lookup fails, THEN the report SHALL show it as unknown and the command SHALL still succeed.
// VPN-012: IF the state cannot be read for `vpn status`, THEN the script SHALL exit non-zero.
// VPN-013: WHEN toggling, the script SHALL print which way it is switching.
// VPN-014: IF the report fails after a successful change, THEN the script SHALL warn and exit 0.
import assert from "node:assert/strict";
import { fileURLToPath } from "node:url";

const SCRIPT = Deno.env.get("VPN_SCRIPT") ??
  fileURLToPath(new URL("../home/bin/executable_vpn", import.meta.url));
const USAGE_EXIT = 2;
const SET_ON = "set --exit-node=mini";
const SET_OFF = "set --exit-node=";
const PUBLIC_IP = "203.0.113.7";

// Calls other than reads are logged. `set` rewrites the prefs so reports see the new state.
const FAKE_TAILSCALE = `#!/usr/bin/env bash
case "$*" in
  "debug prefs")
    [ -n "$FAKE_PREFS_FAIL" ] && { echo "Failed to load preferences." >&2; exit 1; }
    cat "$FAKE_STATE" ;;
  "status --json")
    [ -n "$FAKE_STATUS_FAIL" ] && exit 1
    if grep -q '"ExitNodeID":"abc"' "$FAKE_STATE"; then
      echo '{"BackendState":"Running","Peer":{"k":{"DNSName":"mini.example.test.","ExitNode":true,"Online":true}}}'
    else
      echo '{"BackendState":"Running","Peer":{}}'
    fi ;;
  "set --exit-node="*)
    echo "$*" >> "$FAKE_LOG"
    [ -n "$FAKE_SET_FAIL" ] && { echo "set failed" >&2; exit 1; }
    id=""; [ "$2" != "--exit-node=" ] && id=abc
    printf '{"ExitNodeID":"%s","WantRunning":true}' "$id" > "$FAKE_STATE" ;;
  *)
    echo "$*" >> "$FAKE_LOG"; exit 1 ;;
esac
`;
const FAKE_CURL = `#!/usr/bin/env bash
[ -n "$FAKE_CURL_FAIL" ] && exit 28
echo ${PUBLIC_IP}
`;

const prefs = (extra: Record<string, unknown> = {}) =>
  JSON.stringify({ ExitNodeID: "", ExitNodeIP: "", WantRunning: true, ...extra });
const ON = prefs({ ExitNodeID: "abc" });

async function run(args: string[], env: Record<string, string> = {}) {
  const dir = await Deno.makeTempDir();
  try {
    const log = `${dir}/calls`;
    const state = `${dir}/prefs`;
    await Deno.writeTextFile(`${dir}/tailscale`, FAKE_TAILSCALE, { mode: 0o755 });
    await Deno.writeTextFile(`${dir}/curl`, FAKE_CURL, { mode: 0o755 });
    await Deno.writeTextFile(log, "");
    await Deno.writeTextFile(state, env.FAKE_PREFS ?? prefs());
    const out = await new Deno.Command("bash", {
      args: [SCRIPT, ...args],
      env: {
        VPN_TAILSCALE: `${dir}/tailscale`,
        VPN_CURL: `${dir}/curl`,
        FAKE_LOG: log,
        FAKE_STATE: state,
        ...env,
      },
    }).output();
    const calls = (await Deno.readTextFile(log)).split("\n").filter(Boolean);
    const text = new TextDecoder();
    return { code: out.code, calls, stdout: text.decode(out.stdout), stderr: text.decode(out.stderr) };
  } finally {
    await Deno.remove(dir, { recursive: true });
  }
}

const REPORT_ON = [/^VPN: on$/m, /Exit node: +mini \(online\)/, /LAN access: +blocked/, new RegExp(`Public IP: +${PUBLIC_IP}`)];
const REPORT_OFF = [/^VPN: off$/m, /Exit node: +none/, /LAN access: +allowed/, new RegExp(`Public IP: +${PUBLIC_IP}`)];
const matchAll = (text: string, patterns: RegExp[]) => patterns.forEach((p) => assert.match(text, p));

Deno.test("VPN-001 VPN-008 on sets mini and reports", async () => {
  const r = await run(["on"]);
  assert.equal(r.code, 0, r.stderr);
  assert.deepEqual(r.calls, [SET_ON]);
  matchAll(r.stdout, REPORT_ON);
  assert.doesNotMatch(r.stderr, /stopped/);
});

Deno.test("VPN-002 VPN-008 off clears the exit node and reports", async () => {
  const r = await run(["off"], { FAKE_PREFS: ON });
  assert.equal(r.code, 0, r.stderr);
  assert.deepEqual(r.calls, [SET_OFF]);
  matchAll(r.stdout, REPORT_OFF);
});

Deno.test("VPN-003 VPN-013 toggle from off turns on", async () => {
  for (const args of [[], ["toggle"]]) {
    const r = await run(args);
    assert.equal(r.code, 0, r.stderr);
    assert.deepEqual(r.calls, [SET_ON]);
    matchAll(r.stdout, [/off -> on/, ...REPORT_ON]);
  }
});

Deno.test("VPN-004 VPN-013 toggle from on turns off (by ID, IP or auto)", async () => {
  for (const p of [ON, prefs({ ExitNodeIP: "100.64.0.1" }), prefs({ AutoExitNode: "any" })]) {
    for (const args of [[], ["toggle"]]) {
      const r = await run(args, { FAKE_PREFS: p });
      assert.equal(r.code, 0, r.stderr);
      assert.deepEqual(r.calls, [SET_OFF]);
      matchAll(r.stdout, [/on -> off/, ...REPORT_OFF]);
    }
  }
});

Deno.test("VPN-005 bad arguments change nothing", async () => {
  for (const args of [["maybe"], ["on", "off"], [""], ["status", "x"]]) {
    const r = await run(args);
    assert.equal(r.code, USAGE_EXIT, `args=${JSON.stringify(args)}`);
    assert.match(r.stderr, /usage: vpn/);
    assert.deepEqual(r.calls, []);
  }
});

const UNREADABLE: Record<string, string>[] = [
  { FAKE_PREFS_FAIL: "1" },
  { FAKE_PREFS: "not json" },
  { FAKE_PREFS: "" },
  { FAKE_PREFS: " \n" },
  { FAKE_PREFS: "null" },
  { FAKE_PREFS: "{}" },
];

Deno.test("VPN-006 unreadable state changes nothing", async () => {
  for (const env of UNREADABLE) {
    const r = await run([], env);
    assert.notEqual(r.code, 0, JSON.stringify(env));
    assert.deepEqual(r.calls, []);
  }
});

Deno.test("VPN-007 failed set is reported", async () => {
  for (const [args, p] of [[["on"], prefs()], [["off"], ON], [[], prefs()], [[], ON]] as const) {
    const r = await run([...args], { FAKE_SET_FAIL: "1", FAKE_PREFS: p });
    assert.notEqual(r.code, 0);
    assert.equal(r.calls.length, 1);
    assert.doesNotMatch(r.stdout, /^VPN: /m);
  }
});

Deno.test("VPN-009 warns while Tailscale is stopped, even if set then fails", async () => {
  for (const env of [{}, { FAKE_SET_FAIL: "1" }] as Record<string, string>[]) {
    const r = await run(["on"], { FAKE_PREFS: prefs({ WantRunning: false }), ...env });
    assert.match(r.stderr, /Tailscale is stopped; traffic is not routed/);
  }
});

Deno.test("VPN-010 status reports and changes nothing", async () => {
  for (const [p, report] of [[ON, REPORT_ON], [prefs(), REPORT_OFF]] as const) {
    const r = await run(["status"], { FAKE_PREFS: p });
    assert.equal(r.code, 0, r.stderr);
    assert.deepEqual(r.calls, []);
    matchAll(r.stdout, [/Tailscale: +Running/, ...report]);
  }
  const lan = await run(["status"], { FAKE_PREFS: prefs({ ExitNodeID: "abc", ExitNodeAllowLANAccess: true }) });
  assert.match(lan.stdout, /LAN access: +allowed/);
  const gone = await run(["status"], { FAKE_PREFS: prefs({ ExitNodeID: "zzz" }) });
  assert.match(gone.stdout, /Exit node: +set, but not found/);
});

Deno.test("VPN-011 unknown public IP is not an error", async () => {
  const r = await run(["status"], { FAKE_CURL_FAIL: "1" });
  assert.equal(r.code, 0, r.stderr);
  assert.match(r.stdout, /Public IP: +unknown/);
});

Deno.test("VPN-012 status fails when state is unreadable", async () => {
  for (const env of [...UNREADABLE, { FAKE_STATUS_FAIL: "1" } as Record<string, string>]) {
    const r = await run(["status"], env);
    assert.notEqual(r.code, 0, JSON.stringify(env));
    assert.doesNotMatch(r.stdout, /^VPN: /m);
  }
});

Deno.test("VPN-014 a failed report after a change is only a warning", async () => {
  const r = await run(["on"], { FAKE_STATUS_FAIL: "1" });
  assert.equal(r.code, 0, r.stderr);
  assert.deepEqual(r.calls, [SET_ON]);
  assert.match(r.stderr, /could not read the new state/);
});
