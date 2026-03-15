"""Pre-flight check: ensure the VM image matches the host macOS version."""

from __future__ import annotations

import re
import subprocess
from pathlib import Path

# macOS major version -> Cirrus Labs codename
MACOS_CODENAMES: dict[int, str] = {
    13: "ventura",
    14: "sonoma",
    15: "sequoia",
    16: "tahoe",
}


def detect_macos_version() -> tuple[int, int]:
    """Return (major, minor) macOS version from sw_vers."""
    result = subprocess.run(
        ["sw_vers", "-productVersion"],
        capture_output=True, text=True, check=True,
    )
    parts = result.stdout.strip().split(".")
    return int(parts[0]), int(parts[1]) if len(parts) > 1 else 0


def build_expected_image(major: int) -> str | None:
    """Build the expected Cirrus Labs image URL for a macOS major version."""
    codename = MACOS_CODENAMES.get(major)
    if codename is None:
        return None
    return f"ghcr.io/cirruslabs/macos-{codename}-base:latest"


def extract_codename_from_image(image: str) -> str | None:
    """Extract the macOS codename from a Cirrus Labs image URL."""
    match = re.search(r"macos-(\w+)-base", image)
    return match.group(1) if match else None


def check_image_version(configured_image: str) -> str | None:
    """Check if the configured image matches the host macOS version.

    Returns the expected image string if there's a mismatch, or None if OK.
    """
    major, _ = detect_macos_version()
    expected = build_expected_image(major)
    if expected is None:
        # Unknown macOS version — can't validate, don't block
        return None

    configured_codename = extract_codename_from_image(configured_image)
    expected_codename = extract_codename_from_image(expected)

    if configured_codename == expected_codename:
        return None

    return expected


def update_toml_image(toml_path: Path, new_image: str) -> None:
    """Replace the vm.image value in a TOML file (preserving other content)."""
    content = toml_path.read_text()
    updated = re.sub(
        r'(image\s*=\s*")[^"]*(")',
        rf"\g<1>{new_image}\g<2>",
        content,
        count=1,
    )
    toml_path.write_text(updated)
