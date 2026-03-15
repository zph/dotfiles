"""CLI entry point for dotfiles e2e tests."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

from src.config import load_config
from src.preflight import check_image_version, update_toml_image
from src.runner import BOLD, RED, RESET, YELLOW, print_summary, run_setup, run_tests
from src.vm import TartVM


def preflight_version_check(config_path: Path, configured_image: str) -> str:
    """Check VM image matches host macOS. Prompt to update if mismatched.

    Returns the image to use (possibly updated).
    """
    expected = check_image_version(configured_image)
    if expected is None:
        return configured_image

    print(f"\n{RED}==> Version mismatch!{RESET}")
    print(f"  Config image:   {configured_image}")
    print(f"  Expected image: {expected}")
    print(f"\n  Your macOS version doesn't match the VM image in {config_path.name}.")

    answer = input(f"\n  Update {config_path.name} to use {expected}? [Y/n] ").strip().lower()
    if answer in ("", "y", "yes"):
        update_toml_image(config_path, expected)
        print(f"  {YELLOW}Updated {config_path.name}{RESET}")
        return expected

    print(f"  {RED}Aborting. Update {config_path.name} manually.{RESET}")
    sys.exit(1)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run dotfiles e2e tests in a fresh Tart VM",
    )
    parser.add_argument(
        "--keep",
        action="store_true",
        help="Keep the VM after tests (for debugging)",
    )
    parser.add_argument(
        "--config",
        default=None,
        help="Path to config.toml (default: config.toml next to this package)",
    )
    parser.add_argument(
        "--tests-only",
        action="store_true",
        help="Skip setup, only run test assertions (assumes VM is ready)",
    )
    args = parser.parse_args()

    # Resolve config path
    if args.config:
        config_path = Path(args.config)
    else:
        config_path = Path(__file__).parent.parent / "config.toml"

    if not config_path.exists():
        print(f"Config not found: {config_path}", file=sys.stderr)
        sys.exit(1)

    vm_config, setup_config, tests = load_config(config_path)

    # Pre-flight: ensure VM image matches host macOS version
    updated_image = preflight_version_check(config_path, vm_config.image)
    if updated_image != vm_config.image:
        # Reload config after update
        vm_config, setup_config, tests = load_config(config_path)

    print(f"\n{BOLD}==> Dotfiles E2E Tests{RESET}")
    print(f"  Config: {config_path}")
    print(f"  VM: {vm_config.name} ({vm_config.image})")
    print(f"  Tests: {len(tests)}")
    print(f"  Keep VM: {args.keep}")

    if args.tests_only:
        # Connect to existing VM, just run tests
        vm = TartVM(vm_config, keep=True)
        vm.wait_for_ssh()
        results = run_tests(vm, tests)
        sys.exit(print_summary(results))

    with TartVM(vm_config, keep=args.keep) as vm:
        run_setup(vm, setup_config)
        results = run_tests(vm, tests)
        exit_code = print_summary(results)

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
