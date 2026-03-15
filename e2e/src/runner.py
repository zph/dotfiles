"""Test orchestration: seed chezmoi, run setup, execute tests, report results."""

from __future__ import annotations

import subprocess
import textwrap
from dataclasses import dataclass

from src.config import SetupConfig, Test
from src.vm import TartVM


# ANSI colors
GREEN = "\033[32m"
RED = "\033[31m"
YELLOW = "\033[33m"
BOLD = "\033[1m"
RESET = "\033[0m"


@dataclass
class TestResult:
    name: str
    passed: bool
    stdout: str
    stderr: str


def seed_chezmoi(vm: TartVM, chezmoi_data: dict[str, str]) -> None:
    """Pre-seed chezmoi config and generate a test age key in the VM.

    This prevents interactive prompts during `chezmoi init --apply`.
    """
    print(f"\n{BOLD}==> Seeding chezmoi config{RESET}")

    # Generate an age keypair locally (host has age-keygen) and push to the VM.
    keygen = subprocess.run(
        ["age-keygen"],
        capture_output=True, text=True, check=True,
    )
    private_key = keygen.stdout  # full key file content

    # When captured (non-TTY), age-keygen writes:
    #   stdout: "# public key: age1...\nAGE-SECRET-KEY-..."
    #   stderr: "Public key: age1..."  (no # prefix)
    # Check both streams.
    recipient = ""
    for line in keygen.stdout.splitlines() + keygen.stderr.splitlines():
        if line.startswith("# public key:"):
            recipient = line.split(": ", 1)[1].strip()
            break
        if line.startswith("Public key:"):
            recipient = line.split(": ", 1)[1].strip()
            break

    if not recipient:
        raise RuntimeError("Failed to extract recipient from age-keygen output")

    print(f"  Generated test age key locally (recipient: {recipient[:20]}...)")

    # Write the private key to the VM
    vm.ssh_check("mkdir -p ~/.ssh")
    escaped_key = private_key.replace("'", "'\\''")
    vm.ssh_check(f"cat > ~/.ssh/20221104-age-key-dotfiles.key << 'AGE_EOF'\n{private_key}AGE_EOF")
    vm.ssh_check("chmod 600 ~/.ssh/20221104-age-key-dotfiles.key")

    # Build the chezmoi.toml content
    data_lines = "\n".join(f'    {k} = "{v}"' for k, v in chezmoi_data.items())
    chezmoi_toml = textwrap.dedent(f"""\
        encryption = "age"
        [age]
            identity = "$HOME/.ssh/20221104-age-key-dotfiles.key"
            recipient = "{recipient}"

        [data]
        {data_lines}

        [scriptEnv]
            GITHUB_USERNAME = "{chezmoi_data.get('github_username', 'test')}"
    """)

    # Write the config to the VM
    vm.ssh_check("mkdir -p ~/.config/chezmoi")
    vm.ssh_check(f"cat > ~/.config/chezmoi/chezmoi.toml << 'CHEZMOI_EOF'\n{chezmoi_toml}CHEZMOI_EOF")
    print("  Wrote ~/.config/chezmoi/chezmoi.toml")


def run_setup(vm: TartVM, setup: SetupConfig) -> None:
    """Seed chezmoi config and run setup steps."""
    seed_chezmoi(vm, setup.chezmoi_data)

    for step in setup.steps:
        print(f"\n{BOLD}==> Setup: {step.name}{RESET}")
        result = vm.ssh(step.run)
        if result.stdout:
            for line in result.stdout.splitlines():
                print(f"  {line}")
        if result.exit_code != 0:
            print(f"  {RED}FAILED (exit {result.exit_code}){RESET}")
            if result.stderr:
                for line in result.stderr.splitlines():
                    print(f"  {RED}{line}{RESET}")
            raise RuntimeError(f"Setup step failed: {step.name}")
        print(f"  {GREEN}OK{RESET}")


def run_tests(vm: TartVM, tests: list[Test]) -> list[TestResult]:
    """Run each test assertion and collect results."""
    print(f"\n{BOLD}==> Running {len(tests)} tests{RESET}\n")
    results: list[TestResult] = []

    for test in tests:
        result = vm.ssh(test.run)
        passed = result.exit_code == 0
        results.append(TestResult(
            name=test.name,
            passed=passed,
            stdout=result.stdout,
            stderr=result.stderr,
        ))

        status = f"{GREEN}PASS{RESET}" if passed else f"{RED}FAIL{RESET}"
        print(f"  {status}  {test.name}")
        if not passed and result.stderr:
            for line in result.stderr.strip().splitlines():
                print(f"         {RED}{line}{RESET}")

    return results


def print_summary(results: list[TestResult]) -> int:
    """Print results summary and return exit code."""
    passed = sum(1 for r in results if r.passed)
    failed = sum(1 for r in results if not r.passed)
    total = len(results)

    print(f"\n{BOLD}{'=' * 40}{RESET}")
    print(f"{BOLD}Results: {passed}/{total} passed", end="")
    if failed:
        print(f", {RED}{failed} failed{RESET}")
    else:
        print(f" {GREEN}(all passed){RESET}")
    print(f"{BOLD}{'=' * 40}{RESET}")

    if failed:
        print(f"\n{RED}Failed tests:{RESET}")
        for r in results:
            if not r.passed:
                print(f"  - {r.name}")

    return 0 if failed == 0 else 1
