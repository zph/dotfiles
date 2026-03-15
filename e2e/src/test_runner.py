"""Tests for the test runner orchestration."""

import unittest
from unittest.mock import MagicMock, call, patch

from src.config import SetupConfig, Step, Test
from src.runner import TestResult, print_summary, run_tests
from src.vm import SSHResult, TartVM


class TestRunTests(unittest.TestCase):
    def _make_vm(self):
        vm = MagicMock(spec=TartVM)
        return vm

    def test_all_passing(self):
        vm = self._make_vm()
        vm.ssh.return_value = SSHResult(exit_code=0, stdout="ok", stderr="")

        tests = [
            Test(name="test1", run="true"),
            Test(name="test2", run="true"),
        ]
        results = run_tests(vm, tests)

        self.assertEqual(len(results), 2)
        self.assertTrue(all(r.passed for r in results))

    def test_mixed_results(self):
        vm = self._make_vm()
        vm.ssh.side_effect = [
            SSHResult(exit_code=0, stdout="ok", stderr=""),
            SSHResult(exit_code=1, stdout="", stderr="not found"),
        ]

        tests = [
            Test(name="passes", run="true"),
            Test(name="fails", run="false"),
        ]
        results = run_tests(vm, tests)

        self.assertTrue(results[0].passed)
        self.assertFalse(results[1].passed)
        self.assertEqual(results[1].stderr, "not found")

    def test_runs_correct_commands(self):
        vm = self._make_vm()
        vm.ssh.return_value = SSHResult(exit_code=0, stdout="", stderr="")

        tests = [Test(name="t", run="brew --version")]
        run_tests(vm, tests)

        vm.ssh.assert_called_once_with("brew --version")


class TestPrintSummary(unittest.TestCase):
    def test_all_pass_returns_zero(self):
        results = [
            TestResult(name="t1", passed=True, stdout="", stderr=""),
            TestResult(name="t2", passed=True, stdout="", stderr=""),
        ]
        self.assertEqual(print_summary(results), 0)

    def test_any_fail_returns_one(self):
        results = [
            TestResult(name="t1", passed=True, stdout="", stderr=""),
            TestResult(name="t2", passed=False, stdout="", stderr="err"),
        ]
        self.assertEqual(print_summary(results), 1)


if __name__ == "__main__":
    unittest.main()
