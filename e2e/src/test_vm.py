"""Tests for TartVM lifecycle (unit tests with subprocess mocking)."""

import unittest
from unittest.mock import MagicMock, call, patch

from src.config import Mount, VMConfig
from src.vm import SSHResult, TartVM


def make_vm_config(**overrides) -> VMConfig:
    defaults = dict(
        image="ghcr.io/test/base:latest",
        name="test-vm",
        cpu=2,
        memory=4096,
        disk=30,
        user="admin",
        password="admin",
        mounts=[],
    )
    defaults.update(overrides)
    return VMConfig(**defaults)


class TestTartVMClone(unittest.TestCase):
    @patch("src.vm.subprocess.run")
    def test_clone_deletes_existing_vm(self, mock_run):
        mock_run.side_effect = [
            MagicMock(stdout="test-vm\nother-vm\n"),  # tart list
            MagicMock(),  # tart delete
            MagicMock(),  # tart clone
        ]
        vm = TartVM(make_vm_config())
        vm.clone()

        calls = mock_run.call_args_list
        self.assertEqual(calls[0][0][0], ["tart", "list", "--quiet"])
        self.assertEqual(calls[1][0][0], ["tart", "delete", "test-vm"])
        self.assertEqual(calls[2][0][0][:3], ["tart", "clone", "ghcr.io/test/base:latest"])

    @patch("src.vm.subprocess.run")
    def test_clone_skips_delete_when_not_exists(self, mock_run):
        mock_run.side_effect = [
            MagicMock(stdout="other-vm\n"),  # tart list
            MagicMock(),  # tart clone
        ]
        vm = TartVM(make_vm_config())
        vm.clone()

        calls = mock_run.call_args_list
        self.assertEqual(len(calls), 2)  # list + clone, no delete


class TestTartVMConfigure(unittest.TestCase):
    @patch("src.vm.subprocess.run")
    def test_configure_passes_correct_args(self, mock_run):
        vm = TartVM(make_vm_config(cpu=4, memory=8192, disk=50))
        vm.configure()

        mock_run.assert_called_once_with(
            ["tart", "set", "test-vm",
             "--cpu", "4",
             "--memory", "8192",
             "--disk-size", "50"],
            check=True,
        )


class TestTartVMStart(unittest.TestCase):
    @patch("src.vm.subprocess.Popen")
    def test_start_headless_no_mounts(self, mock_popen):
        vm = TartVM(make_vm_config())
        vm.start()

        cmd = mock_popen.call_args[0][0]
        self.assertEqual(cmd, ["tart", "run", "--no-graphics", "test-vm"])

    @patch("src.vm.subprocess.Popen")
    def test_start_with_mounts(self, mock_popen):
        from pathlib import Path
        mounts = [
            Mount(name="code", host_path=Path("/src"), read_only=True),
            Mount(name="data", host_path=Path("/data"), read_only=False),
        ]
        vm = TartVM(make_vm_config(mounts=mounts))
        vm.start()

        cmd = mock_popen.call_args[0][0]
        self.assertIn("--dir=code:/src:ro", cmd)
        self.assertIn("--dir=data:/data", cmd)


class TestTartVMSSH(unittest.TestCase):
    @patch("src.vm.subprocess.run")
    def test_ssh_builds_correct_command(self, mock_run):
        mock_run.return_value = MagicMock(returncode=0, stdout="ok\n", stderr="")
        vm = TartVM(make_vm_config())
        vm._ip = "192.168.1.100"

        result = vm.ssh("echo hello")

        cmd = mock_run.call_args[0][0]
        self.assertEqual(cmd[0], "sshpass")
        self.assertIn("-p", cmd)
        self.assertIn("admin", cmd)
        self.assertIn("admin@192.168.1.100", cmd)
        self.assertIn("echo hello", cmd)
        self.assertEqual(result.exit_code, 0)

    @patch("src.vm.subprocess.run")
    def test_ssh_check_raises_on_failure(self, mock_run):
        mock_run.return_value = MagicMock(returncode=1, stdout="", stderr="err")
        vm = TartVM(make_vm_config())
        vm._ip = "192.168.1.100"

        with self.assertRaises(RuntimeError):
            vm.ssh_check("failing-command")


class TestTartVMStop(unittest.TestCase):
    def test_stop_terminates_process(self):
        vm = TartVM(make_vm_config())
        mock_proc = MagicMock()
        vm._process = mock_proc

        vm.stop()

        mock_proc.terminate.assert_called_once()
        mock_proc.wait.assert_called_once()
        self.assertIsNone(vm._process)

    def test_stop_noop_when_no_process(self):
        vm = TartVM(make_vm_config())
        vm.stop()  # Should not raise


if __name__ == "__main__":
    unittest.main()
