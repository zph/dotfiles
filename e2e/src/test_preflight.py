"""Tests for macOS version preflight check."""

import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from src.preflight import (
    MACOS_CODENAMES,
    build_expected_image,
    detect_macos_version,
    extract_codename_from_image,
    check_image_version,
)


class TestDetectMacosVersion(unittest.TestCase):
    @patch("src.preflight.subprocess.run")
    def test_returns_version_tuple(self, mock_run):
        mock_run.return_value = type("R", (), {"stdout": "15.2.1\n", "returncode": 0})()
        major, minor = detect_macos_version()
        self.assertEqual(major, 15)
        self.assertEqual(minor, 2)

    @patch("src.preflight.subprocess.run")
    def test_returns_major_only(self, mock_run):
        mock_run.return_value = type("R", (), {"stdout": "14.0\n", "returncode": 0})()
        major, minor = detect_macos_version()
        self.assertEqual(major, 14)
        self.assertEqual(minor, 0)


class TestBuildExpectedImage(unittest.TestCase):
    def test_known_versions(self):
        self.assertEqual(
            build_expected_image(13),
            "ghcr.io/cirruslabs/macos-ventura-base:latest",
        )
        self.assertEqual(
            build_expected_image(14),
            "ghcr.io/cirruslabs/macos-sonoma-base:latest",
        )
        self.assertEqual(
            build_expected_image(15),
            "ghcr.io/cirruslabs/macos-sequoia-base:latest",
        )

    def test_unknown_version_returns_none(self):
        self.assertIsNone(build_expected_image(99))


class TestExtractCodenameFromImage(unittest.TestCase):
    def test_extracts_ventura(self):
        self.assertEqual(
            extract_codename_from_image("ghcr.io/cirruslabs/macos-ventura-base:latest"),
            "ventura",
        )

    def test_extracts_sequoia(self):
        self.assertEqual(
            extract_codename_from_image("ghcr.io/cirruslabs/macos-sequoia-base:latest"),
            "sequoia",
        )

    def test_non_matching_returns_none(self):
        self.assertIsNone(extract_codename_from_image("ubuntu:latest"))


class TestCheckImageVersion(unittest.TestCase):
    @patch("src.preflight.detect_macos_version")
    def test_matching_returns_none(self, mock_detect):
        mock_detect.return_value = (15, 0)
        result = check_image_version("ghcr.io/cirruslabs/macos-sequoia-base:latest")
        self.assertIsNone(result)

    @patch("src.preflight.detect_macos_version")
    def test_mismatch_returns_expected(self, mock_detect):
        mock_detect.return_value = (15, 0)
        result = check_image_version("ghcr.io/cirruslabs/macos-ventura-base:latest")
        self.assertIsNotNone(result)
        self.assertIn("sequoia", result)

    @patch("src.preflight.detect_macos_version")
    def test_unknown_host_version_returns_none(self, mock_detect):
        mock_detect.return_value = (99, 0)
        result = check_image_version("ghcr.io/cirruslabs/macos-ventura-base:latest")
        # Can't determine expected image, so don't block
        self.assertIsNone(result)


class TestUpdateToml(unittest.TestCase):
    @patch("src.preflight.detect_macos_version")
    def test_update_image_in_toml(self, mock_detect):
        from src.preflight import update_toml_image
        mock_detect.return_value = (15, 0)

        tmpdir = tempfile.mkdtemp()
        toml_path = Path(tmpdir) / "e2e.toml"
        toml_path.write_text(
            '[vm]\nimage = "ghcr.io/cirruslabs/macos-ventura-base:latest"\nname = "test"\n'
        )

        update_toml_image(toml_path, "ghcr.io/cirruslabs/macos-sequoia-base:latest")

        content = toml_path.read_text()
        self.assertIn("macos-sequoia-base", content)
        self.assertNotIn("macos-ventura-base", content)
        # Ensure other content is preserved
        self.assertIn('name = "test"', content)


if __name__ == "__main__":
    unittest.main()
