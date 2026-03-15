"""Parse e2e.toml into typed dataclasses."""

from __future__ import annotations

import tomllib
from dataclasses import dataclass, field
from pathlib import Path


@dataclass
class Mount:
    name: str
    host_path: Path
    read_only: bool = False


@dataclass
class VMConfig:
    image: str
    name: str
    cpu: int
    memory: int
    disk: int
    user: str
    password: str
    mounts: list[Mount] = field(default_factory=list)


@dataclass
class Step:
    name: str
    run: str


@dataclass
class SetupConfig:
    chezmoi_data: dict[str, str]
    steps: list[Step] = field(default_factory=list)


@dataclass
class Test:
    name: str
    run: str


def load_config(path: Path) -> tuple[VMConfig, SetupConfig, list[Test]]:
    """Load and parse an e2e TOML config file.

    Returns (VMConfig, SetupConfig, list[Test]).
    """
    with open(path, "rb") as f:
        raw = tomllib.load(f)

    config_dir = path.parent.resolve()

    # Parse VM config
    vm_raw = raw["vm"]
    mounts = []
    for m in vm_raw.get("mounts", []):
        host = Path(m["host_path"])
        if not host.is_absolute():
            host = config_dir / host
        host = host.resolve()
        mounts.append(Mount(name=m["name"], host_path=host, read_only=m.get("read_only", False)))

    vm = VMConfig(
        image=vm_raw["image"],
        name=vm_raw["name"],
        cpu=vm_raw["cpu"],
        memory=vm_raw["memory"],
        disk=vm_raw["disk"],
        user=vm_raw["user"],
        password=vm_raw["password"],
        mounts=mounts,
    )

    # Parse setup config
    setup_raw = raw.get("setup", {})
    steps = [Step(name=s["name"], run=s["run"]) for s in setup_raw.get("steps", [])]
    setup = SetupConfig(
        chezmoi_data=setup_raw.get("chezmoi_data", {}),
        steps=steps,
    )

    # Parse tests
    tests = [Test(name=t["name"], run=t["run"]) for t in raw.get("tests", [])]

    return vm, setup, tests
