---
description: Interactive commit workflow with patch review and smart commit messages
---

Create an interactive commit workflow following these steps:

1. **Discover New Files**: Run `git add -N .` to track all new untracked files without staging their content

2. **Interactive Patch Review**: Run `git add -p` to interactively review and stage changes chunk by chunk

3. **Review Staged Changes**: After the user completes the interactive patch selection:
   - Run `git status` to show what's staged
   - Run `git diff --cached` to show the full diff of staged changes
   - Present this information to the user for their review and approval

4. **Generate Commit Message**: After user approval:
   - Analyze the recent commit history with `git log --oneline -10` to understand the repository's commit message style
   - Review the staged changes to understand the nature of the changes
   - Propose a concise, descriptive commit message that:
     * Follows git commit best practices (imperative mood, clear and concise)
     * Matches the stylistic voice of the repository
     * Accurately reflects the "why" behind the changes
     * Is 1-2 sentences maximum

5. **Create Commit**: Present the proposed commit message to the user and, upon approval, create the commit using a heredoc format:
   ```bash
   git commit -m "$(cat <<'EOF'
   Your proposed commit message here
   EOF
   )"
   ```

6. **Verify**: Run `git status` after committing to confirm success

Follow the repo coding guidelines throughout this process.
