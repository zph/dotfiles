---
name: reference
description: Research reference material from URLs and create comprehensive documentation. Use this skill when users provide URLs to research, need to gather and synthesize information from web sources, or want to create structured research documentation with citations and summaries.
---

# Reference Material Research Skill

You are tasked with researching reference material provided by the user and creating comprehensive documentation.

## Input
The user will provide a description that may contain one or more URLs to research.

## Process

### 1. Setup url-to-md tool (if not already installed)
Check if `url-to-md` is available, and if not, install it:
```bash
deno install -A --global -n url-to-md https://raw.githubusercontent.com/zph/url-to-md/refs/heads/main/url-to-md.ts
```

### 2. Extract and Process URLs
- Identify all direct URLs in the user's description
- For each URL, use `url-to-md` to download and convert the content to markdown
- Save each article to `docs/research/<descriptive-task-name>/` with a descriptive filename based on the article title or URL
- Use the format: `<article-name>.md`

### 3. Supplementary Research
- Use WebSearch or WebFetch to gather additional context if needed
- Ensure you understand the topic comprehensively

### 4. Create Summary Documentation
Create a `README.md` in `docs/research/<descriptive-task-name>/` that includes:

#### Structure:
```markdown
# [Descriptive Task Name]

## Overview
Brief introduction to the research topic and purpose.

## Key Findings
Summarize the main insights from all sources.

## Sources

### [Article 1 Title]
**Source:** [URL]
**Saved as:** `article-1.md`

[2-3 paragraph summary of key points]

Key takeaways:
- Bullet point 1
- Bullet point 2
- Bullet point 3

### [Article 2 Title]
**Source:** [URL]
**Saved as:** `article-2.md`

[Summary continues...]

## References
1. [Author/Site Name]. "[Article Title]". [URL]. Retrieved [Date].
2. [Continue with all sources...]

## Related Topics
- Topic 1
- Topic 2

## Additional Notes
Any supplementary insights or connections between sources.
```

## Important Guidelines

1. **Citations:** Use proper markdown citation format throughout
2. **File naming:** Use descriptive, kebab-case names for files
3. **Organization:** Each research session gets its own folder under `docs/research/`
4. **Content preservation:** Keep the full `url-to-md` output in individual files
5. **Summary quality:** README.md should synthesize information, not just list it
6. **Cross-references:** Link between related concepts when applicable

## Example Workflow

If user says: "Research these articles on Rust async patterns: https://example.com/rust-async, https://example.com/tokio-guide"

1. Create `docs/research/rust-async-patterns/`
2. Download:
   - `rust-async.md` (from first URL)
   - `tokio-guide.md` (from second URL)
3. Create `README.md` with synthesis of both articles, proper citations, and key insights

## Output
After completing the research:
1. Confirm all URLs were processed successfully
2. Provide the path to the research folder
3. Give a brief summary of what was learned
4. Ask if the user wants any specific aspects explored further
