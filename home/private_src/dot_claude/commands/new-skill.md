---
description: Create a new skill with template content
---

Create a new skill file in the .claude/skills directory with the following template:

```markdown
---
name: [skill-name]
description: [Brief description of what this skill does]
version: 1.0.0
---

# [Skill Name]

## Purpose
[Describe what this skill is designed to do]

## Usage
[Explain how to invoke and use this skill]

## Instructions

When this skill is invoked:

1. [Step 1 of what Claude should do]
2. [Step 2 of what Claude should do]
3. [Step 3 of what Claude should do]

## Parameters
[If applicable, describe any parameters this skill accepts]

## Example
[Provide an example of using this skill]

## Notes
[Any additional notes, limitations, or considerations]
```

Prompt the user for:
1. The skill name (will be used as filename, e.g., "code-review" becomes "code-review.md")
2. The description for the frontmatter
3. The purpose and main instructions

Then create the file at `$USER/.claude/skills/{skill-name}.md` with the properly filled template.

After creating the skill, inform the user they can invoke it using the Skill tool in conversations.
