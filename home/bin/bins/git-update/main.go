/*
git-update is a tool to update the current branch with the upstream branch.

It will fetch the upstream branch, make sure we're tracking it, pull the latest changes,
and then check if a rebase is needed.

It's executed by the dotfiles/bin/git/git-update script.
*/

package main

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"strings"
)

// ANSI color codes
const (
	colorReset  = "\033[0m"
	colorRed    = "\033[0;31m"
	colorGreen  = "\033[0;32m"
	colorYellow = "\033[0;33m"
)

// Print a header with a message
func header(message string) {
	fmt.Printf("-----> %s\n", message)
}

// Print a warning message in red
func warn(message string) {
	fmt.Printf("%s%s%s\n", colorRed, message, colorReset)
}

// Print a success message in green
func success(message string) {
	fmt.Printf("%s%s%s\n", colorGreen, message, colorReset)
}

// Indent text (similar to the bash function)
func indent(text string) string {
	if text == "" {
		return ""
	}
	lines := strings.Split(text, "\n")
	for i, line := range lines {
		lines[i] = "       " + line
	}
	return strings.Join(lines, "\n")
}

// Execute a command and return its output
func execCommand(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	output, err := cmd.CombinedOutput()
	return string(output), err
}

// Execute a command and print its output with indentation
func execCommandWithIndent(name string, args ...string) error {
	cmd := exec.Command(name, args...)
	output, err := cmd.CombinedOutput()
	fmt.Println(indent(string(output)))
	return err
}

// Get the current branch name
func getBranchName() (string, error) {
	output, err := execCommand("git", "rev-parse", "--abbrev-ref", "HEAD")
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(output), nil
}

// Get the default branch name (main or master)
func getDefaultBranch() (string, error) {
	// First try to get it from git metadata
	output, err := execCommand("git", "metadata", "get", "GIT_DEFAULT_BRANCH")
	if err == nil {
		return strings.TrimSpace(output), nil
	}

	// If that fails, try to get it from remote
	output, err = execCommand("git", "remote", "show", "origin")
	if err != nil {
		return "", err
	}

	// Parse the output to find the default branch
	lines := strings.Split(output, "\n")
	for _, line := range lines {
		if strings.Contains(line, "HEAD branch:") {
			parts := strings.Split(line, ":")
			if len(parts) >= 2 {
				return strings.TrimSpace(parts[1]), nil
			}
		}
	}

	// If we still don't have it, try to infer it
	output, err = execCommand("git", "branch", "-r", "-l", "origin/*")
	if err != nil {
		return "", err
	}

	lines = strings.Split(output, "\n")
	for _, line := range lines {
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "origin/main") {
			return "main", nil
		}
		if strings.HasPrefix(line, "origin/master") {
			return "master", nil
		}
	}

	return "", fmt.Errorf("could not determine default branch")
}

// Get the upstream branch
func getUpstreamBranch() (string, error) {
	output, err := execCommand("git", "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}")
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(output), nil
}

// Pretty print the git log
func gitUpdatePrettyPrintLog(headSHA, remoteSHA string) error {
	// Get the format from git config or use default
	format, err := execCommand("git", "config", "--get", "pretty.update")
	if err != nil || strings.TrimSpace(format) == "" {
		format = "%C(yellow)%h%Cblue%d%Creset %s - %C(white)%an %Cgreen(%cr)%Creset"
	}

	// Get the merge base
	mergeBaseSHA, err := execCommand("git", "merge-base", headSHA, remoteSHA)
	if err != nil {
		return err
	}
	mergeBaseSHA = strings.TrimSpace(mergeBaseSHA)

	// Execute git log
	return execCommandWithIndent("git", "log", "--format="+strings.TrimSpace(format), "--graph", mergeBaseSHA+".."+remoteSHA)
}

// Ask for confirmation
func confirm(question string) bool {
	reader := bufio.NewReader(os.Stdin)
	fmt.Printf("%s (Y/N): ", question)
	response, err := reader.ReadString('\n')
	if err != nil {
		return false
	}

	response = strings.ToLower(strings.TrimSpace(response))
	return response == "y" || response == "yes"
}

func main() {
	// Get the upstream branch
	upstreamBranch, err := getUpstreamBranch()
	if err != nil {
		fmt.Printf("Error getting upstream branch: %v\n", err)
		os.Exit(1)
	}

	// Get the default branch
	defaultBranch, err := getDefaultBranch()
	if err != nil {
		fmt.Printf("Error getting default branch: %v\n", err)
		os.Exit(1)
	}

	// Get the HEAD SHA
	headSHA, err := execCommand("git", "rev-parse", "HEAD")
	if err != nil {
		fmt.Printf("Error getting HEAD SHA: %v\n", err)
		os.Exit(1)
	}
	headSHA = strings.TrimSpace(headSHA)

	// Check if we're on the default branch
	currentBranch, err := getBranchName()
	if err != nil {
		fmt.Printf("Error getting current branch: %v\n", err)
		os.Exit(1)
	}

	if currentBranch != defaultBranch {
		header(fmt.Sprintf("Fetching origin %s", defaultBranch))
		execCommandWithIndent("git", "fetch", "origin", fmt.Sprintf("%s:%s", defaultBranch, defaultBranch), "--prune")
	}

	// Make sure we're tracking remote
	header("Making sure we're tracking remote")
	execCommandWithIndent("git", "branch", "-u", fmt.Sprintf("origin/%s", currentBranch))

	// Get latest from remote on current branch
	header("Getting latest from remote on current branch")
	execCommandWithIndent("git", "pull", "--rebase=merges", "--autostash")

	// Get the remote SHA
	remoteSHA, err := execCommand("git", "rev-parse", upstreamBranch)
	if err != nil {
		fmt.Printf("Error getting remote SHA: %v\n", err)
		os.Exit(1)
	}
	remoteSHA = strings.TrimSpace(remoteSHA)

	// Show changes applied
	header("Changes applied")
	gitUpdatePrettyPrintLog(headSHA, remoteSHA)
	success("✅ Complete")

	// Check if rebase is needed
	hash1, err := execCommand("git", "show-ref", "--head", "-s", fmt.Sprintf("origin/%s", defaultBranch))
	if err != nil {
		fmt.Printf("Error checking default branch: %v\n", err)
		os.Exit(1)
	}
	// Only keep the first line of the output
	if lines := strings.Split(hash1, "\n"); len(lines) > 0 {
		hash1 = strings.TrimSpace(lines[0])
	} else {
		hash1 = strings.TrimSpace(hash1)
	}

	hash2, err := execCommand("git", "merge-base", fmt.Sprintf("origin/%s", defaultBranch), "origin/HEAD")
	if err != nil {
		fmt.Printf("Error checking merge base: %v\n", err)
		os.Exit(1)
	}
	hash2 = strings.TrimSpace(hash2)

	if hash1 == hash2 {
		success("✅ No rebase needed to get current")
	} else {
		fmt.Println("🆘 Rebase is required")
		fmt.Println(hash1, "!=", hash2)
		if confirm("Continue?") {
			execCommandWithIndent("git", "rebase", fmt.Sprintf("origin/%s", defaultBranch))
		} else {
			warn(fmt.Sprintf("Branch not current with origin/%s", defaultBranch))
		}
	}
}
