package main

import (
	"strings"
	"testing"
)

func TestIndent(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"test", "       test"},
		{"line1\nline2", "       line1\n       line2"},
		{"", ""},
	}

	for _, test := range tests {
		result := indent(test.input)
		if result != test.expected {
			t.Errorf("indent(%q) = %q, expected %q", test.input, result, test.expected)
		}
	}
}

func TestConfirm(t *testing.T) {
	// This is a simple test to ensure the function exists and compiles
	// Actual testing would require mocking stdin
	_ = confirm("Test question")
}

func TestColorConstants(t *testing.T) {
	if !strings.Contains(colorRed, "31m") {
		t.Errorf("colorRed does not contain the expected ANSI code")
	}
	if !strings.Contains(colorGreen, "32m") {
		t.Errorf("colorGreen does not contain the expected ANSI code")
	}
	if !strings.Contains(colorYellow, "33m") {
		t.Errorf("colorYellow does not contain the expected ANSI code")
	}
	if !strings.Contains(colorReset, "0m") {
		t.Errorf("colorReset does not contain the expected ANSI code")
	}
}
