---
description: Create a new slash command with template content
---

Create a new slash command file in the .claude/commands directory with the following template:

```markdown
---
description: [Brief description of what this command does]
---

[Your command instructions here]

This command should:
- Describe the task clearly
- Include any necessary context
- Specify expected behavior
```

Prompt the user for:
1. The command name (will be used as filename, e.g., "review-pr" becomes "review-pr.md")
2. The description for the frontmatter
3. The command instructions/content
4. Whether the command takes arguments that should be used in the command and an example of how to
   do so

Then create the file at `$USER/.claude/commands/{command-name}.md` with the properly filled template.

After creating the command, inform the user they can use it by typing `/{command-name}` in Claude Code.
