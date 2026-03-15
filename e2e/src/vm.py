"""Tart VM lifecycle management."""

from __future__ import annotations

import subprocess
import time
from dataclasses import dataclass

from src.config import VMConfig


@dataclass
class SSHResult:
    exit_code: int
    stdout: str
    stderr: str


class TartVM:
    """Manage a Tart VM's lifecycle: clone, configure, start, SSH, stop, delete."""

    def __init__(self, config: VMConfig, *, keep: bool = False):
        self.config = config
        self.keep = keep
        self._process: subprocess.Popen | None = None
        self._ip: str | None = None

    def __enter__(self) -> TartVM:
        self.clone()
        self.configure()
        self.start()
        self.wait_for_ssh()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb) -> None:
        self.stop()
        if not self.keep:
            self.delete()

    def clone(self) -> None:
        """Clone the base image. Deletes existing VM with same name first."""
        # Clean up any existing VM with this name
        existing = subprocess.run(
            ["tart", "list", "--quiet"],
            capture_output=True, text=True,
        )
        if self.config.name in existing.stdout.splitlines():
            print(f"  Deleting existing VM '{self.config.name}'...")
            subprocess.run(["tart", "delete", self.config.name], check=True)

        print(f"  Cloning {self.config.image} as '{self.config.name}'...")
        subprocess.run(
            ["tart", "clone", self.config.image, self.config.name],
            check=True,
        )

    def configure(self) -> None:
        """Set VM CPU, memory, and disk size."""
        print(f"  Configuring VM: cpu={self.config.cpu} mem={self.config.memory}MB disk={self.config.disk}GB")
        subprocess.run(
            ["tart", "set", self.config.name,
             "--cpu", str(self.config.cpu),
             "--memory", str(self.config.memory),
             "--disk-size", str(self.config.disk)],
            check=True,
        )

    def start(self) -> None:
        """Start the VM headlessly with configured mounts."""
        cmd = ["tart", "run", "--no-graphics", self.config.name]
        for mount in self.config.mounts:
            suffix = ":ro" if mount.read_only else ""
            cmd.append(f"--dir={mount.name}:{mount.host_path}{suffix}")

        print(f"  Starting VM '{self.config.name}' (headless)...")
        self._process = subprocess.Popen(
            cmd,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def wait_for_ssh(self, timeout: int = 300) -> None:
        """Wait until SSH is reachable on the VM."""
        print(f"  Waiting for SSH (timeout {timeout}s)...")
        deadline = time.monotonic() + timeout

        while time.monotonic() < deadline:
            # Get IP address
            result = subprocess.run(
                ["tart", "ip", self.config.name],
                capture_output=True, text=True,
            )
            if result.returncode != 0:
                time.sleep(5)
                continue

            ip = result.stdout.strip()
            if not ip:
                time.sleep(5)
                continue

            # Try SSH
            ssh_result = self.ssh("echo ok", ip=ip)
            if ssh_result.exit_code == 0 and "ok" in ssh_result.stdout:
                self._ip = ip
                print(f"  SSH ready at {ip}")
                return

            time.sleep(5)

        raise TimeoutError(f"SSH not available after {timeout}s")

    @property
    def ip(self) -> str:
        if self._ip is None:
            raise RuntimeError("VM IP not yet known. Call wait_for_ssh() first.")
        return self._ip

    def ssh(self, cmd: str, *, ip: str | None = None) -> SSHResult:
        """Execute a command in the VM via SSH."""
        target_ip = ip or self.ip
        ssh_cmd = [
            "sshpass", "-p", self.config.password,
            "ssh",
            "-o", "StrictHostKeyChecking=no",
            "-o", "UserKnownHostsFile=/dev/null",
            "-o", "LogLevel=ERROR",
            "-o", "ConnectTimeout=10",
            f"{self.config.user}@{target_ip}",
            cmd,
        ]
        result = subprocess.run(ssh_cmd, capture_output=True, text=True, timeout=600)
        return SSHResult(
            exit_code=result.returncode,
            stdout=result.stdout,
            stderr=result.stderr,
        )

    def ssh_check(self, cmd: str) -> SSHResult:
        """Execute a command via SSH and raise on non-zero exit."""
        result = self.ssh(cmd)
        if result.exit_code != 0:
            raise RuntimeError(
                f"SSH command failed (exit {result.exit_code}): {cmd}\n"
                f"stdout: {result.stdout}\nstderr: {result.stderr}"
            )
        return result

    def stop(self) -> None:
        """Stop the VM process."""
        if self._process is not None:
            print(f"  Stopping VM '{self.config.name}'...")
            self._process.terminate()
            try:
                self._process.wait(timeout=30)
            except subprocess.TimeoutExpired:
                self._process.kill()
                self._process.wait()
            self._process = None

    def delete(self) -> None:
        """Delete the VM."""
        print(f"  Deleting VM '{self.config.name}'...")
        subprocess.run(
            ["tart", "delete", self.config.name],
            capture_output=True,
        )
