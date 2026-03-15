# Instructions

1. Always use TDD approach to building
2. EARS design using our ears skill
3. Tag ears spec ids onto the code area worked on for a given task
4. Use docs/ folder for understanding the project and keep an upto date IMPLEMENTATION.md doc

**Remember:**
- 🧪 Test first, EARS always, trace everything
- 🎯 Test behavior, not implementation
- 📋 **Always update IMPLEMENTATION.md**
- 🔄 Red-Green-Refactor loop is mandatory
- Technical choices for algorithms and distributed systems behavior should focus on the tradeoffs involved and use research skill.

# Python

- **Always use `uv`** for all Python execution. Never invoke `python3` or `python` directly.
- Makefile targets, scripts, and commands should use `uv run --project <path> python ...` or `uv run --project <path> <entry-point>`.
- Python projects use `pyproject.toml` with uv-compatible configuration.

# Makefile
1. Makefiles should have a help target in them that automatically prints the targets and a bit of information.

# Git Repo
1. Every Git repo that has an origin, which is github.com/zph, should have a Makefile at the root of it.
