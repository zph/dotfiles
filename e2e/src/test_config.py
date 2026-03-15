"""Tests for e2e config parsing."""

import tempfile
import unittest
from pathlib import Path

from src.config import Mount, SetupConfig, Step, Test, VMConfig, load_config


SAMPLE_TOML = """\
[vm]
image = "ghcr.io/cirruslabs/macos-ventura-base:latest"
name = "dotfiles-e2e"
cpu = 4
memory = 8192
disk = 50
user = "admin"
password = "admin"

[[vm.mounts]]
name = "dotfiles"
host_path = "."
read_only = true

[[vm.mounts]]
name = "extra"
host_path = "/tmp/extra"
read_only = false

[setup]
[setup.chezmoi_data]
email = "test@e2e.local"
is_work = "false"

[[setup.steps]]
name = "Run bootstrap"
run = "bash /bootstrap.sh"

[[tests]]
name = "Brew works"
run = "brew --version"

[[tests]]
name = "Fish exists"
run = "command -v fish"
"""


class TestLoadConfig(unittest.TestCase):
    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.config_path = Path(self.tmpdir) / "e2e.toml"
        self.config_path.write_text(SAMPLE_TOML)

    def test_vm_config_fields(self):
        vm, setup, tests = load_config(self.config_path)
        self.assertEqual(vm.image, "ghcr.io/cirruslabs/macos-ventura-base:latest")
        self.assertEqual(vm.name, "dotfiles-e2e")
        self.assertEqual(vm.cpu, 4)
        self.assertEqual(vm.memory, 8192)
        self.assertEqual(vm.disk, 50)
        self.assertEqual(vm.user, "admin")
        self.assertEqual(vm.password, "admin")

    def test_mounts_parsed(self):
        vm, _, _ = load_config(self.config_path)
        self.assertEqual(len(vm.mounts), 2)
        self.assertEqual(vm.mounts[0].name, "dotfiles")
        self.assertTrue(vm.mounts[0].read_only)
        self.assertEqual(vm.mounts[1].name, "extra")
        self.assertFalse(vm.mounts[1].read_only)

    def test_mount_host_path_resolved(self):
        vm, _, _ = load_config(self.config_path)
        # Relative "." should resolve to the config file's parent directory
        # Use .resolve() on both sides to handle macOS /var -> /private/var symlinks
        self.assertEqual(vm.mounts[0].host_path, Path(self.tmpdir).resolve())
        # Absolute path stays absolute (resolved)
        self.assertEqual(vm.mounts[1].host_path, Path("/tmp/extra").resolve())

    def test_setup_config(self):
        _, setup, _ = load_config(self.config_path)
        self.assertEqual(setup.chezmoi_data["email"], "test@e2e.local")
        self.assertEqual(setup.chezmoi_data["is_work"], "false")
        self.assertEqual(len(setup.steps), 1)
        self.assertEqual(setup.steps[0].name, "Run bootstrap")
        self.assertEqual(setup.steps[0].run, "bash /bootstrap.sh")

    def test_tests_parsed(self):
        _, _, tests = load_config(self.config_path)
        self.assertEqual(len(tests), 2)
        self.assertEqual(tests[0].name, "Brew works")
        self.assertEqual(tests[0].run, "brew --version")
        self.assertEqual(tests[1].name, "Fish exists")

    def test_missing_file_raises(self):
        with self.assertRaises(FileNotFoundError):
            load_config(Path("/nonexistent/e2e.toml"))

    def test_empty_mounts_default(self):
        toml_no_mounts = """\
[vm]
image = "img"
name = "vm"
cpu = 2
memory = 4096
disk = 30
user = "admin"
password = "admin"

[setup]
[setup.chezmoi_data]
email = "x"

[[tests]]
name = "t"
run = "true"
"""
        p = Path(self.tmpdir) / "no_mounts.toml"
        p.write_text(toml_no_mounts)
        vm, _, _ = load_config(p)
        self.assertEqual(vm.mounts, [])

    def test_empty_steps_default(self):
        toml_no_steps = """\
[vm]
image = "img"
name = "vm"
cpu = 2
memory = 4096
disk = 30
user = "admin"
password = "admin"

[setup]
[setup.chezmoi_data]
email = "x"

[[tests]]
name = "t"
run = "true"
"""
        p = Path(self.tmpdir) / "no_steps.toml"
        p.write_text(toml_no_steps)
        _, setup, _ = load_config(p)
        self.assertEqual(setup.steps, [])


if __name__ == "__main__":
    unittest.main()
